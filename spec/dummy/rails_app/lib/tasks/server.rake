namespace :server do

  desc "Start all servers"
  task :start => [:'rails:start', :'flack:start']

  desc "Stop all servers"
  task :stop => [:'rails:stop', :'flack:stop']

  desc "Restart all servers"
  task :restart => [:'rails:restart', :'flack:restart']

  namespace :rails do
    desc "Start rails"
    task :start do
      sh %{bundle exec rails s}
    end

    desc "Stop rails"
    task :stop do
      sh %{bundle exec rails stop}
    end

    desc "Restart rails"
    task :restart do
      sh %{kill -s SIGUSR2 `cat tmp/pids/server.pid`}
    end
  end

  namespace :flack do
    desc "Start Flack: Rack app for the flor workflow engine"
    task :start do
       chdir "../flack"
       sh %{ make start }
    end

    desc "Stop Flack"
    task :stop do
      chdir "../flack"
      sh %{ make stop }
    end

    desc "Restart Flack"
    task :restart do
      chdir "../flack"
      sh %{ make restart }
    end
  end
end
