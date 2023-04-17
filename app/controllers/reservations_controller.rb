# frozen_string_literal: true

class ReservationsController < ApplicationController
  include ResponseHelper

  skip_before_action :verify_authenticity_token, only: :callback

  # GET /reservations/precheckin_form/:friend_line_id
  def precheckin_form
  end

  # GET /reservations/inquiry_form/:friend_line_id
  def inquiry_form
    @friend_line_id = params[:friend_line_id]
  end

  # POST /reservations/precheckin/:friend_line_id
  def precheckin
    if precheckin = ReservationPrecheckin.find_by(precheckin_params)
      @precheckin_data = precheckin.slice(ReservationPrecheckin::ATTRIBUTES)
    else
      @precheckin_data = precheckin_params.slice(:phone_number, :check_in_date)
      friend = LineFriend.find_by_line_user_id params[:friend_line_id]
      pms_api_key = friend.line_account.pms_api_key
      reservations = get_reservations(pms_api_key, precheckin_params)
      first_reservation = reservations.find { |h| h['rsvStatus'] != 'Canceled' }

      if first_reservation.present?
        @precheckin_data[:check_out_date] = first_reservation['checkOutDate']
        @precheckin_data[:companion] = first_reservation['companion']
        guest = Pms::Guest::GetGuests.new(pms_api_key).perform(first_reservation['guestId'])
        if guest.present?
          @precheckin_data[:name] = guest['name']
          @precheckin_data[:address] = guest['address']
          @precheckin_data[:birthdate] = guest['birthdate']
          @precheckin_data[:gender] = guest['gender']
        end
      end
    end
    render :precheckin_detail_form
  end

  # POST /reservations/inquire/:friend_line_id
  def inquire
    ReservationInquiryJob.perform_later(inquiry_params)
    redirect_to reservation_inquiry_success_path
  end

  # POST /reservations/precheckin_detail
  def precheckin_detail
    # binding.pry
    friend = LineFriend.find_by_line_user_id params[:friend_line_id]
    pms_api_key = friend.line_account.pms_api_key
    reservations = get_reservations(pms_api_key, precheckin_params)
    first_reservation = reservations.find { |h| h['rsvStatus'] != 'Canceled' }
    if first_reservation.present?
      # binding.pry
      reservation_ids = reservations.select { |h| h['rsvStatus'] != 'Canceled' }.map { |h| h['id'] }
      Pms::Guest::UpdateGuest.new(pms_api_key).perform(first_reservation['guestId'], precheckin_params.slice(:birthdate, :gender, :address))
      reservation_ids&.each {
        |reservation_id|
        # binding.pry
        Pms::Reservation::UpdateReservations.new(pms_api_key).perform(reservation_id, { companion: precheckin_params[:companion] })
      }
    end
    if precheckin = ReservationPrecheckin.find_by(precheckin_params.slice(:phone_number, :check_in_date))
      precheckin.update(precheckin_params)
      messages = [{ 'text'=>I18n.t('messages.precheckin.update_success'), 'type'=>'text' }]
    else
      ReservationPrecheckin.create!(precheckin_params.merge(line_friend_id: friend.id, line_account_id: friend.line_account_id))
      messages = [{ 'text'=>I18n.t('messages.precheckin.create_success'), 'type'=>'text' }]
    end
    payload = {
      channel_id: friend.channel.id,
      messages: messages
    }
    # PushMessageToLineJob.perform_now(payload)
    redirect_to reservation_precheckin_success_path
  rescue => exception
    puts exception.message
  end

  # GET /reservations/inquiry_success
  def inquiry_success
  end

  # GET /reservations/inquiry_success
  def precheckin_success
  end

  # POST /reservations/callback?notifier_id=abc12-123acwab
  # When a bookmarked room becomes available, hotel management system
  # will send a notification via this URL with room information.
  def callback
    validator = SendAvailableRoomNotificationValidator.new(type_id: available_room_params['id'], notifier_id: params['notifier_id'])
    unless validator.valid?
      render_bad_request_with_message(validator.errors.full_messages.first)
      return
    end
    available_stock = available_room_params[:stockCalendar].pluck(:stock).min
    reservation = Reservation.wait.find_by(room_id: params[:id], notifier_id: params[:notifier_id])
    if reservation.nil? || reservation.stock > available_stock
      render_bad_request_with_message('Could not find the data or the stock is less than expected')
      return
    end
    AvailableRoomNotificationJob.perform_later available_room_params, reservation
    render_success
  end

  private
    def precheckin_params
      params
        .require(:precheckin)
        .permit(ReservationPrecheckin::ATTRIBUTES)
    end

    def inquiry_params
      params
        .require(:inquiry)
        .permit(
          :friend_line_id,
          :num_room,
          :date_start,
          :date_end
        )
    end

    def available_room_params
      @available_room_params ||= params.permit(:notifier_id, :paxMax, :paxMin, :id, :name, :otaUrl,
        :roomArea, :roomAreaUnit, :lineImage, labels: [], stockCalendar: [:date, :stock, :price])
      @available_room_params.to_h.deep_transform_keys! { |key| key.to_s.camelize(:lower) }
    end

    def get_reservations(pms_api_key, params)
      reservation_info = {
        checkInFrom: params[:check_in_date],
        checkInTo: params[:check_in_date],
        guestPhoneNumber: params[:phone_number]
      }
      Pms::Reservation::SearchReservations.new(pms_api_key).perform(reservation_info)
    end
end
