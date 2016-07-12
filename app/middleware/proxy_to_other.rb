require 'rack/proxy'
require 'openregister'

class ProxyToOther < Rack::Proxy
  def initialize(app)
    @app = app
    super(streaming: true, read_timeout: 2000)
  end

  def fullpath(env)
    request = Rack::Request.new(env)
    if request.fullpath == ""
      URI.parse(env['REQUEST_URI']).request_uri
    else
      request.fullpath
    end
  end

  def perform_request(env)
    # call super if we want to proxy, otherwise just handle regularly via call
    path = [fullpath(env)]
    if proxy?(env)
      super(env) + path
    else
      @app.call(env) + path
    end
  end

  def proxy?(env)
    # do not alter env here, but return true if you want to proxy for this request.
    return true
  end

  def rewrite_env(env)
    env["HTTP_HOST"] = "www.compare-school-performance.service.gov.uk"
    env["SERVER_PORT"] = "443"
    env["SERVER_NAME"] = "www.compare-school-performance.service.gov.uk"
    env["rack.url_scheme"] = 'https'
    env
  end

  def rewrite_response(triplet_path)
    status, headers, body, path = triplet_path
    if path[/^\/school\/\d+$/]
      sio = StringIO.new( body.to_s )
      gz = Zlib::GzipReader.new( sio )
      html = gz.read()
      modifier = ModifySchoolHtml.new(html)
      modified = modifier.modify
      # byebug
      headers["content-length"] = [modified.length.to_s]
      headers.delete("content-encoding")
      [status, headers, [modified] ]
    else
      [status, headers, body]
    end
  end
end
