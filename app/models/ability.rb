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

      can [:read], MicrocreditLoan if user.finances_admin?
      can [:read, :update], Microcredit if user.finances_admin?

      can [:show, :read], ImpulsaEdition if user.impulsa_admin?
      can [:show, :read, :update], ImpulsaProject if user.impulsa_admin?
      
      can [:read, :create], ActiveAdmin::Comment if user.finances_admin? || user.impulsa_admin?

      can [:show, :update], User, id: user.id
      can :show, Notice

      if Features.presential_verifications?
        can [:step1, :step2, :step3, :confirm, :search, :result_ok, :result_ko], :verification if user.verifying_presentially?
        can :show, :verification
      end

      if Features.online_verifications?
        can [:step1, :step2, :step3, :phone, :documents, :valid], :sms_validator
      end

      if Features.verifications?
        can [:create, :create_token, :check], :vote if user.is_verified?
      end

      cannot :admin, :all
    end

  end
end
