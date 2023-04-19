# frozen_string_literal: true

module SurveysHelper
  def build_answer(survey, params, precheckin_id = nil)
    friend = LineFriend.find_by(line_user_id: params[:friend_id])
    old_response = SurveyResponse.find_by(survey: survey, line_friend: friend)
    if old_response.present? && !survey.re_answer?
      return raise 'You are already responsed!'
    end
    # Create a new response
    response = SurveyResponse.new(survey: survey, line_friend: friend)
    response.answer_count = 1
    response.reservation_precheckin_id = precheckin_id
    response.save!

    answer_params = params[:answers]
    answer_params.each do |k, answer|
      survey_answer = SurveyAnswer.new(survey_response: response)
      survey_answer.survey_question_id = answer[:id]
      question = SurveyQuestion.find(survey_answer.survey_question_id)

      if question.file?
        survey_answer.file = answer[:answer]
      else
        survey_answer.answer = answer[:answer]
      end
      survey_answer.save!

      variable = question.content['variable']
      assign_variable(friend, variable['id'], survey_answer) if variable.present? && variable['id'].present?
    end
    AfterAnsweredSurveyJob.perform_later(response.id)
  end

  def update_answer(survey, survey_answers, params)
    friend = LineFriend.find_by(line_user_id: params[:friend_id])
    old_response = SurveyResponse.find_by(survey: survey, line_friend: friend)
    if old_response.present? && !survey.re_answer?
      return raise 'You are already responsed!'
    end
    response = SurveyResponse.find_by(survey_id: survey.id, line_friend_id: friend.id)

    answer_params = params[:answers]
    survey_answers.each_with_index do |survey_answer, index|
      question = SurveyQuestion.find(survey_answer.survey_question_id)

      ans = answer_params[(index+1).to_s][:answer]
      if question.file? && ans.present?
        survey_answer.file.purge
        survey_answer.file = ans
      else
        survey_answer.answer = ans
      end
      survey_answer.save!

      variable = question.content['variable']
      assign_variable(friend, variable['id'], survey_answer) if variable.present? && variable['id'].present?
    end
    AfterAnsweredSurveyJob.perform_later(response.id)
  end

  private
    def assign_variable(friend, variable_id, answer)
      variable = Variable.find(variable_id)
      friend_variable = FriendVariable.find_or_initialize_by(line_friend: friend, variable_id: variable_id, survey_answer_id: answer.id)
      if answer.survey_question.file?
        friend_variable.value = rails_blob_url(answer.file) if answer.file.attached?
      else
        # If answer is empty, set value to variable's default value
        if answer.answer.empty?
          friend_variable.value = variable.default_value(friend)
        else
          friend_variable.value = answer.answer
        end
      end
      friend_variable.save!
      # Reset variable's friends counter
      variable.refresh_friends_count
    end
end
