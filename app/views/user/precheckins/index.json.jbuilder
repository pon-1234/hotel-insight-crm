# frozen_string_literal: true

json.meta do
  json.total_pages @precheckins.total_pages
  json.current_page @precheckins.current_page
  json.total_count @precheckins.total_count
  json.limit_value @precheckins.limit_value
end
json.data do
  json.array! @precheckins do |precheckin|
    json.(precheckin, :id, :name, :phone_number, :check_in_date, :check_out_date, :address, :birthdate, :companion, :gender)
  end
end
