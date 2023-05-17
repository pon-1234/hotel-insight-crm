# frozen_string_literal: true

require "#{Rails.root}/lib/common/error_handle.rb"

class Pms::Guest::GetGuests < Pms::BaseRequest
  def perform(guest_id)
    options = {
      headers: auth_header.merge('Content-Type' => 'application/json', 'accept' => 'application/json')
    }
    response = self.class.get "/guests/#{guest_id}", options
    return if response.code != 200

    JSON.parse response.body
  rescue => exception
    raise Common::PmsApiError.new(exception.message)
  end
end
