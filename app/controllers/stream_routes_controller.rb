# frozen_string_literal: true

class StreamRoutesController < ApplicationController
  MAX_RETRY_TIME = 3
  RETRY_DELAY = 0.5

  def show
    @stream_route = StreamRoute.find_by code: params[:stream_route_code]
    @resolved_liff_id = params[:liff_id].presence || @stream_route&.client&.line_account&.liff_id.to_s
    if params[:friendship_status_changed] && params[:line_user_id]
      @line_friend = LineFriend.find_by!(line_user_id: params[:line_user_id])
      # in case line friend is added first time then
      # logic to run actions is included in after_create_commit callback in the line_friend model
      if @line_friend.is_changed_before? && @stream_route.actions.present?
        StreamRouteActionHandlerJob.perform_later(@line_friend, @stream_route.actions.first['data'])
      end
      update_source_for_line_friend
    elsif params[:line_user_id] && @stream_route.always_run_actions
      # in case chose アクションの実行 -> いつでも then always run actions everytime user access the link
      @line_friend = LineFriend.find_by!(line_user_id: params[:line_user_id])
      StreamRouteActionHandlerJob.perform_later(@line_friend, @stream_route.actions.first['data']) if @stream_route.actions.present?
    end
  end

  private
    def update_source_for_line_friend(retry_count = 0)
      retry_count += 1
      @line_friend.update!(stream_route_id: @stream_route.id)
    rescue => exception
      unless retry_count >= MAX_RETRY_TIME
        sleep RETRY_DELAY
        # use retry to avoid case line friend not exist because follow hook has not done yet
        retry
      else
        raise exception.message
      end
    end
end
