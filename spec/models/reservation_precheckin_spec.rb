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
require 'rails_helper'

RSpec.describe ReservationPrecheckin, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
