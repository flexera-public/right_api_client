
module RightApi
  module Exceptions

    class ApiException < RuntimeError

      def initialize(response)

        super(
          prefix +
          "HTTP Code: #{response.code.to_s}, " +
          "Response body: #{response.body}")
      end

      def prefix

        'Error: '
      end
    end

    class UnknownRouteException < ApiException

      def prefix

        'Unknown action or route. '
      end
    end
  end
end
