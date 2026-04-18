# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ops::SlackAlertNotifier do
  describe '.enabled?' do
    it 'returns true when webhook url is present' do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('SLACK_ALERT_WEBHOOK_URL').and_return('https://hooks.slack.com/services/test/webhook')

      expect(described_class.enabled?).to be(true)
    end
  end
end
