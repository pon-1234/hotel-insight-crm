# frozen_string_literal: true

class User::PrecheckinsController < User::ApplicationController
  # GET /user/precheckins
  def index
    if request.format.json?
      @params = params[:q]
      @q = ReservationPrecheckin.accessible_by(current_ability).order(created_at: :desc).ransack(params[:q])
      @precheckins = @q.result.page(params[:page])
    end
    respond_to do |format|
      format.html
      format.json
    end
  end
end
