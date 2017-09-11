set :application, 'participa'
set :repo_url, 'https://github.com/CatComu/participa'
set :linked_files, %w{config/database.yml config/secrets.yml config/redis.yml config/mailserver.yml}
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system db/podemos app/assets/fonts}

set :user, 'participa'
set :ssh_options, forward_agent: true

after 'deploy:publishing', 'passenger:restart'
