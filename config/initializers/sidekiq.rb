# frozen_string_literal: true

Sidekiq::Extensions.enable_delay!

Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'], namespace: 'lineinsight' }

  config.error_handlers << proc do |exception, context_hash|
    job = context_hash[:job] || {}
    worker_class = job['wrapped'] || job['class'] || context_hash[:class] || 'UnknownWorker'
    queue = job['queue'] || context_hash[:queue] || 'unknown'

    Ops::SlackAlertNotifier.notify_once(
      key: "sidekiq-error:#{worker_class}:#{exception.class}",
      ttl: Integer(ENV.fetch('SLACK_ALERT_ERROR_TTL', 300)),
      text: [
        'Sidekiq job raised an exception.',
        "worker=#{worker_class}",
        "queue=#{queue}",
        "error_class=#{exception.class}",
        "message=#{exception.message}",
        "jid=#{job['jid']}"
      ].compact.join("\n")
    )
  end

  config.death_handlers << lambda do |job, exception|
    worker_class = job['wrapped'] || job['class'] || 'UnknownWorker'

    Ops::SlackAlertNotifier.notify_once(
      key: "sidekiq-dead-job:#{worker_class}",
      ttl: Integer(ENV.fetch('SLACK_ALERT_DEAD_TTL', 600)),
      text: [
        'Sidekiq job moved to dead set.',
        "worker=#{worker_class}",
        "queue=#{job['queue']}",
        "error_class=#{exception.class}",
        "message=#{exception.message}",
        "jid=#{job['jid']}"
      ].compact.join("\n")
    )
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URL'], namespace: 'lineinsight' }
end
