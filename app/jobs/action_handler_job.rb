# frozen_string_literal: true

class ActionHandlerJob < ApplicationJob
  sidekiq_options retry: false
  queue_as :default

  def perform(friend, action, reply_token = nil)
    @friend = friend
    @action = action
    @reply_token = reply_token
    # Create text message if friend select option contains displayText
    handle_display_text(@action['displayText']) if @action['displayText'].present?
    # Handle multiple actions
    handle_message_action(@action['actions']) if @action['actions'].present?
    # Handle single action
    handle_message_action([@action['action']]) if @action['action'].present?
  end

  private
    def handle_message_action(actions)
      actions.each do |action|
        action_content = action['content']
        case action['type']
        when 'text'
          Postback::SendTextMessageHandler.new(@friend, action_content, @reply_token).perform
          # Reply token is valid only for first time we use
          @reply_token = nil
        when 'email'
          Postback::SendMailHandler.new(@friend, action_content).perform
        when 'scenario'
          Postback::SendScenarioHandler.new(@friend, action_content).perform
        when 'template'
          Postback::SendTemplateHandler.new(@friend, action_content).perform
        when 'tag'
          Postback::AssignOrUnassignTagHandler.new(@friend, action_content).perform
        when 'reminder'
          Postback::SetupReminderHandler.new(@friend, action_content).perform
        when 'scoring'
          Postback::ScoringHandler.new(@friend, action_content).perform
        when 'precheckin'
          Postback::SendPrecheckinHandler.new(@friend, action_content).perform
        when 'rsv_intro'
          Postback::SendReservationInstructionHandler.new(@friend, action_content).perform
        when 'rsv_bookmark'
          Postback::CreateRsvBookmarkHandler.new(@friend, action_content).perform
        when 'rsv_cancel_intro'
          Postback::SendRsvCancellationIntroHandler.new(@friend, action_content).perform
        when 'rsv_rm_bookmark'
          Postback::RemoveRsvBookmarkHandler.new(@friend, action_content).perform
        when 'rsv_contact'
          Postback::ContactRsvHandler.new(@friend, action_content).perform
        when 'service_review'
          Postback::SendServiceReviewFormHandler.new(@friend, action_content).perform
        when 'assign_staff'
          Postback::AssignStaffHandler.new(@friend, action_content).perform
        end
        sleep 0.1
      end
    end

    def handle_display_text(text)
      Messages::MessageBuilder.new(@friend, @friend.channel, { message: { type: 'text', text: text } }.try(:with_indifferent_access)).perform
    end
end
