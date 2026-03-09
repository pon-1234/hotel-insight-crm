# frozen_string_literal: true

class Subdomain::AdminConstraint
  def matches?(request)
    if Rails.env.production?
      request.subdomain.include?('admin') || request.subdomain.blank?
    else
      request.subdomain.blank?
    end
  end

  def self.path
    'admin'
  end
end
