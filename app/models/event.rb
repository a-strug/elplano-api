# frozen_string_literal: true

# Event
#
#   Represents eny event in curriculum.
#   It can be a scheduled lesson or a one-time event.
#
#   "confirmed" - The event is confirmed. This is the default status.
#   "tentative" - The event is tentatively confirmed.
#   "cancelled" - The event is cancelled (deleted).
#
# Recurrence rule
#
#   The schedule for a recurring event is defined in two parts:
#
#     - Its start and end fields (which define the first occurrence,
#       as if this were just a stand-alone single event)
#
#     - Its recurrence field (which defines how the event should be repeated over time).
#
#   The recurrence field contains an array of strings representing one or several
#   RRULE, RDATE or EXDATE properties as defined in RFC 5545.(https://tools.ietf.org/html/rfc5545)
#
#   The RRULE property is the most important as it defines a regular rule for repeating the event.
#   It is composed of several components. Some of them are:
#
#     FREQ - The frequency with which the event should be repeated
#            (such as DAILY or WEEKLY). Required.
#
#     INTERVAL - Works together with FREQ to specify how often the event should be repeated.
#                For example, FREQ=DAILY;INTERVAL=2 means once every two days.
#
#     COUNT - Number of times this event should be repeated.
#
#     *** You can use either COUNT or UNTIL to specify the end of the event recurrence. Don't use both in the same rule. ***
#
#     UNTIL - The date or date-time until which the event should be repeated (inclusive).
#
#     BYDAY - Days of the week on which the event should be repeated (SU, MO, TU, etc.).
#             Other similar components include BYMONTH, BYYEARDAY, and BYHOUR.
#
#   The RDATE property specifies additional dates or date-times when the event occurrences should happen.
#   For example, RDATE;VALUE=DATE:19970101,19970120.
#   Use this to add extra occurrences not covered by the RRULE.
#
#   The EXDATE property is similar to RDATE, but specifies dates or date-times when the event should not happen.
#   That is, those occurrences should be excluded. This must point to a valid instance generated by the recurrence rule.
#
#   EXDATE and RDATE can have a time zone, and must be dates (not date-times) for all-day events.
#
#   Each of the properties may occur within the recurrence field multiple times.
#   The recurrence is defined as the union of all RRULE and RDATE rules, minus the ones excluded by all EXDATE rules.
#
# Example :
#
#   1. An all-day event starting on June 1st, 2015 and
#       repeating every 3 days throughout the month,
#       excluding June 10th but including June 9th and 11th:
#
#         start_at: '2015-06-01'
#         end_at: '2015-06-02'
#         recurrence: [
#           'EXDATE;VALUE=DATE:20150610',
#           'RDATE;VALUE=DATE:20150609,20150611',
#           'RRULE:FREQ=DAILY;UNTIL=20150628;INTERVAL=3'
#         ]
#
#   2. An event that happens from 6am until 7am every Tuesday and Friday
#       starting from September 15th, 2015 and
#       stopping after the fifth occurrence on September 29th:
#
#         start_at: '2015-09-15T06:00:00+02:00'
#         end_at: '2015-09-15T07:00:00+02:00'
#         recurrence: ['RRULE:FREQ=WEEKLY;COUNT=5;BYDAY=TU,FR']
#
class Event < ApplicationRecord
  enum status: {
    confirmed: 'confirmed',
    tentative: 'tentative',
    cancelled: 'cancelled'
  }

  belongs_to :creator, class_name: 'Student', inverse_of: :created_events

  validates :creator, :start_at, :timezone, presence: true
  validates :title, presence: true, length: { in: 3..250 }

  validates :timezone, timezone_existence: true
end
