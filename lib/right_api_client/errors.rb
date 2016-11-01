
module RightApi

  class ApiError < RuntimeError
    # Create a new ApiError. This accepts a parameter glob because this type is aliased to
    # a removed exception type that took only one initializer argument: the response object.
    # This type prefers two arguments: the request and response objects. If you pass only one
    # argument, it is taken to be the response.
    def initialize(*args)
      case args.size
      when 1
        # Compatible with RightApi::Exceptions::ApiException (from 1.5.9 of the gem)
        @request, @response = nil, args[0]
      when 2
        # Normal/preferred format
        @request, @response = args[0], args[1]
      else
        raise ArgumentError, "wrong number of arguments (#{args.size} for 1 or 2)"
      end

      super(
        prefix +
        "HTTP Code: #{@response.code.to_s}, " +
        "Response body: #{@response.body}")
    end

    def prefix

      'Error: '
    end

    # Get the HTTP response code that triggered this error.
    #
    # @return [Integer] the response code
    #
    def response_code
      @response.code
    end
  end

  class UnknownRouteError < ApiError
    def prefix
      'Unknown action or route. '
    end
  end

  class EmptyBodyError < ApiError
    def prefix
      'Empty response body: '
    end
  end
end

