# frozen_string_literal: true

# == Schema Information
#
# Table name: reservation_precheckins
#
#  id              :bigint           not null, primary key
#  line_account_id :bigint
#  line_friend_id  :bigint
#  name            :string(255)
#  phone_number    :string(255)
#  check_in_date   :date
#  check_out_date  :date
#  address         :string(255)
#  birthdate       :string(255)
#  companion       :string(255)
#  gender          :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_reservation_precheckins_on_line_account_id  (line_account_id)
#  index_reservation_precheckins_on_line_friend_id   (line_friend_id)
#
# Foreign Keys
#
#  fk_rails_...  (line_account_id => line_accounts.id)
#  fk_rails_...  (line_friend_id => line_friends.id)
#
class ReservationPrecheckin < ApplicationRecord
  belongs_to :line_account
  belongs_to :line_friend

  ATTRIBUTES = %i[name phone_number check_in_date check_out_date address birthdate companion gender]
  validates :name, :phone_number, :check_in_date, :check_out_date, :address, :birthdate, :companion, :gender, :line_friend_id, :line_account_id, presence: true
end
