# frozen_string_literal: true

class Postback::SendPrecheckinHandler < Postback::BaseHandler
  def perform
    routes = Rails.application.routes.url_helpers
    form_url = routes.reservation_precheckin_form_url(friend_line_id: @friend.line_user_id)
    send_text_message("こちらのリンクにアクセスして、事前チェックインしましょう〜  #{form_url}")
  end
end
