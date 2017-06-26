server 'betaparticipa.catalunyaencomu.cat', port: 22014, roles: %w(db web app)

set :branch, -> { `git rev-parse --abbrev-ref HEAD`.chomp }
set :deploy_to, '/home/participa/betaparticipa.catalunyaencomu.cat'
