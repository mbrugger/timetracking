require 'test_helper'

class UserMailerTest < ActionMailer::TestCase

  def setup
    @controller = WorkingDayValidationController.new
    @current_user = users(:wd_validation_user)

    for user in User.all
      if user != @current_user
        user.delete
      end
    end
    ActionMailer::Base.deliveries.clear
  end

  test "should send a mailing for day with validation error" do
    validation_date = Date.new(2014,12,9)
    @controller.validate_working_day(validation_date)
    mail = ActionMailer::Base.deliveries.last
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_equal 'wd_tester@brugger.eu' , mail['to'].to_s
    assert_equal "Time tracking validation failed on #{validation_date.to_formatted_s(:pretty_date)}", mail['subject'].to_s
  end

  test "should not send a mailing for day without validation error" do
    validation_date = Date.new(2014,12,12)
    @controller.validate_working_day(validation_date)
    mail = ActionMailer::Base.deliveries.last
    assert_nil mail
  end
end
