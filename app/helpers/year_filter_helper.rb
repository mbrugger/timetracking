module YearFilterHelper
  def start_of_year(year)
    Date.new(year, 1, 1)
  end

  def end_of_year(year)
    Date.new(year, 12, 31)
  end
end
