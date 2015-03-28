class Ability
  include CanCan::Ability

  def initialize(user)
      if user == nil
        #guest user currently is not allowed to do anything
      elsif user.admin?
        can :content, Report
        can :manage, :all
      else
        can :content, Report, user_id: user.id
        can :manage, TimeEntry, user_id: user.id
        can :show, User, id: user.id
        can :manage, LeaveDay, user_id: user.id
        can :read, Report, user_id: user.id
        can :current, Report, user_id: user.id
        can :read, Employment, user_id: user.id
        can :home, :index
      end
  end
end
