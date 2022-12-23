# frozen_string_literal: true

# == Schema Information
#
# Table name: line_friends
#
#  id               :bigint           not null, primary key
#  line_account_id  :bigint
#  line_picture_url :string(255)
#  line_user_id     :string(255)
#  line_name        :string(255)
#  display_name     :string(255)
#  status           :string(255)      default("active")
#  locked           :boolean          default(FALSE)
#  visible          :boolean          default(TRUE)
#  note             :text(65535)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  deleted_at       :datetime
#  tester           :boolean          default(FALSE)
#  stream_route_id  :bigint
#
# Indexes
#
#  index_line_friends_on_line_account_id  (line_account_id)
#  index_line_friends_on_stream_route_id  (stream_route_id)
#  index_line_friends_on_tester           (tester)
#
# Foreign Keys
#
#  fk_rails_...  (line_account_id => line_accounts.id)
#  fk_rails_...  (stream_route_id => stream_routes.id)
#
class LineFriend < ApplicationRecord
  belongs_to :line_account
  belongs_to :stream_route, optional: true
  has_one :channel
  has_many :taggings, as: :taggable
  has_many :tags, through: :taggings
  has_many :messages, as: :sender
  has_many :survey_responses
  has_many :friend_variables
  has_many :reservations
  has_many :pms_reservations, dependent: :destroy

  # Validations
  validates :display_name, allow_nil: true, length: { maximum: 255 }
  validates :line_name, allow_nil: true, length: { maximum: 255 }
  validates :note, allow_nil: true, length: { maximum: 2000 }

  # Scope
  enum status: { active: 'active', blocked: 'blocked' }
  scope :created_at_gteq, ->(date_str) { where('line_friends.created_at >= ?', date_str&.to_date&.beginning_of_day) }
  scope :created_at_lteq, ->(date_str) { where('line_friends.created_at <= ?', date_str&.to_date&.end_of_day) }
  scope :by_ids, ->(ids) { where(id: ids) }
  scope :is_tester, -> { where(tester: true) }

  after_create_commit :exec_after_create_commit
  after_update :exec_after_unblock

  def self.find_all_by_tags(line_account_id, tag_ids)
    LineAccount.find(line_account_id).line_friends.joins(:tags).references(:tags).where(tags: { id: tag_ids })
  end

  def push_event_data
    {
      id: id,
      name: name,
      display_name: display_name,
      avatar_url: line_picture_url,
      type: 'friend',
      note: note,
      locked: locked,
      created_at: created_at,
      tags: self.tags.select(:id, :name)
    }
  end

  def name
    self.display_name.present? ? self.display_name : self.line_name
  end

  def avatar_url
    line_picture_url
  end

  def toggle_locked
    self.locked = !self.locked
    self.save!
    self.channel.locked = self.locked
    self.channel.save!
  end

  def toggle_visible
    self.visible = !self.visible
    self.save!
  end

  # Available scenarios that can be sent by configs (on chat, postback action...)
  def manual_scenarios
    all = Scenario.manual.includes([:tags, :taggings]).enabled.not_empty.where(line_account_id: self.line_account_id)
    without_tag = all.select { |_| _.tags.blank? }
    with_tag = all.joins(:tags).references(:tags).where(tags: { id: self.tag_ids })
    (without_tag + with_tag).sort_by { |scenario| -scenario.id }
  end

  # Available scenarios that will be sent after making friend
  def auto_scenarios
    all = Scenario.auto.includes([:tags, :taggings]).enabled.not_empty.where(line_account_id: self.line_account_id)
    without_tag = all.select { |_| _.tags.blank? }
    with_tag = all.joins(:tags).references(:tags).where(tags: { id: self.tag_ids })
    without_tag + with_tag
  end

  def set_reminder!(reminder_id, goal)
    reminder = Reminder.find(reminder_id)
    # Cancel all active reminding
    active_remindings = reminder.remindings.where("remindings.channel_id = ? AND remindings.status = 'active'", self.channel.id)
    active_remindings.each { |_| _.cancel }
    reminding = Reminding.new(channel: self.channel, reminder_id: reminder_id, goal: goal)
    reminding.save!
    reminding
  end

  def send_suitable_rich_menu
    RichMenu.target_condition.where(status: :enabled, line_account_id: line_account.id).sort_by(&:updated_at)&.each do |rich_menu|
      tag_condition = rich_menu.conditions.detect { |condition| condition['type'].eql?('tag') }
      tag_ids = tag_condition['data']['tags'].pluck('id')
      if (tag_ids & self.tags.pluck(:id)).any?
        unless LineApi::BulkLinkRichMenus.new(line_account).perform([self.line_user_id], rich_menu.line_menu_id)
          rich_menu.logs = 'Could not bulk link rich menu'
          rich_menu.status = :error
        end
        return
      end
    end

    # If no suitable rich menus was set, unlink all rich menus
    LineApi::BulkUnlinkRichMenus.new(line_account).perform([self.line_user_id])
  end

  def variables
    FriendVariable.find_by_sql(['
      WITH rfv AS (
      SELECT
        fv.*, ROW_NUMBER() OVER (PARTITION BY variable_id, line_friend_id
      ORDER BY
        id DESC) AS rn
      FROM
        friend_variables AS fv )
      SELECT
        variables.name AS name,
        rfv.value AS value,
        variables.type AS type
      FROM
        variables
      LEFT JOIN rfv ON
        variables .id = rfv.variable_id
        AND rn = 1
        AND rfv.line_friend_id = ?
      WHERE variables.line_account_id = ?
    ', self.id, self.line_account_id]).map { |_| _.attributes }
  end

  def responses_count_for(survey_id)
    self.survey_responses.where(survey_id: survey_id).count
  end

  def is_changed_before?
    updated_at != created_at
  end

  private
    def exec_after_create_commit
      AcquireFriendJob.perform_later(self.id)
    end

    def exec_after_unblock
      if saved_change_to_attribute?(:status) && self.active?
        AcquireFriendJob.perform_later(self.id)
        send_suitable_rich_menu
      end
    end
end
