# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Elplano::Redis::Queues do
  include_examples 'redis_shared_examples'
end
