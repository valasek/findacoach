# Find a Coach

Focus on coaching and Find a Coach will manage all what you need: your coaching session times and notes and clients.

## Roadmap

[Roadmap](https://github.com/users/valasek/projects/2/views/1?layout=board)

## Technical notes

Start app with bin/dev

Precompile rails assets:
- rails assets:clean assets:precompile

- clean all assets
rails assets:clobber

Include into precommit hook:
rubocop
rails db:test:prepare test test:system

Reset demo user
rails demo_user:reset

### KAMAL deployment

run kamal init
if not using root account, in ./delpoy.yaml add
ssh:
  user: kamal
  keys: [ "~/.ssh/id_ed25519" ]

Create private docker repository e.h. on DockerHub
add access token (Read, Write, Delete) and store it in ./kamal/secrets in variable KAMAL_REGISTRY_PASSWORD= or set as en environment variable export KAMAL_REGISTRY_PASSWORD=password

Create e.f. Hetzner machine with ssh
Add identity to ssh
Confirm it
ssh-add -l

create RAILS_MASTER_KEY
VISUAL="code --wait" bin/rails credentials:edit
export key from console from previous commant to env variable
export RAILS_MASTER_KEY=<key from console>

VISUAL="code --wait" bin/rails credentials:edit
export key from console from previous commant to env variable por comy it from config/master.key
export RAILS_MASTER_KEY=<key from console>

docker login
run kamal setup

#### Deploy using KAMAL
export KAMAL_REGISTRY_PASSWORD=<DockedHub access token>
export RAILS_MASTER_KEY=<key from console>
docker login
kamal deploy

And optional:
kamal reset_demo_user
kamal logs

* Rails dev-container configuration
https://dev.to/konyu/how-to-use-docker-containers-for-ruby-on-rails-development-in-visual-studio-code-23np

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions
