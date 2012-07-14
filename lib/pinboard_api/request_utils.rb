module PinboardApi
  module RequestUtils
    def self.included(receiver)
      receiver.extend ClassMethods
    end

    def yes_no(value)
      return nil if value.nil?
      value ? "yes" : "no"
    end

    module ClassMethods
      def tag_param_string(tags)
        tags.nil? ? nil : Array.wrap(tags).join(",")
      end

      def dt_param_string(time)
        time.nil? ? nil : time.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
      end
    end
  end
end
