# frozen_string_literal: true

class Subdomain::UserConstraint
  def matches?(request)
    if Rails.env.production?
      request.subdomain.include?('user') || request.subdomain.blank?
    else
      request.subdomain.blank?
    end
  end

  def self.path
    'user'
  end
end
