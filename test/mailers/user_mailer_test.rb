require 'test_helper'

class UserMailerTest < ActionMailer::TestCase

  def setup
    @controller = WorkingDayValidationController.new
    ActionMailer::Base.deliveries.clear
  end

  def given_validation_user(validation_user)
    @current_user = users(validation_user)

    for user in User.all
      if user != @current_user
        user.delete
      end
    end
  end

  test "should send a mailing for day with validation error" do
    given_validation_user(:wd_validation_user)
    validation_date = Date.new(2014,12,9)
    @controller.validate_working_day(validation_date)
    mail = ActionMailer::Base.deliveries.last
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_equal 'wd_tester@brugger.eu' , mail['to'].to_s
    assert_equal "Time tracking validation failed on #{validation_date.to_formatted_s(:pretty_date)}", mail['subject'].to_s
  end

  test "should not send a mailing for day without validation error" do
    given_validation_user(:wd_validation_user)
    validation_date = Date.new(2014,12,12)
    @controller.validate_working_day(validation_date)
    mail = ActionMailer::Base.deliveries.last
    assert_nil mail
  end

  test "should not send a validation error for working day without time entries if validation is setting disabled" do
    given_validation_user(:wd_validation_user_disabled_missing_validation)
    validation_date = Date.new(2014,12,9)
    @controller.validate_working_day(validation_date)
    mail = ActionMailer::Base.deliveries.last
    assert_nil mail
  end

  test "should send a validation error mail for multiple days validation failed" do
    given_validation_user(:wd_validation_user)
    @controller.validate_working_days_for_duration(Date.new(2014,12,9), Date.new(2014,12,10))
    mail = ActionMailer::Base.deliveries.last
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_equal 'wd_tester@brugger.eu' , mail['to'].to_s
    assert_equal "Time tracking validation failed", mail['subject'].to_s
  end
end
