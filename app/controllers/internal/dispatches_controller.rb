# frozen_string_literal: true

class Internal::DispatchesController < ActionController::API
  before_action :authorize_dispatch!

  def broadcasts
    dispatchable_ids = Broadcast.dispatchable.limit(100).pluck(:id)
    dispatchable_ids.each do |id|
      DispatchBroadcastJob.perform_now(id)
    end

    render json: { status: 'ok', dispatched: dispatchable_ids.length }
  end

  private
    def authorize_dispatch!
      expected_token = ENV['INTERNAL_DISPATCH_TOKEN'].presence || ENV['CRM_API_KEY']
      provided_token = request.authorization.to_s.split(' ').last

      return if expected_token.present? && provided_token == expected_token

      head :unauthorized
    end
end
