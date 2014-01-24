module RightApi
  module Exceptions
    # Alias for a class that was renamed. This exists to preserve interface compatibility.
    # @deprecated do not use - will be removed in right_api_client 2.0
    ApiException = ::RightApi::ApiError

    # Alias for a class that was renamed. This exists to preserve interface compatibility.
    # @deprecated do not use - will be removed in right_api_client 2.0
    UnknownRouteException = ::RightApi::UnknownRouteError
  end
end
