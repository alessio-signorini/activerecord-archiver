module ActiveRecord
  module Archiver
    module Logger

      def self.init logger
        @logger = logger
      end

      def self.debug message
        if @logger
          @logger.debug(format_message(message))
        end
      end

      def self.info message
        if @logger
          @logger.info(format_message(message))
        end
      end

      def self.warn message
        if @logger
          @logger.warn(format_message(message))
        end
      end

      def self.error message
        if @logger
          @logger.error(format_message(message))
        end
      end

      def self.fatal message
        if @logger
          @logger.fatal(format_message(message))
        end
      end

      def self.unknown message
        if @logger
          @logger.unknown(format_message(message))
        end
      end

      def self.format_message message
        "[ActiveRecord::Archiver] #{message}"
      end
    end
  end
end