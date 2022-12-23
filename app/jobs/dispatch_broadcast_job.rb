# frozen_string_literal: true

class DispatchBroadcastJob < ApplicationJob
  sidekiq_options retry: false
  queue_as :default
  include User::MessagesHelper

  MULTICAST_BATCH_SIZE = 500

  def perform(broadcast_id)
    @broadcast = Broadcast.find(broadcast_id)
    # Change broadcast status to sending
    @broadcast.update_columns(status: 'sending', deliver_at: Time.zone.now)
    success = dispatch_to_all if @broadcast.broadcast_type_all?
    success = dispatch_with_condition if @broadcast.broadcast_type_condition?
    @broadcast.update_columns(status: success ? 'done' : 'error')
  rescue
    @broadcast.update_columns(status: 'error')
  end

  # send message to every friends of line official account
  # using broadcast api to reduce message count
  def dispatch_to_all
    line_account = @broadcast.line_account
    friends = line_account.line_friends
    messages = @broadcast.broadcast_messages
    channels = Channel.where(line_friend_id: friends.map(&:id))

    nomalized_messages_data = []

    if messages.any? { |message| message.site_measurements.any? }
      send_messages_with_shorten_urls(line_account, messages, friends)
      update_site_measurement_statistic(messages, friends)
      return true
    end

    messages.each do |message|
      nomalized_messages_data << Normalizer::MessageNormalizer.new(message.content).perform
    end

    if contain_survey_action?(nomalized_messages_data)
      send_messages_with_survey_action(channels, nomalized_messages_data)
      nomalized_messages_data.each do |content|
        insert_delivered_message(channels, content)
      end
    else
      # Deliver messages via line api
      success = send_multicast(line_account, nomalized_messages_data, friends)
      nomalized_messages_data.each do |content|
        insert_delivered_message(channels, content)
      end if success
      success
    end
  end

  # send message to specific friend
  # using multicast api to send message to friends
  def dispatch_with_condition
    line_account = @broadcast.line_account

    friends = filter_friend_by_conditions
    channels = Channel.where(line_friend_id: friends.map(&:id))
    messages = @broadcast.broadcast_messages

    nomalized_messages_data = []

    if messages.any? { |message| message.site_measurements.any? }
      send_messages_with_shorten_urls(line_account, messages, friends)
      update_site_measurement_statistic(messages, friends)
      return true
    end

    messages.each do |message|
      nomalized_messages_data << Normalizer::MessageNormalizer.new(message.content).perform
    end

    if contain_survey_action?(nomalized_messages_data)
      send_messages_with_survey_action(channels, nomalized_messages_data)
      nomalized_messages_data.each do |content|
        insert_delivered_message(channels, content)
      end
    else
      success = send_multicast(line_account, nomalized_messages_data, friends)
      nomalized_messages_data.each do |content|
        insert_delivered_message(channels, content)
      end if success
      success
    end
  end

  private
    # Check if any action contains a survey action
    def contain_survey_action?(messages)
      messages.extend Hashie::Extensions::DeepLocate
      survey_actions = messages.deep_locate -> (key, value, object) { key.eql?('type') && value.eql?('survey') }
      !survey_actions.blank?
    end

    # If a message in the list contain survey action, we could not use broadcast or multicast to distribute messages
    # In the case, we have to generate survey url for each channel and send message using PushMessage
    def send_messages_with_survey_action(channels, messages)
      channels.each do |channel|
        LineApi::PushMessage.new(@broadcast.line_account)
          .perform(
            normalize_messages_with_survey_action(channel, messages),
            channel.line_friend.line_user_id
          )
      end
    end

    def send_broadcast(line_account, messages_data)
      LineApi::Broadcast.new(line_account).perform(messages_data)
    end

    def send_multicast(line_account, messages_data, friends)
      friends.in_groups_of(MULTICAST_BATCH_SIZE, false) do |friends_info|
        friends_info&.each do |friend|
          messages_change = Marshal.load(Marshal.dump messages_data)
          messages_change.map! do |message|
            message['text'].gsub! '{name}', friend.name if message['text']
            message
          end
          LineApi::Multicast.new(line_account).perform(messages_change, friend.line_user_id)
        end
      end
      true
    end

    # TODO need refactoring
    def filter_friend_by_conditions
      conditions = @broadcast.conditions
      add_friend_date_cond = conditions['add_friend_date']
      friends = @broadcast.line_account.line_friends
      if conditions['type']&.eql?('specific')
        friends = friends.created_at_gteq(add_friend_date_cond['start_date']).created_at_lteq(add_friend_date_cond['end_date'])
      end
      # filter by tags
      unless @broadcast.tags.empty?
        friends = friends.joins(:tags).references(:tags).where(tags: { id: @broadcast.tag_ids })
      end
      friends
    end

    def insert_delivered_message(channels, message_content)
      message_params = {
        message: message_content.with_indifferent_access,
        timestamp: Time.zone.now
      }
      channels.each do |channel|
        next if channel.locked?
        Messages::MessageBuilder.new(nil, channel, message_params).perform
        Messages::SystemLogBuilder.new(channel).perform_broadcast(@broadcast)
      end
    end

    def send_messages_with_shorten_urls(line_account, messages, friends)
      friends.each do |friend|
        nomalized_messages_data = []
        messages.each do |message|
          message.reload
          if message.site_measurements.any?
            message.site_measurements.each do |site_measurement|
              attach_shorten_url_to_message(message, site_measurement, friend.line_user_id)
            end
          end
          nomalized_messages_data << Normalizer::MessageNormalizer.new(message.content).perform
        end
        LineApi::PushMessage.new(line_account).perform nomalized_messages_data, friend.line_user_id
        nomalized_messages_data.each do |content|
          insert_delivered_message([friend.channel], content)
        end
      end
    end
end
