# frozen_string_literal: true

require 'digest'

class Ops::SlackAlertNotifier
  include HTTParty

  DEFAULT_TTL = 300

  class << self
    def enabled?
      webhook_url.present?
    end

    def notify_once(key:, text:, ttl: DEFAULT_TTL)
      return false unless enabled?
      return false unless acquire_lock(key, ttl)

      response = post(
        webhook_url,
        body: { text: decorate(text) }.to_json,
        headers: { 'Content-Type' => 'application/json' },
        timeout: 5
      )
      response.success?
    rescue StandardError => e
      Rails.logger.error("[Ops::SlackAlertNotifier] #{e.class}: #{e.message}")
      false
    end

    private
      def webhook_url
        ENV['SLACK_ALERT_WEBHOOK_URL']
      end

      def acquire_lock(key, ttl)
        redis_key = "ops_slack_alert:#{Digest::SHA256.hexdigest(key)}"
        Sidekiq.redis { |redis| redis.set(redis_key, Time.zone.now.to_i, nx: true, ex: ttl) }
      end

      def decorate(text)
        lines = []
        lines << "[#{Rails.env}] Hotel Insight CRM alert"
        lines << "service=#{ENV['K_SERVICE']}" if ENV['K_SERVICE'].present?
        lines << text
        lines.compact.join("\n")
      end
  end
end
