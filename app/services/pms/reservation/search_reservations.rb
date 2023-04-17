# frozen_string_literal: true

require "#{Rails.root}/lib/common/error_handle.rb"

class Pms::Reservation::SearchReservations < Pms::BaseRequest
  def perform(reservation_info)
    options = {
      headers: auth_header.merge('Content-Type' => 'application/json', 'accept' => 'application/json'),
      body: reservation_info.to_json
    }
    response = self.class.post '/reservations/search', options
    if response.code != 200
      raise Common::PmsApiError.new(response.body) if response.code == 403
    else
      JSON.parse response.body
    end
  rescue => exception
    raise Common::PmsApiError.new(exception.message)
  end
end
