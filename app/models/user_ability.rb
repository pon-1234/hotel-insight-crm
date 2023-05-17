# frozen_string_literal: true

class UserAbility
  include CanCan::Ability

  def initialize(user)
    if user.staff?
      can :read, LineFriend, { line_account: user.line_account, channel: { assignee_id: user.id } }
      can :manage, Channel, { line_account: user.line_account, assignee_id: user.id }
      can :read, Scenario, line_account: user.line_account
      can :read, Template, line_account: user.line_account
      can :create, Media
      can :read, Media, line_account: user.line_account
      can :read, Folder, line_account: user.line_account
    elsif user.admin?
      # Friend
      can [:manage], LineFriend, line_account: user.line_account

      return unless user.admin?
      can :manage, User, line_account: user.line_account

      # Broadcast
      can [:manage], Broadcast, line_account: user.line_account
      can [:create], Broadcast

      # Template
      can [:manage], Template, line_account: user.line_account
      can [:create], Template

      # Scenario
      can [:manage], Scenario, line_account: user.line_account
      can [:create], Scenario

      # Auto Response
      can [:manage], AutoResponse, line_account: user.line_account
      can [:create], AutoResponse

      # Channel
      can [:read, :create, :update], Channel, line_account: user.line_account
      can :create_message, Channel, { line_account: user.line_account, locked: false }

      # RichMenu
      can [:manage], RichMenu, line_account: user.line_account
      can [:create], RichMenu

      # Media
      can [:manage], Media, line_account: user.line_account
      can [:create], Media

      # Friend
      can [:manage], LineFriend, line_account: user.line_account

      # Folder
      can [:manage], Folder, line_account: user.line_account
      can [:create], Folder

      # Tag
      can [:manage], Tag, folder: { line_account: user.line_account }
      can [:create], Tag

      # Reminder
      can [:manage], Reminder, folder: { line_account: user.line_account }
      can [:create], Reminder
      can [:manage], Episode, reminder: { line_account: user.line_account }
      can [:create], Episode

      # Reservations
      can :manage, Reservation, line_account: user.line_account
      can :manage, ReservationPrecheckin, line_account: user.line_account

      # Reviews
      can :manage, Review, client: user.client
    end
  end
end
