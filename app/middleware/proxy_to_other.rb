require 'rack/proxy'
require 'openregister'

class ProxyToOther < Rack::Proxy
  def initialize(app)
    puts "initialize: #{app}"
    @the_app = app
    puts self.object_id
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
    if path.first && path.first[/^\/school\/\d+$/]
      %w[ORIGINAL_FULLPATH
      PATH_INFO
      REQUEST_URI
      REQUEST_PATH].each do |var|
        env[var].sub!('school','schools') unless env[var][/schools/]
      end
      @the_app.call(env) + [fullpath(env)]
    elsif proxy?(env, path)
      super(env) + path
    else
      puts self.object_id
      puts "perform: #{@the_app}"
      @the_app.call(env) + path
    end
  end

  def proxy?(env, path)
    puts "path: " + path.inspect
    if path.first
      case path.first
      when /^\/schools\/\d+$/, /^\/assets\/.+$/, /^\/items$/, /^\/items.+$/
        puts 'false'
        false
      else
        true
      end
    else
      true
    end
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
      [status, headers, body]
    elsif path[/^\/schools\/\d+$/]
      [status, headers, body]
    elsif path == '/' || path[/^\/\?.+/]
      html = begin
        sio = StringIO.new( body.to_s )
        gz = Zlib::GzipReader.new( sio )
        gz.read()
      rescue Exception => e
        body.to_s
      end

      html.sub!('<strong class="phase-tag">BETA</strong>','<strong class="phase-tag" style="background:#912b88;">DISCOVERY</strong>')
      begin
        doc = Nokogiri::HTML html
        if logo = doc.at('.header-logo')
          logo.remove
        end
        if menu = doc.at('#proposition-menu')
          menu.inner_html = '<span>This is a prototype</span>'
        end
        if doc.at('.phase-banner-beta') && span = doc.at('.phase-banner-beta').at('span')
          span.remove
        end
        html = doc.to_s
        html.sub!('<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">','')
        html.strip!
      rescue Exception => e
      end
      headers["content-length"] = [html.length.to_s]
      headers.delete("content-encoding")
      [status, headers, [html] ]
    else
      [status, headers, body]
    end
  end
end
