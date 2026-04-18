# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SidekiqHealthCheckWorker, type: :worker do
  describe '#perform' do
    let(:queue) { instance_double(Sidekiq::Queue, latency: 180.0, size: 120) }
    let(:retry_set) { instance_double(Sidekiq::RetrySet, size: 2) }
    let(:dead_set) { instance_double(Sidekiq::DeadSet, size: 1) }

    before do
      allow(Ops::SlackAlertNotifier).to receive(:enabled?).and_return(true)
      allow(Ops::SlackAlertNotifier).to receive(:notify_once)
      allow(Sidekiq::Queue).to receive(:new).and_return(queue)
      allow(Sidekiq::RetrySet).to receive(:new).and_return(retry_set)
      allow(Sidekiq::DeadSet).to receive(:new).and_return(dead_set)
    end

    it 'notifies when thresholds are exceeded' do
      described_class.new.perform

      expect(Ops::SlackAlertNotifier).to have_received(:notify_once).at_least(:once)
    end
  end
end
