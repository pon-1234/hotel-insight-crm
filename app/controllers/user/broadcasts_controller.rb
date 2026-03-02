# frozen_string_literal: true

class User::BroadcastsController < User::ApplicationController
  load_and_authorize_resource
  before_action :find_broadcast, only: [:show, :update, :destroy]

  include User::BroadcastsHelper

  # GET /user/broadcasts
  def index
    if request.format.json?
      @params = params[:q]
      @q = Broadcast.accessible_by(current_ability).includes([:tags, taggings: [:tag]]).order(id: :desc).ransack(params[:q])
      @broadcasts = @q.result.page(params[:page])
    end
    respond_to do |format|
      format.html
      format.json
    end
  end

  # GET /user/broadcasts/search
  def search
    index
    render :index
  end

  # GET /user/broadcasts/:id
  def show
  end

  # GET /user/broadcasts/new
  def new
  end

  # GET /user/broadcasts/edit
  def edit
    @broadcast_id = params[:id]
  end

  # POST /user/broadcasts
  def create
    @broadcast = build_broadcast(broadcast_params)
    if @broadcast.save
      build_broadcast_messages(@broadcast, messages_params)
      dispatch_broadcast_now(@broadcast) if @broadcast.deliver_now? && !@broadcast.draft?
    else
      render_bad_request_with_message(@broadcast.error.full_messages.first)
    end
  rescue => e
    logger.error e.message
    render_bad_request
  end

  # PATCH /user/broadcasts/:id
  def update
    return render_permission_denied unless @broadcast.editable?
    @broadcast = update_broadcast(@broadcast, broadcast_params)
    if @broadcast.save
      build_broadcast_messages(@broadcast, messages_params)
      dispatch_broadcast_now(@broadcast) if @broadcast.deliver_now? && !@broadcast.draft?
    else
      render_bad_request_with_message(@broadcast.error.full_messages.first)
    end
  rescue => e
    logger.error e.message
    render_bad_request
  end

  # POST /user/broadcasts/:id/copy
  def copy
    @broadcast.clone!
    render_success
  rescue => e
    logger.error e.message
    render_bad_request
  end

  # DELETE /user/broadcasts/:id
  def destroy
    if @broadcast.destroyable? && @broadcast.destroy
      render_success
    else
      render_bad_request
    end
  end

  private
    def broadcast_params
      params.permit(
        :title,
        :type,
        :status,
        :deliver_now,
        :schedule_at,
        tag_ids: [],
        conditions: {},
      )
    end

    def messages_params
      params.require(:messages).map do |p|
        p.permit(:message_type_id, content: {}).tap do |whitelisted|
          whitelisted[:site_measurements_attributes] = []
          (p[:site_measurements_attributes] || p[:site_measurements]).to_a.each_with_index do |site_measurement, index|
            whitelisted[:site_measurements_attributes][index] = site_measurement
            whitelisted.permit!
          end
        end
      end
    end

    def find_broadcast
      @broadcast = Broadcast.find(params[:id])
    end

    def dispatch_broadcast_now(broadcast)
      DispatchBroadcastJob.perform_now(broadcast.id)
    end
end
