require "bloc_works/version"
require "bloc_works/dependencies"
require "bloc_works/controller"

module BlocWorks
  class Application
    def call(env)
      # Use fav_icon and controller_and_action methods
      [200, {'Content-Type' => 'text/html'}, ["Hello Blocheads!"]]
    end
  end
end