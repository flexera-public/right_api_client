# This gem is versioned with the usual X.Y.Z notation, where X.Y is the API version, and Z is the client version.
module RightApi
  class Client
    VERSION        = File.read(File.expand_path('../../../VERSION', __FILE__)).strip
    API_VERSION    = "1.5"
    CLIENT_VERSION = VERSION.split('.')[1..-1].join('.')
  end
end
