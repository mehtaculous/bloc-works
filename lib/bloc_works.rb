require "bloc_works/version"
require "bloc_works/dependencies"
require "bloc_works/controller"
require "bloc_works/router"
require "bloc_works/utility"

module BlocWorks
  class Application
    def call(env)
      if env['PATH_INFO'] != '/favicon.ico'
        controller_class, action_name = controller_and_action(env)
        if !controller_class.nil?
          controller = controller_class.new(env)

          if controller.respond_to?(action_name)
            body = controller.send(action_name)
            return [200, {'Content-Type' => 'text/html'}, [body]]
          end
        end
      end

      return [404, {'Content-Type' => 'text/html'}, []]
    end
  end
end