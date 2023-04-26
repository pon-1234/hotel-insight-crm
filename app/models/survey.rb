# frozen_string_literal: true

# == Schema Information
#
# Table name: surveys
#
#  id                   :bigint           not null, primary key
#  line_account_id      :bigint
#  folder_id            :bigint
#  type                 :string(255)      default("normal")
#  code                 :string(255)
#  name                 :string(255)
#  banner_url           :string(255)
#  liff_id              :string(255)
#  title                :string(255)
#  description          :text(65535)
#  after_action         :json
#  success_message      :text(65535)
#  status               :string(255)      default(NULL)
#  re_answer            :boolean          default(FALSE)
#  connected_to_ggsheet :boolean          default(FALSE)
#  google_oauth_code    :string(255)
#  google_oauth_tokens  :json
#  google_oauth_email   :string(255)
#  spreadsheet_id       :string(255)
#  sync_to_ggsheet      :boolean          default(FALSE)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  deleted_at           :datetime
#
# Indexes
#
#  index_surveys_on_folder_id        (folder_id)
#  index_surveys_on_line_account_id  (line_account_id)
#
# Foreign Keys
#
#  fk_rails_...  (folder_id => folders.id)
#  fk_rails_...  (line_account_id => line_accounts.id)
#

require 'google/apis/sheets_v4'

class Survey < ApplicationRecord
  default_scope { order(created_at: :desc) }
  belongs_to :line_account
  belongs_to :folder
  has_many :survey_responses
  has_many :survey_questions, dependent: :destroy
  accepts_nested_attributes_for :survey_questions, allow_destroy: true

  # Validation
  validates :name, presence: true, length: { maximum: 255 }
  validates :title, presence: true, length: { maximum: 255 }
  validates :description, presence: true

  # Scope
  enum status: { published: 'published', unpublished: 'unpublished', draft: 'draft' }

  before_create do
    self.code = generate_code
  end

  after_save_commit :get_google_service_tokens, if: -> { sync_to_ggsheet? and !connected_to_ggsheet? }

  def destroyable?
    self.survey_responses.count == 0
  end

  def editable?
    self.survey_responses.count == 0
  end

  def responses_count
    survey_responses.count
  end

  def users_count
    survey_responses.pluck(:line_friend_id).uniq.size
  end

  def answered_users
    LineFriend.distinct.joins(:survey_responses)
      .references(:survey_responses)
      .where('survey_responses.line_friend_id = line_friends.id AND survey_responses.survey_id = ?', self.id)
  end

  def responses
    self.survey_responses.includes([:line_friend, survey_answers: [:survey_question, file_attachment: [:blob]]])
  end

  def responses_by(friend_id)
    self.survey_responses.where('survey_responses.line_friend_id = ?', friend_id).includes([:line_friend, survey_answers: [:survey_question, file_attachment: [:blob]]])
  end

  def clone!
    new_survey = self.dup
    new_survey.connected_to_ggsheet = false
    new_survey.google_oauth_code = ''
    new_survey.name = self.name + '（コピー）'
    new_survey.status = :draft
    new_survey.save!
    self.survey_questions&.each { |question| question.clone_to!(new_survey.id) }
    new_survey
  end

  def toggle_status
    self.status = self.published? ? 'unpublished' : 'published'
    self.save
  end

  def google_oauth_access_token
    GoogleApi::RefreshAccessToken.new.perform(self.google_oauth_tokens['refresh_token']) rescue nil
  end

  def get_google_service_tokens
    return if self.google_oauth_code.blank? || !self.published?
    ConnectGoogleSheetJob.perform_later(self.id)
  end

  private
    def generate_code
      loop do
        code = Devise.friendly_token(10)
        break code unless Survey.where(code: code).first
      end
    end
end
