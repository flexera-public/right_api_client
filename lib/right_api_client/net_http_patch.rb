#

require 'net/http'
require 'net/protocol'
require 'uri'

# This monkeypatches the 1.8.7 version of http to have a timeout on the 
# s.connect call, which performs the SSL handshake.  Otherwise high
# packetloss during the handshake can cause a failure and the process to wait 
# forever if the servers FIN packet is lost as well. 
# Note that ruby 1.9.x has this timeout already in there.
if RUBY_VERSION == "1.8.7" && RUBY_PLATFORM =~ /linux|arch|darwin/i
  module Net   #:nodoc:
    class HTTP < Protocol

      def connect
        D "opening connection to #{conn_address()}..."
        s = timeout(@open_timeout) { TCPSocket.open(conn_address(), conn_port()) }
        D "opened"
        if use_ssl?
          unless @ssl_context.verify_mode
            warn "warning: peer certificate won't be verified in this SSL session"
            @ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
          end
          s = OpenSSL::SSL::SSLSocket.new(s, @ssl_context)
          s.sync_close = true
        end
        @socket = BufferedIO.new(s)
        @socket.read_timeout = @read_timeout
        @socket.debug_output = @debug_output
        if use_ssl?
          if proxy?
            @socket.writeline sprintf('CONNECT %s:%s HTTP/%s',
                                      @address, @port, HTTPVersion)
            @socket.writeline "Host: #{@address}:#{@port}"
            if proxy_user
              credential = ["#{proxy_user}:#{proxy_pass}"].pack('m')
              credential.delete!("\r\n")
              @socket.writeline "Proxy-Authorization: Basic #{credential}"
            end
            @socket.writeline ''
            HTTPResponse.read_new(@socket).value
          end
          timeout(@open_timeout) { s.connect }
          if @ssl_context.verify_mode != OpenSSL::SSL::VERIFY_NONE
            s.post_connection_check(@address)
          end
        end
        on_connect
      end
      private :connect
    end
  end
end
