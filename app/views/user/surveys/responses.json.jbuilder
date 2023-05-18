# frozen_string_literal: true

json.meta do
  json.total_pages @responses.total_pages
  json.current_page @responses.current_page
  json.total_count @responses.total_count
  json.limit_value @responses.limit_value
end

json.data do
  json.array! @responses do |response|
    json.id response.id
    json.created_at response.created_at
    json.line_friend do
      json.(response.line_friend, :display_name, :avatar_url)
    end
    json.survey_answers do
      json.array! response.survey_answers.empty? ? SurveyResponse.find_by(response.slice(:survey_id, :reservation_precheckin_id)).survey_answers : response.survey_answers do |survey_answer|
        json.id survey_answer.id
        if survey_answer.survey_question.file?
          json.file_url survey_answer.file_url
        else
          json.answer survey_answer.answer
        end
        json.survey_question do
          json.type survey_answer.survey_question.type
          json.content survey_answer.survey_question.content
        end
      end
    end
  end
end
