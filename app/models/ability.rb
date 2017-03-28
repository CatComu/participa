class Ability
  include CanCan::Ability

  def initialize(user)
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities

    user ||= User.new # guest user (not logged in)
    if user.is_admin?
      can :manage, :all
      can :manage, Notice
      can :manage, Resque
      can :manage, Report
      can :manage, ActiveAdmin
      can :admin, User
      can :admin, Microcredit
      can :admin, MicrocreditLoan
      can :admin, ImpulsaProject
      can :admin, ImpulsaEdition

      can :manage, Post

      if !user.superadmin?
        cannot :manage, Election
        cannot :manage, Notice
        cannot :manage, ReportGroup
        cannot :manage, SpamFilter
        can :read, Election
      end

      can :show, :verification
    else
      cannot :manage, :all
      cannot :manage, Resque
      cannot :manage, ActiveAdmin

      if user.finances_admin?
        can [:read], MicrocreditLoan if user.finances_admin?
        can [:read, :update], Microcredit if user.finances_admin?
      end

      if user.impulsa_admin?
        can [:show, :read], ImpulsaEdition
        can [:show, :read, :update], ImpulsaProject
      end
      
      if user.finances_admin? || user.impulsa_admin?
        can [:read, :create], ActiveAdmin::Comment
      end

      can [:show, :update], User, id: user.id
      can :show, Notice

      if !Features.online_verifications_only? || user.voting_right?
        can :index, :tools
      end

      if Features.presential_verifications?
        if user.verifying_presentially?
          can [:step1, :step2, :step3, :confirm, :search, :result_ok, :result_ko], :verification
        end

        can :show, :verification
      end

      if Features.online_verifications?
        if user.verifying_online?
          can [:show, :search, :accept, :reject, :index], :online_verifications
        end

        if user.unconfirmed_by_sms? || user.online_verification_pending?
          can [:step1, :documents], :sms_validator
        end

        if user.unconfirmed_by_sms? || user.can_change_phone?
          can [:step2, :step3, :phone, :valid], :sms_validator
        end
      end

      if Features.verifications? && user.voting_right?
        can [:create, :create_token, :check, :sms_check, :send_sms_check], :vote
      end

      cannot :admin, :all
    end

  end
end
