require "fileutils"

namespace :assets do
  desc "Compile all the assets named in config.assets.precompile"
  task :precompile do
    Rake::Task["assets:clean:all"].invoke 
    Rake::Task["assets:precompile:all"].invoke
  end

  namespace :precompile do
    task :all => ["environment"] do
      config = Sinatra::Sprockets.config
      config.compile = true
      config.digest  = true
      config.digests = {}

      env      = Sinatra::Sprockets.environment
      target   = File.join(config.app.settings.public_path, config.prefix)
      compiler = Sinatra::Sprockets::StaticCompiler.new(env,
                                               target,
                                               config.precompile,
                                               :manifest_path => config.manifest_path,
                                               :digest => config.digest,
                                               :manifest => true)
      compiler.compile
    end
  end

  desc "Remove compiled assets"
  task :clean do
    Rake::Task["assets:clean:all"].invoke
  end

  namespace :clean do
    task :all => ["environment"] do
      config = Sinatra::Sprockets.config
      public_asset_path = File.join(config.app.settings.public_path, config.prefix)
      rm_rf public_asset_path, :secure => true
    end
  end
end
