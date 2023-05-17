# frozen_string_literal: true

json.array! @folders do |folder|
  json.(folder, :id, :name)
  json.surveys do
    json.array! folder.surveys do |survey|
      json.(survey, :id, :folder_id, :type, :name, :banner_url, :status)
      json.ggsheet_url "https://docs.google.com/spreadsheets/d/#{survey.spreadsheet_id}" if survey.connected_to_ggsheet? && survey.spreadsheet_id.present?
      json.responses_count survey.responses_count
      json.users_count survey.users_count
      json.created_at survey.created_at.strftime('%Y-%m-%d %H:%M')
      json.destroyable survey.destroyable?
      json.editable survey.editable?
    end
  end
end
