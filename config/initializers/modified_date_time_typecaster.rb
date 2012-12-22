require 'active_attr'

module ActiveAttr
  module Typecasting
    class DateTimeTypecaster
      def self.with_date_format(date_format = "%Y-%m-%d %H:%M:%S")
        @@date_format = date_format

        class_eval do
          alias :old_call :call
          def call(value)
            date_time = nil
            begin
              date_time = DateTime.strptime value, @@date_format
            rescue ArgumentError
            end
            return date_time
          end
        end

        yield

        class_eval do
          alias :call :old_call
        end

      end
    end
  end
end

