module RightApi
  module Exceptions
    class ApiException < RuntimeError
      def initialize(message="")
        super("Error: #{message}")
      end
    end

    class UnknownRouteException < ApiException
      def initialize(message="")
        super("Unknown action or route. #{message}")
      end
    end
  end
end
