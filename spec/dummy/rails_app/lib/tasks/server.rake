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
  end

  namespace :flack do
    desc "Start Flack: Rack app for the flor workflow engine"
    task :start do
       chdir "../flack" do
         sh %{ make start }
       end
    end

    desc "Stop Flack"
    task :stop do
      chdir "../flack" do
        sh %{ make stop }
      end
    end

    desc "Restart Flack"
    task :restart do
      chdir "../flack" do
        sh %{ make restart }
      end
    end
  end
end
