# frozen_string_literal: true

class SidekiqHealthCheckWorker
  include Sidekiq::Worker

  sidekiq_options queue: :low, retry: false

  ALERT_QUEUES = %w[critical default mailers].freeze

  def perform
    return unless Ops::SlackAlertNotifier.enabled?

    check_retry_set
    check_dead_set
    ALERT_QUEUES.each { |queue_name| check_queue(queue_name) }
  end

  private
    def check_retry_set
      retries = Sidekiq::RetrySet.new.size
      threshold = Integer(ENV.fetch('SLACK_ALERT_RETRY_THRESHOLD', 1))
      return if retries < threshold

      Ops::SlackAlertNotifier.notify_once(
        key: 'sidekiq-retry-set',
        ttl: Integer(ENV.fetch('SLACK_ALERT_HEALTHCHECK_TTL', 300)),
        text: "Sidekiq retry set is high.\nretries=#{retries}\nthreshold=#{threshold}"
      )
    end

    def check_dead_set
      dead = Sidekiq::DeadSet.new.size
      threshold = Integer(ENV.fetch('SLACK_ALERT_DEAD_THRESHOLD', 1))
      return if dead < threshold

      Ops::SlackAlertNotifier.notify_once(
        key: 'sidekiq-dead-set',
        ttl: Integer(ENV.fetch('SLACK_ALERT_HEALTHCHECK_TTL', 300)),
        text: "Sidekiq dead set has jobs.\ndead=#{dead}\nthreshold=#{threshold}"
      )
    end

    def check_queue(queue_name)
      queue = Sidekiq::Queue.new(queue_name)
      latency_threshold = Integer(ENV.fetch('SLACK_ALERT_QUEUE_LATENCY_THRESHOLD', 120))
      size_threshold = Integer(ENV.fetch('SLACK_ALERT_QUEUE_SIZE_THRESHOLD', 100))

      if queue.latency >= latency_threshold
        Ops::SlackAlertNotifier.notify_once(
          key: "sidekiq-queue-latency:#{queue_name}",
          ttl: Integer(ENV.fetch('SLACK_ALERT_HEALTHCHECK_TTL', 300)),
          text: "Sidekiq queue latency is high.\nqueue=#{queue_name}\nlatency=#{queue.latency.round(1)}s\nsize=#{queue.size}\nthreshold=#{latency_threshold}s"
        )
      end

      return if queue.size < size_threshold

      Ops::SlackAlertNotifier.notify_once(
        key: "sidekiq-queue-size:#{queue_name}",
        ttl: Integer(ENV.fetch('SLACK_ALERT_HEALTHCHECK_TTL', 300)),
        text: "Sidekiq queue size is high.\nqueue=#{queue_name}\nsize=#{queue.size}\nlatency=#{queue.latency.round(1)}s\nthreshold=#{size_threshold}"
      )
    end
end
