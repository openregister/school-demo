require 'rack/proxy'

class ProxyToOther < Rack::Proxy
  def initialize(app)
    @app = app
    super(streaming: true, read_timeout: 2000)
  end

  def perform_request(env)
    # call super if we want to proxy, otherwise just handle regularly via call
    if proxy?(env)
      super(env)
    else
      @app.call(env)
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

  def rewrite_response(triplet)
    status, headers, body = triplet
    triplet
  end
end
