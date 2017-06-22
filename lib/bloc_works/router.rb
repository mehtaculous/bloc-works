module BlocWorks
  class Application
    def controller_and_action(env)
      _, controller, action, _ = env["PATH_INFO"].split("/", 4)
      controller = controller.capitalize
      controller = "#{controller}Controller"
 
      [Object.const_get(controller), action]
    end

    # controller_class, action_name = controller_and_action(env)

    def fav_icon(env)
      if env['PATH_INFO'] == '/favicon.ico'
        return [404, {'Content-Type' => 'text/html'}, ["No favicon found"]]
      end
    end
  end
end