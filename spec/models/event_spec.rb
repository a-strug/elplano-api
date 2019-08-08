# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Event, type: :model do
  describe 'associations' do
    it { should belong_to(:creator).class_name('Student') }

    it { should belong_to(:course).optional }

    it { should belong_to(:eventable) }
  end

  describe 'validations' do
    subject { build_stubbed(:event) }

    it { should validate_presence_of(:title) }

    it { should validate_length_of(:title).is_at_least(3).is_at_most(250) }

    it { should validate_presence_of(:creator) }

    it { should validate_presence_of(:start_at) }

    it { should validate_presence_of(:timezone) }

    it do
      should define_enum_for(:status)
               .with_values(confirmed: 'confirmed', tentative: 'tentative', cancelled: 'cancelled')
               .backed_by_column_of_type(:string)
    end
  end
end
