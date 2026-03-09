# frozen_string_literal: true

# Get a list of users who added your LINE Official Account as a friend
class LineApi::PushMessage < LineApi::BaseRequest
  def perform(messages, friend_id)
    response = client.push_message(friend_id, messages)
    if response.code == HTTP_OK
      true
    else
      Rails.logger.error(
        "[LineApi::PushMessage] failed code=#{response.code} friend_id=#{friend_id} body=#{response.body}"
      )
      false
    end
  rescue StandardError => e
    Rails.logger.error("[LineApi::PushMessage] exception=#{e.class} message=#{e.message}")
    false
  end
end
