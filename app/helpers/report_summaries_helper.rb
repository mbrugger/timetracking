module ReportSummariesHelper
  include ReportsHelper
  include EmploymentsHelper

  def create_report_summary(working_days, employments, reports)
    report_summary = ReportSummary.new

    if working_days.empty? || employments.empty?
      return report_summary
    end

    report_summary.expected_working_hours = calculate_expected_working_hours(working_days)
    report_summary.working_hours = calculate_working_hours(working_days)
    report_summary.comp_time = calculate_comp_time(working_days)
    report_summary.working_hours_balance = report_summary.working_hours-report_summary.expected_working_hours-report_summary.comp_time

    report_summary.total_working_hours_balance = 0
    report_summary.previous_working_hours_balance = 0
    # always add migrated employment balance
    sorted_employments = sort_employments(employments)
    if sorted_employments.first.migrated_employment?
      report_summary.previous_working_hours_balance += sorted_employments.first.working_hours_balance unless sorted_employments.first.working_hours_balance.nil?
    end

    # add all balances of previous reports
    previous_reports = previous_reports(working_days.first.date, reports)
    for report in previous_reports
      report_summary.previous_working_hours_balance += report.balance
      report_summary.previous_working_hours_balance += report.correction unless report.correction.nil?
    end
    report_summary.total_working_hours_balance += report_summary.previous_working_hours_balance
    report_summary.total_working_hours_balance += report_summary.working_hours_balance

    current_report = current_report(working_days.first.date, reports)
    if  !current_report.nil? && !current_report.correction.nil?
      report_summary.total_working_hours_balance += current_report.correction
    end

    for working_day in working_days
      if (working_day.validation_errors.size > 0)
        logger.debug "validation error on #{working_day.date} error: #{working_day.validation_errors}"
        report_summary.validation_errors = true
        break
      end
    end
    return report_summary
  end

private

  def current_report(current_report_date, reports)
    reports.select{|report| report.date == current_report_date }.first
  end

  def previous_reports(current_report_date, reports)
    reports.select{|report| report.date < current_report_date}
  end
end
