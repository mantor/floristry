namespace :server do
  # Default, todo make this configurable.
  flack_path = Gem::Specification.find_by_name("floristry").gem_dir + '/../flack'

  desc "Start all servers"
  task :start => [:'flack:start', :'rails:start']

  desc "Stop all servers"
  task :stop => [:'flack:stop', :'rails:stop']

  desc "Restart all servers"
  task :restart => [:'flack:restart', :'rails:restart']

  namespace :rails do
    desc "Precompile assets and migrate db"
    task :precompile_and_migrate do
      chdir "spec/dummy/rails_app" do
        Bundler.with_clean_env do
          sh "RAILS_ENV=test bundle exec rake assets:precompile"
          sh "RAILS_ENV=test bundle exec rake db:migrate"
        end
      end
    end

    desc "Start rails"
    task :start do
      chdir "spec/dummy/rails_app" do
        Bundler.with_clean_env do
          sh %{bundle exec rails s -d}
        end
      end
    end

    desc "Stop rails"
    task :stop do
      chdir "spec/dummy/rails_app" do
        sh %{if [ -f tmp/pids/server.pid ]; then kill `cat tmp/pids/server.pid`; fi}
      end
    end

    desc "Restart rails"
    task :restart do
      Rake::Task["server:rails:stop"].invoke
      Rake::Task["server:rails:start"].invoke
    end

    desc "Install rails deps"
    task :install_dep do
      chdir "spec/dummy/rails_app" do
        Bundler.with_clean_env do
          sh "bundle install"
        end
        sh "rails g floristry:install --flack-dir=#{flack_path}"
      end
    end
  end

  namespace :flack do

    desc "Start Flack: Rack app for the Flor workflow engine"
    task :start do
      Bundler.with_clean_env do
        chdir flack_path do
          sh %{ make start }
        end
      end
    end

    desc "Stop Flack"
    task :stop do
      Bundler.with_clean_env do
        chdir flack_path do
          sh %{ make stop }
        end
      end
    end

    desc "Restart Flack"
    task :restart do
      Bundler.with_clean_env do
        chdir flack_path do
          sh %{ make restart }
        end
      end
    end

    desc "Clone Flack"
    task :clone do
      sh %{ git clone https://github.com/floraison/flack #{flack_path} }
    end

    desc "Install Flack's dependencies"
    task :install_dep do
      sh %{ bundle install --gemfile=#{flack_path}/Gemfile }
    end

    desc "Run Flack's migration"
    task :migrate do
      Bundler.with_clean_env do
        chdir flack_path do
          sh %{ make migrate }
        end
      end
    end

    desc "Install Flack"
    task :install => %w[flack:clone flack:install_dep flack:migrate]
  end
end

namespace :floristry do

  desc "Install Floristry and all dependencies for testing with dummy app"
  task :setup_dummy do
    Rake::Task["app:server:flack:install"].invoke

    Bundler.with_clean_env do
      Rake::Task["app:server:rails:install_dep"].invoke
      Rake::Task["app:server:rails:precompile_and_migrate"].invoke
    end
  end
end