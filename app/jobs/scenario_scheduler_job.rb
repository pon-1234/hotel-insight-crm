# frozen_string_literal: true

class ScenarioSchedulerJob < ApplicationJob
  sidekiq_options retry: false
  queue_as :default
  include User::MessagesHelper
  include SendScenarioStatistic

  def perform(channel_id, scenario_id)
    @channel = Channel.find(channel_id)
    @scenario = Scenario.find(scenario_id)

    # Does not send a scenario if it was applying to the channel
    return if ScenarioFriend.running.exists?(scenario: @scenario, line_friend: @channel.line_friend)

    scenario_messages = @scenario.scenario_messages.enabled.ordered
    return if scenario_messages.empty?
    begin_sending_scenario_statistic(@scenario, @channel.line_friend, scenario_messages)
    save_scenario_started_log
    scenario_messages.each do |scenario_message|
      schedule(scenario_message)
    end
    schedule_after_action(scenario_messages.last)
  end

  private
    def schedule(scenario_message)
      schedule_at = deliver_time_for(scenario_message)
      if scenario_message.is_initial? || (schedule_at < Time.zone.now)
        deliver_now(scenario_message)
        after_sending_scenario_statistic(@scenario, @channel.line_friend)
        update_site_measurement_statistic([scenario_message], [@channel.line_friend])
      else
        create_message_event(scenario_message, schedule_at)
      end
    end

    def deliver_now(scenario_message)
      if scenario_message.site_measurements.any?
        scenario_message.site_measurements.each do |site_measurement|
          attach_shorten_url_to_message(scenario_message, site_measurement, @channel.line_friend.line_user_id)
        end
      end
      normalized = scenario_message.content
      if contain_survey_action?(normalized)
        normalized = normalize_messages_with_survey_action(@channel, normalized)
      end
      payload = {
        channel_id: @channel.id,
        messages: [normalized]
      }
      PushMessageToLineJob.perform_now(payload)
    end

    # If last message is initial message then perform after action immediately
    # Otherwise, create a new scenario event
    def schedule_after_action(last_message)
      schedule_at = deliver_time_for(last_message)
      if last_message.is_initial? || (schedule_at < Time.zone.now)
        ActionHandlerJob.perform_now(@channel.line_friend, @scenario.after_action['data'])
        save_scenario_ended_log
        after_sending_scenario_statistic(@scenario, @channel.line_friend)
      else
        schedule_at = schedule_at
        step = last_message.step + 1
        create_after_action_event(schedule_at, step)
      end
    end

    def deliver_time_for(scenario_message)
      date = scenario_message.date
      time = scenario_message.time.to_time
      case @scenario.mode
      when 'time'
        (Time.zone.today + scenario_message.date).in_time_zone.change({ hour: time.hour, min: time.min, sec: 0 })
      when 'elapsed_time'
        Time.zone.now.change({ sec: 0 }) + date.day + time.hour.hour + time.min.minute
      end
    end

    def create_message_event(message, schedule_at)
      scenario_event = ScenarioEvent.new(
        line_account: @channel.line_account,
        scenario: @scenario,
        channel: @channel,
        scenario_message: message,
        type: 'message',
        content: Normalizer::MessageNormalizer.new(message.content, @channel.line_friend).perform,
        schedule_at: schedule_at,
        order: message.step,
        status: 'queued',
        scenario_log: @scenario_log
      )
      scenario_event.save!
    end

    def create_after_action_event(schedule_at, step)
      scenario_event = ScenarioEvent.new(
        line_account: @channel.line_account,
        scenario: @scenario,
        channel: @channel,
        type: 'after_action',
        content: Normalizer::MessageNormalizer.new(@scenario.after_action['data'], @channel.line_friend).perform,
        schedule_at: schedule_at,
        order: step,
        status: 'queued',
        is_last: true,
        scenario_log: @scenario_log
      )
      scenario_event.save!
    end

    def save_scenario_started_log
      Messages::SystemLogBuilder.new(@channel).perform_scenario_start(@scenario)
    end

    def save_scenario_ended_log
      Messages::SystemLogBuilder.new(@channel).perform_scenario_end(@scenario)
    end
end
