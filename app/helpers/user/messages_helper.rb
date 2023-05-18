# frozen_string_literal: true

module User::MessagesHelper
  # Check if any action contains a survey action
  def contain_survey_action?(messages)
    messages.extend Hashie::Extensions::DeepLocate
    survey_actions = messages.deep_locate -> (key, value, object) { key.eql?('type') && value.eql?('survey') }
    !survey_actions.blank?
  end

  # Generate survey url before sending to each friend
  def gen_survey_url(survey, friend_id)
    routes = Rails.application.routes.url_helpers
    routes.new_survey_answer_form_url(code: survey.code, friend_id: friend_id)
  end

  def normalize_messages_with_survey_action(channel, messages)
    messages = Marshal.load(Marshal.dump messages)
    messages.extend Hashie::Extensions::DeepLocate
    # Find all postback action
    survey_actions = messages.deep_locate -> (key, value, object) { key.eql?('type') && value.eql?('survey') }
    survey_actions.each do |action|
      survey_id = action['content']['id']
      survey = Survey.find(survey_id)
      survey_url = gen_survey_url(survey, channel.line_friend.line_user_id)
      action['type'] = 'uri'
      action['uri'] = survey_url
      action['linkUri'] = survey_url
    end
    messages
  end

  def update_site_measurement_statistic(messages, friends)
    messages = messages.select { |message| message.is_text_message? && message.site_measurements.exists? }
    messages.each do |message|
      message.site_measurements.each do |site_measurement|
        site = site_measurement.site
        friends.each do |friend|
          site.update! sending_count: site.sending_count.next
          site_measurement.update! sending_count: site_measurement.sending_count.next
          unless SitesLineFriend.exists?(site_id: site.id, line_friend_id: friend.id, sent: true)
            SitesLineFriend.create!(site_id: site.id, line_friend_id: friend.id, sent: true)
            site.update! receiver_count: site.receiver_count.next
          end
          unless SiteMeasurementsLineFriend.exists?(site_measurement_id: site_measurement.id, line_friend_id: friend.id, sent: true)
            SiteMeasurementsLineFriend.create!(site_measurement_id: site_measurement.id, line_friend_id: friend.id, sent: true)
            site_measurement.update! receiver_count: site_measurement.receiver_count.next
          end
        end
      end
    end
  end

  def attach_shorten_url_to_message(message, site_measurement, line_user_id)
    site_reference = SiteReference.create! code: SiteReference.generate_code, line_user_id: line_user_id,
      site_measurement_id: site_measurement.id
    shorten_url = Rails.application.routes.url_helpers.site_statistic_url(site_reference.code)
    need_to_replace_url = site_measurement.site.url
    message_content_text = message.content['text'].dup
    message_content_text.gsub!(need_to_replace_url, shorten_url)
    message.content['text'] = message_content_text
  end
end
