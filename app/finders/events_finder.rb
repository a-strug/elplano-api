# frozen_string_literal: true

# EventsFinder
#
#   Used to search, filter_by, and sort the collection of student's events
#
# Arguments:
#
#   params: optional search, filter_by and sort parameters
#
# NOTE :
#
#   - by default returns events sorted by recently added.
#   - by default returns all appointed events(personal + group events).
#
class EventsFinder < Finder
  alias student context

  # @param context [Student] -
  #   A student in the scope of which filtration is performed
  #
  # @param params [Hash] - (optional, default: {}) filter_by and sort parameters
  #
  # @option params [String, Symbol] :scope -
  #   One of the events scope(appointed, authored)
  #
  # @option params [String, Symbol] :type -
  #   One of the eventable types(group, personal).
  #
  # @option params [Array<String>] :labels -
  #   Collection of the labels attached to the event
  #
  def initialize(context:, params: {})
    super
  end

  # Perform filtration and sort on student's events list
  #
  # @note by default returns all appointed events(personal + group)
  #   sorted by recently created
  #
  def execute
    perform_filtration.then(&method(:sort))
  end

  private

  def perform_filtration
    resolve_scope.then(&method(:filter_by_labels))
  end

  def resolve_scope
    filters = {
      'appointed' => filter_appointed,
      'authored' => filter_authored
    }

    filters.fetch(params[:scope]) { filter_appointed }
  end

  def filter_authored
    student.created_events.filter_by(params[:type])
  end

  def filter_appointed
    filters = {
      'group' => Event.filter_by('group')
                      .where(eventable_id: student.group_id),
      'personal' => Event.filter_by('personal')
                         .where(eventable_id: student.id)
    }

    filters.fetch(params[:type]) { filters.values.inject(&:or) }
  end

  def filter_by_labels(items)
    return items if params[:labels].blank?

    label_ids = params[:labels].split(',')

    items.joins(:labels).where(labels: { id: label_ids }).distinct
  end

  def sort(items)
    params[:sort].blank? ? items.reorder(id: :desc) : items.order_by(params[:sort])
  end
end
