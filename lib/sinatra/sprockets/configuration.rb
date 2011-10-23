module Sinatra
  module Sprockets
    class Configuration
      DEFAULTS = {
        :digest => true, 
        :debug => false, 
        :compile => true, 
        :compress => true,
        :prefix => "assets", 
        :host => nil, 
        :relative_url_root => ENV['RACK_RELATIVE_URL_ROOT'],
        :precompile => [ /\w+\.(?!js|css).+/, /application.(css|js)$/ ], 
        :manifest_path => "public/assets",
        :app => nil
      }
      OPTIONS = DEFAULTS.keys
      
      OPTIONS.each do |option|
        define_method "#{option}=" do |value|
          (@_config ||= {})[option] = value
        end

        define_method "#{option}" do
          (@_config ||= {})[option]
        end
      end
      
      [:digest, :debug, :compile, :compress].each do |option|
        define_method "#{option}_assets?" do
          !! @_config[option]
        end
      end
      
      def initialize
        @_config = DEFAULTS
        @_digests = {}
        @_paths = []
      end
      
      def digests
        @_digests
      end
      
      def digests=(value)
        @_digests = value
      end
      
      def append_path(path)
        @_paths << path
      end
      
      def paths=(value)
        @_paths = value.to_a
      end
      
      def paths
        @_paths
      end
      
      def inspect
        @_config.inspect
      end
      
      def environment
        Sinatra::Sprockets.environment
      end
    end
  end
end