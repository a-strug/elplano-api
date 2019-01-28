# frozen_string_literal: true

FactoryBot.define do
  factory :event, class: Event do
    title     { Faker::Lorem.sentence }
    timezone  { 'Etc/GMT+12' }
    start_at  { Faker::Date.forward(1) }

    creator
  end

  factory :event_params, class: Hash do
    initialize_with do
      {
        type: 'event',
        attributes: {
          title: Faker::Lorem.sentence(3),
          description: Faker::Lorem.paragraph(5),
          start_at: Faker::Date.backward(1),
          end_at: Faker::Date.forward(1),
          timezone: 'Etc/GMT+12',
          recurrence: [
            'EXDATE;VALUE=DATE:20150610',
            'RDATE;VALUE=DATE:20150609,20150611',
            'RRULE:FREQ=DAILY;UNTIL=20150628;INTERVAL=3'
          ]
        }
      }
    end
  end
end