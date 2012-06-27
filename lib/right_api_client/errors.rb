
module RightApi

  class ApiError < RuntimeError

    def initialize(request, response)

      @request, @response = request, response

      super(
        prefix +
        "HTTP Code: #{response.code.to_s}, " +
        "Response body: #{response.body}")
    end

    def prefix

      'Error: '
    end
  end

  class NotFoundError < ApiError

    def prefix

      path = @request.url.match(/(\/api\/.+)$/)[1]

      "Not found: #{path}. "
    end
  end

  class UnknownRouteError < ApiError

    def prefix

      'Unknown action or route. '
    end
  end
end

