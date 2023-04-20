# frozen_string_literal: true

class SurveysController < ApplicationController
  before_action :find_survey, only: [:show, :answer, :form, :answer_success, :precheckin_answer]

  include SurveysHelper

  # GET /surveys/:code
  def show
    @survey = Survey.find_by(code: params[:code])
    if @survey.blank? || !@survey.published?
      render_bad_request
    end
  end

  # GET /surveys/:code/:friend_id
  def form
    @code = params[:code]
    @friend_id = params[:friend_id]
    friend = LineFriend.find_by(line_account_id: @survey.line_account_id, line_user_id: @friend_id)
    unless can_answer?(@survey, friend)
      return redirect_to root_path, flash: { warning: '回答フォームにアクセスできません。' }
    end

    redirect_if_already_answered

    if @survey.type == 'precheckin'
      render :precheckin_form
    end
  end

  # POST /surveys/precheckin/:code/:friend_id
  def precheckin
    @code = params[:code]
    @friend_id = params[:friend_id]
    @answers = {}

    p = format_answer_params
    precheckin = ReservationPrecheckin.find_by(phone_number: p[:answers]['1'][:answer], check_in_date: p[:answers]['2'][:answer])
    if precheckin.present?
      survey_answers = precheckin.survey_response&.survey_answers.includes(:file_blob, file_attachment: [:blob])
      survey_answers.each_with_index do |answer, index|
        if answer.file_blob.present?
          @answers[(index+1).to_s] = { answer: answer.file_blob.filename.to_s }
        else
          @answers[(index+1).to_s] = { answer: answer.answer }
        end
      end
    else
      @answers['2'] = { answer: p[:answers]['1'][:answer] }
      @answers['3'] = { answer: p[:answers]['2'][:answer] }
      friend = LineFriend.find_by_line_user_id @friend_id
      pms_api_key = friend.line_account.pms_api_key
      @have_api_key = pms_api_key.present?
      reservations = get_reservations(pms_api_key, @answers)
      first_reservation = reservations&.find { |h| h['rsvStatus'] != 'Canceled' }
      @answers['4'] = { answer: first_reservation&.[]('checkOutDate') }
      @answers['8'] = { answer: first_reservation&.[]('companion') }
      guest = Pms::Guest::GetGuests.new(pms_api_key).perform(first_reservation&.[]('guestId'))
      @answers['1'] = { answer: guest&.[]('name') }
      @answers['5'] = { answer: guest&.[]('address') }
      @answers['6'] = { answer: guest&.[]('gender') }
      @answers['7'] = { answer: guest&.[]('birthdate') }
    end

    render :precheckin_detail_form
  end

  # POST /surveys/precheckin_answer/:code/:friend_id
  def precheckin_answer
    p = format_answer_params

    friend = LineFriend.find_by_line_user_id params[:friend_id]
    pms_api_key = friend.line_account.pms_api_key
    reservations = get_reservations(pms_api_key, p[:answers])
    first_reservation = reservations&.find { |h| h['rsvStatus'] != 'Canceled' }

    if first_reservation.present?
      reservation_ids = reservations.select { |h| h['rsvStatus'] != 'Canceled' }.map { |h| h['id'] }
      Pms::Guest::UpdateGuest.new(pms_api_key).perform(first_reservation['guestId'], precheckin_default_params(friend, p[:answers]).slice("birthdate", "gender", "address"))
      reservation_ids&.each {
        |reservation_id|
        Pms::Reservation::UpdateReservations.new(pms_api_key).perform(reservation_id, { companion: precheckin_default_params(friend, p[:answers])["companion"] })
      }
    end

    precheckin = ReservationPrecheckin.find_by(precheckin_default_params(friend, p[:answers]).slice('phone_number', 'check_in_date'))
    if precheckin.present?
      start_with_question = 5
      reservation_precheckin_params = {}

      %w[address gender birthdate companion].each.with_index(start_with_question) do |attr, index|
        reservation_precheckin_params[attr] = get_answer(index, p[:answers])
      end

      answers_params = {
        answers: p[:answers].select { |k, v| k.to_i >= start_with_question },
        code: p[:code],
        friend_id: p[:friend_id]
      }

      precheckin.update(reservation_precheckin_params)
      update_answer(@survey, precheckin.survey_response.survey_answers.offset(start_with_question - 1), answers_params)
      messages = [{ 'text'=>I18n.t('messages.precheckin.update_success'), 'type'=>'text' }]
    else
      precheckined = ReservationPrecheckin.create!(precheckin_default_params(friend, p[:answers]))
      
      build_answer(@survey, p, precheckined.id)
      messages = [{ 'text'=>I18n.t('messages.precheckin.create_success'), 'type'=>'text' }]
    end
    payload = {
      channel_id: friend.channel.id,
      messages: messages
    }
    PushMessageToLineJob.perform_now(payload)
    redirect_to survey_answer_success_path(code: params[:code], friend_id: params[:friend_id])
  rescue
    redirect_to survey_answer_error_path(code: params[:code], friend_id: params[:friend_id])
  end

  # POST /surveys/:code/:friend_id
  def answer
    build_answer(@survey, answer_params)
    redirect_to survey_answer_success_path(code: params[:code], friend_id: params[:friend_id])
  rescue
    redirect_to survey_answer_error_path(code: params[:code], friend_id: params[:friend_id])
  end

  # GET /surveys/:code/:friend_id/answer_success
  def answer_success
  end

  # GET /surveys/:code/:friend_id/answer_error
  def answer_error
  end

  # GET /surveys/:code/:friend_id/already_answer
  def already_answer
  end

  private
    def answer_params
      params.permit(
        :code,
        :friend_id,
        answers: [
          :id,
          :answer
        ]
      )
    end

    def format_answer_params
      answer_params[:answers].to_h.each_with_object({answers: {}, code: answer_params[:code], friend_id: answer_params[:friend_id]}) do |(qnum, answer_data), data|
        data[:answers][qnum] = {id: answer_data[:id], answer: answer_data[:answer]}
        next if answer_data[:answer].is_a?(ActionDispatch::Http::UploadedFile)

        if answer_data[:answer]&.match?(/\d{4}年\d{1,2}月\d{1,2}日/) && qnum.to_i <= 8
          data[:answers][qnum][:answer] = Date.parse(answer_data[:answer].gsub(/(\d{4})年(\d{1,2})月(\d{1,2})日/, '\1-\2-\3')).strftime("%Y-%m-%d")
        end
      end
    end

    def precheckin_default_params friend, answers
      precheckin_params = {
        line_friend_id: friend.id,
        line_account_id: friend.line_account_id,
      }

      %w[name phone_number check_in_date check_out_date address gender birthdate companion].each.with_index(1) do |attr, index|
        precheckin_params[attr] = get_answer(index, answers)
      end

      precheckin_params
    end

    def get_answer index, answers
      answers[index.to_s][:answer]
    end

    def find_survey
      @survey = Survey.find_by(code: params[:code])
    end

    def can_answer?(survey, friend)
      survey.present? and friend.present? and survey.published?
    end

    def redirect_if_already_answered
      friend = LineFriend.find_by(line_user_id: @friend_id, line_account_id: @survey.line_account)
      response = SurveyResponse.find_by(survey: @survey, line_friend_id: friend&.id)
      if !@survey.re_answer? && response.present?
        redirect_to survey_already_answer_path(code: params[:code], friend_id: params[:friend_id])
      end
    end

    def get_reservations(pms_api_key, answers)
      reservation_info = {
        checkInFrom: answers['3'][:answer],
        checkInTo: answers['3'][:answer],
        guestPhoneNumber: answers['2'][:answer]
      }
      Pms::Reservation::SearchReservations.new(pms_api_key).perform(reservation_info)
    end
end
