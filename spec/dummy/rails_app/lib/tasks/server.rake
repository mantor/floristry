namespace :server do

  desc "Start all servers"
  task :start => [:'flack:start', :'rails:start']

  desc "Stop all servers"
  task :stop => [:'flack:stop', :'rails:stop']

  desc "Restart all servers"
  task :restart => [:'flack:restart', :'rails:restart']

  namespace :rails do
    desc "Start rails"
    task :start do
      sh %{bundle exec rails s -d}
    end

    desc "Stop rails"
    task :stop do
      sh %{if [ -f tmp/pids/server.pid ]; then kill `cat tmp/pids/server.pid`; fi}
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
      end
    end


  end

  namespace :flack do
    flack_path = "../flack"

    desc "Start Flack: Rack app for the Flor workflow engine"
    task :start do
       chdir flack_path do
         sh %{ make start }
       end
    end

    desc "Stop Flack"
    task :stop do
      chdir flack_path do
        sh %{ make stop }
      end
    end

    desc "Restart Flack"
    task :restart do
      chdir flack_path do
        sh %{ make restart }
      end
    end

    desc "Clone Flack"
    task :clone do
      sh %{ git clone https://github.com/floraison/flack ../flack }
    end

    desc "Install Flack's dependencies"
    task :install_dep do
      sh %{ bundle install --gemfile=#{flack_path}/Gemfile }
    end

    desc "Run Flack's migration"
    task :migrate do
      chdir flack_path do
        sh %{ make migrate }
      end
    end

    desc "Install Flack"
      task :install => %w[flack:clone flack:install_dep flack:migrate]
    end
end
