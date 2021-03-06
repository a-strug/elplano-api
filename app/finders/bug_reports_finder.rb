# frozen_string_literal: true

# BugReportsFinder
#
#   Used to search, filter, and sort the collection of bugs reports
#
# Arguments:
#
#   params: optional search, filter and sort parameters
#
class BugReportsFinder < Finder
  # @param params [Hash] - (optional, default: {}) filter and sort parameters
  #
  # @option params [String, Symbol] :status
  #   One of the user status(banned, active, confirmed)
  #
  # @option params [Integer] :user_id
  #   Bug report reporter identity
  #
  def initialize(context: nil, params: {})
    super
  end

  # Perform filtration and sort on bug reports list
  #
  # @note
  #  - by default all records are sorted by recently created
  #  - be default return records by chunks(15 records per chunk)
  #
  # @return [ActiveRecord::Relation]
  #
  def execute
    filter_by_user(BugReport).then(&method(:paginate))
  end

  private

  def filter_by_user(items)
    return items if params[:user_id].blank?

    items.where(reporter_id: params[:user_id])
  end
end
