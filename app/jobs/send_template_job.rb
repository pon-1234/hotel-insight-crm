# frozen_string_literal: true

class SendTemplateJob < ApplicationJob
  sidekiq_options retry: false
  queue_as :critical

  include User::MessagesHelper

  def perform(channel_id, template_id)
    @channel = Channel.find(channel_id)
    template = Template.find(template_id)
    template_messages = template.template_messages
    messages = template_messages.map(&:content)
    if contain_survey_action?(messages)
      payload = {
        channel_id: channel_id,
        messages: normalize_messages_with_survey_action(@channel, messages)
      }
    else
      payload = {
        channel_id: channel_id,
        messages: messages
      }
    end
    PushMessageToLineJob.perform_now(payload)
  end
end
