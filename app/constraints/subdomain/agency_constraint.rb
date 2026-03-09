# frozen_string_literal: true

class Subdomain::AgencyConstraint
  def matches?(request)
    if Rails.env.production?
      request.subdomain.include?('agency') || request.subdomain.blank?
    else
      request.subdomain.blank?
    end
  end

  def self.path
    'agency'
  end
end
