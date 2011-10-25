Sinatra::Sprockets.configure do |config|
  config.app = MyApp
  
  ['stylesheets', 'javascripts', 'images'].each do |dir|
    config.append_path(File.join('app', 'assets', dir))
  end
  
  config.digest = true
  config.compress = true
  config.debug = false

  config.precompile = ['application.js', 'vendor.js', 'application.css', /.+\.(png|ico|gif|jpeg|jpg)$/]
end