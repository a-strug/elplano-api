# frozen_string_literal: true

module Elplano
  module Loggers
    # Elplano::Loggers::AppLogger
    #
    #   Logger for the application events
    #
    class AppLogger < ::Elplano::Logger
      class << self
        attr_writer :file_name_noext

        def file_name_noext
          @file_name_noext || 'application'
        end
      end

      def format_message(severity, timestamp, progname, msg)
        "#{severity} -- [#{timestamp.to_s(:long)}] : #{msg}\n"
      end
    end
  end
end
