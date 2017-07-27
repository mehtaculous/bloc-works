module BlocWorks
  class Application
    def controller_and_action(env)
      _, controller, action, _ = env["PATH_INFO"].split("/", 4)
      controller = controller.capitalize
      controller = "#{controller}Controller"
 
      [Object.const_get(controller), action]
    end

    def fav_icon(env)
      if env['PATH_INFO'] == '/favicon.ico'
        return [404, {'Content-Type' => 'text/html'}, []]
      end
    end

    def route(&block)
      @router ||= Router.new
      @router.instance_eval(&block)
    end

    def get_rack_app(env)
      if @router.nil?
        raise "No routes defined"
      end
 
      @router.look_up_url(env["PATH_INFO"], env["REQUEST_METHOD"])
    end
  end

  class Router
    def initialize
      @rules = []
    end
 
    def map(url, *args)
      options = options_setter(args)
      destination = destination_setter(args)
 
      parts = url.split("/")
      parts.reject! { |part| part.empty? }

      vars, regex_parts = parts_handler(parts)
 
      regex = regex_parts.join("/")
      @rules.push({ regex: Regexp.new("^/#{regex}$"), vars: vars, destination: destination, options: options })
    end

    def options_setter(args)
      options = {}
      options = args.pop if args[-1].is_a?(Hash)
      options[:default] ||= {}
      options
    end

    def destination_setter(args)
      destination = nil
      destination = args.pop if args.size > 0
      raise "Too many args!" if args.size > 0
      return destination
    end

    def parts_handler(parts)
      vars, regex_parts = [], []
      parts.each do |part|
        case part[0]
        when ":"
          vars << part[1..-1]
          regex_parts << "([a-zA-Z0-9]+)"
        when "*"
          vars << part[1..-1]
          regex_parts << "(.*)"
        else
          regex_parts << part
        end
      end

      return vars, regex_parts
    end

    def look_up_url(url, request_method)
      @rules.each do |rule|
        rule_match = rule[:regex].match(url)
        request_match = rule[:options][:default][:request_method].match(request_method)
        if rule_match && request_match
          params = set_params(rule, rule_match)
          return set_destination(rule, params)
        end
      end

      proc { |env| [404, {}, [""]] }
    end

    def set_params(rule, rule_match)
      options = rule[:options]
      params = options[:default].dup

      rule[:vars].each_with_index do |var, index|
        params[var] = rule_match.captures[index]
      end

      return params
    end

    def set_destination(rule, params)
      if rule[:destination]
        return get_destination(rule[:destination], params)
      else
        controller = params["controller"]
        action = params["action"]
        return get_destination("#{controller}##{action}", params)
      end
    end
 
    def get_destination(destination, routing_params={})
      if destination.respond_to?(:call)
        return destination
      end
 
      if destination =~ /^([^#]+)#([^#]+)$/
        name = $1.capitalize
        controller = Object.const_get("#{name}Controller")
        return controller.action($2, routing_params)
      end
      raise "Destination not found: #{destination}"
    end

    def resources(controller)
      map ":controller",          default: {"action" => "index", :request_method => "GET"}
      map ":controller/new",      default: {"action" => "new", :request_method => "GET"}
      map ":controller/:id/edit", default: {"action" => "edit", :request_method => "GET"}
      map ":controller/:id",      default: {"action" => "show", :request_method => "GET"}
      map ":controller",          default: {"action" => "create", :request_method => "PUT"}
      map ":controller/:id",      default: {"action" => "update", :request_method => "POST"}
      map ":controller/:id",      default: {"action" => "destroy", :request_method => "DELETE"}
    end
  end
end