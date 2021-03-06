# frozen_string_literal: true

module Elplano
  module HealthChecks
    module Redis
      # Elplano::HealthChecks::Redis::QueuesCheck
      #
      #   Used to check redis health for Queues
      #
      class QueuesCheck
        extend AbstractCheck

        class << self
          def check_up
            check
          end

          private

          def metric_prefix
            'redis_queues_ping'
          end

          def successful?(result)
            result == 'PONG'
          end

          def check
            catch_timeout(DEFAULT_TIMEOUT) { Elplano::Redis::Queues.with(&:ping) }
          end
        end
      end
    end
  end
end
