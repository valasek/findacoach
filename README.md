# Find a Coach

Focus on coaching and Find a Coach will manage all what you need: your coaching session times and notes and clients.

## Roadmap

[Roadmap](https://github.com/users/valasek/projects/2/views/1?layout=board)

## Technical notes

Start app with bin/dev

Run tests - bin/rails test

Precompile rails assets:
- rails assets:clean assets:precompile

Build Tailwind
- bin/rails tailwindcss:build

- clean all assets
rails assets:clobber

# Update Daisyui

curl -sLo app/assets/tailwind/daisyui.js https://github.com/saadeghi/daisyui/releases/latest/download/daisyui.js
curl -sLo app/assets/tailwind/daisyui-theme.js https://github.com/saadeghi/daisyui/releases/latest/download/daisyui-theme.js

Include into precommit hook:
rubocop
rails db:test:prepare test test:system

Reset demo user
rails demo_user:reset

 ## Upgrate gems
 bundle outdated
 bundle update

### Backup and restore DB
Backup Process: From your host machine
docker cp your-rails7-container:/storage/production.sqlite3 ./backup/production.sqlite3
docker cp 290055864fd3:/storage/production-backup.sqlite3 ./production.sqlite3

Restore Process: To your new Rails 8 container
docker cp --chown rails:rails ./production.sqlite3 your-rails8-container:/rails/storage/production.sqlite3
docker cp ./production.sqlite3 290055864fd3:/rails/storage/production.sqlite3

And backup locally
scp ./production.sqlite3 root@162.55.185.37:/root/production.sqlite3 

Inspect container via bash
docker exec -it 290055864fd3 bash

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
export key from console from previous commant to env variable or copy it from config/master.key
export RAILS_MASTER_KEY=<key from console>

docker login
kamal setup

#### Deploy using KAMAL
export KAMAL_REGISTRY_PASSWORD=<DockedHub access token>
export RAILS_MASTER_KEY=<key from console>
docker login
kamal deploy

And optional:
kamal reset_demo_user
kamal logs
kamal console

* Rails dev-container configuration
https://dev.to/konyu/how-to-use-docker-containers-for-ruby-on-rails-development-in-visual-studio-code-23np
