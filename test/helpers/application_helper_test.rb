require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase

  include ApplicationHelper

  test 'parse -0:10 should return correct value' do
    assert_duration(-10.minutes, parse_duration('-0:10'))
  end

  test 'parse 0:10 should return correct value' do
    assert_duration(10.minutes, parse_duration('0:10'))
  end

  test 'parse 1:10 should return correct value' do
    assert_duration(1.hour+10.minutes, parse_duration('1:10'))
  end

  test 'parse -1:10 should return correct value' do
    assert_duration(-1.hour-10.minutes, parse_duration('-1:10'))
  end

end
