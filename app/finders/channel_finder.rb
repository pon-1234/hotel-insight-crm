# frozen_string_literal: true

class ChannelFinder
  def initialize(ability, params)
    @ability = ability
    @params = params
  end

  def perform
    current_channels
  end

  private
    def channels
      Channel.accessible_by(@ability).where('channels.locked = ?', false).includes([line_friend: [:tags, taggings: [:tag]]])
    end

    def current_channels
      if @params[:before].present?
        @q = channels.reorder('last_activity_at desc').where('UNIX_TIMESTAMP(last_activity_at) < (?)', @params[:before].to_time.to_i)
      else
        @q = channels.reorder('last_activity_at desc')
      end
      @q.ransack(@params[:q]).result.distinct.limit(1000)
    end
end
