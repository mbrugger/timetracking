require 'test_helper'

class DurationFormatHelperTest < ActionView::TestCase

  include DurationFormatHelper

  test "format_time should correctly format time for 0:00" do
    result = format_duration(0)
    assert result == "", "got #{result}"
  end

  test "format_time should correctly format time <24h" do
    result = format_duration(5*3600 + 21*60)
    assert result == "5:21", "got #{result}"
  end

  test "format_time should correctly format time >24h" do
    result = format_duration(154*60*60 + 15*60)
    assert result == "154:15", "got #{result}"
  end

  test "format_time should correctly format time for negative time -0:50" do
    result = format_duration(-50*60)
    assert result == "-0:50", "got #{result}"
  end

end
