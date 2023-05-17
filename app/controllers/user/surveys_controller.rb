# frozen_string_literal: true

class User::SurveysController < User::ApplicationController
  include User::SurveysHelper

  before_action :find_survey, except: [:index, :new, :create]
  # GET /user/surveys
  def index
    if request.format.json?
      @folders = Folder.accessible_by(current_ability).includes([:surveys]).type_survey
    end
    respond_to do |format|
      format.html
      format.json
    end
  end

  # GET /user/surveys/:id
  def show
    respond_to do |format|
      format.html
      format.json
    end
  end

  # GET /user/surveys/:id/answered_users
  def answered_users
    @answered_users = @survey.answered_users.page(params[:page]).per(10)
  end

  # GET /user/surveys/:id/responses
  def responses
    @responses = Kaminari.paginate_array(@survey.responses).page(params[:page]).per(10)
  end

  # GET /user/surveys/:id/:friend_id/:responses
  def friend_responses
    @survey_id = params[:id]
    @friend_id = params[:friend_id]
    @friend = LineFriend.find(@friend_id)
    if request.format.json?
      @responses = @survey.responses_by(@friend_id)
    end
    respond_to do |format|
      format.html
      format.json
    end
  end

  # GET /user/surveys/new
  def new
    @can_sync_ggsheet = current_user.client.gauth_visible
  end

  # GET /user/surveys/:id/edit
  def edit
    @survey_id = params[:id]
    @can_sync_ggsheet = current_user.client.gauth_visible
  end

  # POST /user/surveys
  def create
    @survey = build_survey(survey_params)
    unless @survey.save(validate: !@survey.draft?)
      render_bad_request_with_message(@survey.first_error_message)
    end
  end

  # PATCH /user/surveys/:id
  def update
    @survey.assign_attributes(survey_params)
    cur_question_ids = @survey.survey_questions.pluck(:id)
    new_question_ids = survey_params[:survey_questions_attributes].pluck(:id)
    (cur_question_ids - new_question_ids).each { |i| @survey.survey_questions_attributes = { id: i, _destroy: '1' } }
    unless @survey.save(validate: !@survey.draft?)
      render_bad_request_with_message(@survey.first_error_message)
    end
  end

  # POST /user/surveys/:id/toggle_status
  def toggle_status
    @survey.toggle_status
    render_success
  end

  # POST /user/surveys/:id/copy
  def copy
    @survey.clone!
    render_success
  rescue => e
    logger.error e.message
    render_bad_request
  end

  # DELETE /user/surveys/:id
  def destroy
    @survey.destroy! if @survey.destroyable?
    render_success
  rescue
    render_bad_request
  end

  # GET /user/surveys/:id/export
  def export
    csv = Export::ExportSurveyResponseService.new convert_to_csv(@survey)
    send_data csv.perform_hash, filename: "#{@survey.title}_#{Time.zone.now.strftime('%Y%m%d%H%M')}.csv"
  end

  private
    def survey_params
      params.permit(
        :id,
        :folder_id,
        :type,
        :name,
        :banner_url,
        :title,
        :description,
        :success_message,
        :re_answer,
        :status,
        :sync_to_ggsheet,
        :google_oauth_code,
        survey_questions_attributes: [
          :id,
          :order,
          :required,
          :type,
          content: {}
        ],
        after_action: {}
      )
    end

    def find_survey
      @survey = Survey.find(params[:id])
    end
end
