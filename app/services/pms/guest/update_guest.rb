# frozen_string_literal: true

require "#{Rails.root}/lib/common/error_handle.rb"

class Pms::Guest::UpdateGuest < Pms::BaseRequest
  def perform(pms_guest_id, guest_info = {})
    options = {
      headers: auth_header.merge('Content-Type' => 'application/json', 'accept' => 'application/json'),
      body: guest_info.to_json
    }
    response = self.class.put "/guests/#{pms_guest_id}", options
    raise Common::PmsApiError.new(response.message) if response.code != 200
    JSON.parse response.body
  rescue => exception
    raise Common::PmsApiError.new(exception.message)
  end
end
