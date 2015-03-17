require 'test_helper'

class EmploymentsHelperTest < ActionView::TestCase

  def setup
    @controller = EmploymentsController.new
    @current_user = users(:admin)
    @june_employment = employments(:june)
    @first_half_august_employment = employments(:first_half_august)
    @second_half_august_employment = employments(:second_half_august)
    @december_open_end_employment = employments(:december_open_end)
    @current_user.employments = [@june_employment, @first_half_august_employment, @second_half_august_employment, @december_open_end_employment]
  end

  def print_employment(employments)
    result = ""
    for employment in employments
      result += "#{employment.startDate} - #{employment.endDate}\n"
    end
    return result
  end

  def assert_employments(expected_employments, result)
    assert expected_employments == result, "expected:\n#{print_employment(expected_employments)} got:\n#{print_employment(result)}"
  end

  test "filter_employments should return employment starting before range" do
    #1
    employments = @controller.filter_employments(Date.new(2014,6,15), Date.new(2014,7,15), users(:admin).employments)
    assert_employments([@june_employment], employments)
  end

  test "filter_employments should return employment ending after range" do
    #3
    employments = @controller.filter_employments(Date.new(2014,5,15), Date.new(2014,6,15), users(:admin).employments)
    assert_employments([@june_employment], employments)
  end

  test "filter_employments should return employment within range" do
    #4
    employments = @controller.filter_employments(Date.new(2014,5,15), Date.new(2014,7,15), users(:admin).employments)
    assert_employments([@june_employment], employments)
  end

  test "filter_employments should return employment around range" do
    #5
    employments = @controller.filter_employments(Date.new(2014,6,10), Date.new(2014,6,20), users(:admin).employments)
    assert_employments([@june_employment], employments)
  end

  test "filter_employments should return employments before and after range" do
    #6
    employments = @controller.filter_employments(Date.new(2014,5,15), Date.new(2014,8,15), users(:admin).employments)
    assert_employments([@june_employment, @first_half_august_employment], employments)
  end

  test "filter_employments should return employments without gaps before and after range" do
    #7
    employments = @controller.filter_employments(Date.new(2014,8,1), Date.new(2014,8,30), users(:admin).employments)
    assert_employments([@first_half_august_employment, @second_half_august_employment], employments)
  end

  test "filter_employments should return employments without end date starting before range" do
    #8
    employments = @controller.filter_employments(Date.new(2014,12,15), Date.new(2014,12,31), users(:admin).employments)
    assert_employments([@december_open_end_employment], employments)
  end

  test "filter_employments should return employments without end date starting within range" do
    #9
    employments = @controller.filter_employments(Date.new(2014,11,15), Date.new(2014,12,15), users(:admin).employments)
    assert_employments([@december_open_end_employment], employments)
  end

  test "filter_employments should return empty list without matching employments" do
    #2
    employments = @controller.filter_employments(Date.new(2013,12,1), Date.new(2013,12,31), users(:admin).employments)
    assert_employments([], employments)
  end

  test "employment_for_date should return employment for first day of employment" do
    employment = @controller.employment_for_date(Date.new(2014,6,1), users(:admin).employments)
    assert employment == @june_employment
  end

  test "employment_for_date should return employment for last day of employment" do
    employment = @controller.employment_for_date(Date.new(2014,6,30), users(:admin).employments)
    assert employment == @june_employment
  end

  test "employment_for_date should return employment for random day of employment" do
    employment = @controller.employment_for_date(Date.new(2014,6,15), users(:admin).employments)
    assert employment == @june_employment
  end

  test "employment_for_date should return nil for missing employment" do
    employment = @controller.employment_for_date(Date.new(2014,5,1), users(:admin).employments)
    assert employment == nil
  end

end
