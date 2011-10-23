module Sinatra
  module Sprockets
    module Helpers
      BOOLEAN_ATTRIBUTES = %w(disabled readonly multiple checked autobuffer
                           autoplay controls loop selected hidden scoped async
                           defer reversed ismap seemless muted required
                           autofocus novalidate formnovalidate open pubdate).to_set
      BOOLEAN_ATTRIBUTES.merge(BOOLEAN_ATTRIBUTES.map {|attribute| attribute.to_sym })
      
      def favicon_link_tag(source='favicon.ico', options={})
        tag('link', {
          :rel  => 'shortcut icon',
          :type => 'image/vnd.microsoft.icon',
          :href => asset_path(source)
        }.merge(options.symbolize_keys))
      end
      
      def image_tag(source, options = {})
        options.symbolize_keys!
        
        options[:src] = asset_path(source)
        
        if size = options.delete(:size)
          options[:width], options[:height] = size.split("x") if size =~ %r{^\d+x\d+$}
        end
        
        tag("img", options)
      end
      
      def video_tag(sources, options = {})
        options.symbolize_keys!
        
        options[:poster] = asset_path(options[:poster]) if options[:poster]
        
        if size = options.delete(:size)
          options[:width], options[:height] = size.split("x") if size =~ %r{^\d+x\d+$}
        end
        
        if sources.is_a?(Array)
          content_tag("video", options) do
            sources.map { |source| tag("source", :src => source) }.join.html_safe
          end
        else
          options[:src] = asset_path(sources)
          tag("video", options)
        end
      end
      
      def audio_tag(source, options = {})
        options.symbolize_keys!
        options[:src] = asset_path(source)
        tag("audio", options)
      end
      
      def javascript_include_tag(*sources)
        options = sources.extract_options!
        debug = options.key?(:debug) ? options.delete(:debug) : config.debug_assets?
        body  = options.key?(:body)  ? options.delete(:body)  : false
        digest  = options.key?(:digest)  ? options.delete(:digest)  : config.digest_assets?
        
        sources.collect do |source|
          if debug && asset = asset_paths.asset_for(source, 'js')
            asset.to_a.map { |dep|
              src = asset_path(dep, :ext => 'js', :body => true, :digest => digest)
              content_tag("script", "", { "type" => "application/javascript", "src" => src }.merge!(options))
            }
          else
            src = asset_path(source, :ext => 'js', :body => body, :digest => digest)
            content_tag("script", "", { "type" => "application/javascript", "src" => src }.merge!(options))
          end
        end.join("\n").html_safe
      end
      
      def stylesheet_link_tag(*sources)
        options = sources.extract_options!
        debug   = options.key?(:debug) ? options.delete(:debug) : config.debug_assets?
        body    = options.key?(:body)  ? options.delete(:body)  : false
        digest  = options.key?(:digest)  ? options.delete(:digest)  : config.digest_assets?
        
        sources.collect do |source|
          if debug && asset = asset_paths.asset_for(source, 'css')
            asset.to_a.map { |dep|
              href = asset_path(dep, :ext => 'css', :body => true, :protocol => :request, :digest => digest)
              tag("link", { "rel" => "stylesheet", "type" => "text/css", "media" => "screen", "href" => href }.merge!(options))
            }
          else
            href = asset_path(source, :ext => 'css', :body => body, :protocol => :request, :digest => digest)
            tag("link", { "rel" => "stylesheet", "type" => "text/css", "media" => "screen", "href" => href }.merge!(options))
          end
        end.join("\n").html_safe
      end
    
      def asset_path(source, options={})
        source = source.logical_path if source.respond_to?(:logical_path)
        path = asset_paths.compute_public_path(source, config.prefix, options.merge(:body => true))
        options[:body] ? "#{path}?body=1" : path
      end
    
      def tag(name, options = nil, open = false, escape = true)
        "<#{name}#{tag_options(options, escape) if options}#{open ? ">" : " />"}".html_safe
      end
    
      def content_tag(name, content_or_options_with_block = nil, options = nil, escape = true, &block)
        if block_given?
          options = content_or_options_with_block if content_or_options_with_block.is_a?(Hash)
          content_tag_string(name, block.call, options, escape)
        else
          content_tag_string(name, content_or_options_with_block, options, escape)
        end
      end
    
      private
    
      def asset_paths
        @asset_paths ||= AssetPaths.new(Sinatra::Sprockets.config)
      end
    
      def config
        Sinatra::Sprockets.config
      end
    
      def tag_options(options, escape = true)
        unless options.blank?
          attrs = []
          options.each_pair do |key, value|
            if key.to_s == 'data' && value.is_a?(Hash)
              value.each do |k, v|
                if !v.is_a?(String) && !v.is_a?(Symbol)
                  v = v.to_json
                end
                v = ERB::Util.html_escape(v) if escape
                attrs << %(data-#{k.to_s.dasherize}="#{v}")
              end
            elsif BOOLEAN_ATTRIBUTES.include?(key)
              attrs << %(#{key}="#{key}") if value
            elsif !value.nil?
              final_value = value.is_a?(Array) ? value.join(" ") : value
              final_value = ERB::Util.html_escape(final_value) if escape
              attrs << %(#{key}="#{final_value}")
            end
          end
          " #{attrs.sort * ' '}".html_safe unless attrs.empty?
        end
      end
    
      def content_tag_string(name, content, options, escape = true)
        tag_options = tag_options(options, escape) if options
        "<#{name}#{tag_options}>#{escape ? ERB::Util.h(content) : content}</#{name}>".html_safe
      end
    end
  end
end
