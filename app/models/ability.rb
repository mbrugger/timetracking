class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
      #user ||= User.new # guest user (not logged in)
      if user == nil
        #guest user currently is not allowed to do anything
      elsif user.admin?
        #log.debug "user is admin"
        can :content, Report
        can :manage, :all
      else
        #log.debug "default user"
        can :content, Report, :user_id => user.id
        can :manage, TimeEntry, :user_id => user.id
        can :show, User, :id => user.id
        can :manage, LeaveDay, :user_id => user.id
        can :read, Report, :user_id => user.id
        can :current, Report, :user_id => user.id
        can :read, Employment, :user_id => user.id
        can :my, User
        can :home, :index
      end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
