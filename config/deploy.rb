set :application, "spoke"
set :repository, "http://svn.spanner.org/#{application}/trunk"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
# set :deploy_to, "/var/www/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :web, "bluebottle.spanner.org", :primary => true
role :app, "seagoon.spanner.org", "bluebottle.spanner.org"
role :db,  "eccles.spanner.org", :primary => true

set :deploy_to, "/var/www/#{application}"
set :mongrel_conf, "/etc/mongrel_cluster/#{application}.yml" 
set :user, 'spanner'
set :deploy_via, :remote_cache

namespace :deploy do
  task :after_update do
    run "ln -s #{shared_path}/config/database.yml #{current_release}/config/database.yml" 
    ['collection', 'user', 'source', 'node', 'bundle', 'occasion', 'tag'].each do |directory|
      run "ln -s #{shared_path}/assets/#{directory} #{current_release}/public/#{directory}" 
    end
  end
	
  task :start, :roles => :app do
    sudo "mongrel_rails cluster::start -C #{mongrel_conf}" 
  end
  task :stop, :roles => :app do
    sudo "mongrel_rails cluster::stop -C #{mongrel_conf}" 
  end
  task :restart, :roles => :app do
    sudo "mongrel_rails cluster::restart -C #{mongrel_conf}" 
  end
end

