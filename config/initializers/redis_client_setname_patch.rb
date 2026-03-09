# frozen_string_literal: true

# Memorystore may reject CLIENT SETNAME. Ignore only that command error.
if Rails.env.production?
  module RedisClientSetnamePatch
    def call(*args, &block)
      super
    rescue Redis::CommandError => e
      command = args.first
      is_setname = command.is_a?(Array) &&
        command[0].to_s.casecmp('client').zero? &&
        command[1].to_s.casecmp('setname').zero?

      return 'OK' if is_setname

      raise e
    end
  end

  Redis::Client.prepend(RedisClientSetnamePatch) if defined?(Redis::Client)
end
