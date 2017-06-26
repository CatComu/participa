server 'participa.catalunyaencomu.cat', port: 22015, roles: %w(db web app)

set :branch, :master
set :deploy_to, '/home/participa/participa.catalunyaencomu.cat'
