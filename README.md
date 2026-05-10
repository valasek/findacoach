# Find a Coach

Focus on coaching and Find a Coach will manage all what you need: your coaching session times and notes and clients.

## Roadmap

[Roadmap](https://github.com/users/valasek/projects/2/views/1?layout=board)

## License

All source code in this repository is released under the **[O'Saasy](https://osaasy.dev/)** license.

- ✅ **Commercial use is permitted** (with restrictions)
- 🚫 Cannot offer as competing SaaS/hosted service
- 📝 Attribution and copyright notice must be included
- ⚠️ No liability and no warranty

## How to deploy

`kamal deploy`

And optional:

```sh
kamal reset_demo
kamal logs
kamal console
```

## Technical notes

### First run

Build Tailwind `bin/rails tailwindcss:build`

Reset demo user `rails demo_user:reset`

Update credentials run

`VISUAL="code --wait" bin/rails credentials:edit`

if missing, it will create RAILS_MASTER_KEY

When moving repo to another machine, copy config/master.key 

and set in credentials file:

```yml
secret_key_base:  xxx

# Transactional email provider / RESEND
resend_api_key: xxx

google:
  client_id: xxx
  client_secret: xxx
```

Start app with `bin/dev`

### Other Notes

SVG Icons: https://heroicons.com

Runn local ci: `bin/ci`

Run tests `bin/rails test`

Precompile rails assets: `rails assets:clean assets:precompile`

Clean all assets `rails assets:clobber` 

See test emails (email integration is done via resend.com):

- in folder `tmp/mail/`
- see previews in the browser: `http://localhost:3000/rails/mailers`

Include into precommit hook:

`rubocop` 
`rails db:test:prepare test test:system`

 ## Update
 
 ### Gems

`bundle outdated`
`bundle update --all`

### Bundler
`bundle update --bundler`

### Daisyui

curl -sLo app/assets/tailwind/daisyui.js https://github.com/saadeghi/daisyui/releases/latest/download/daisyui.js

### Kamal

`gem update kamal`
`kamal proxy upgrade`

Clean up unused images and containers
`kamal prune`

### Show list of rake tasks

bin/rails -T

### Backup and restore DB

Backup Process: From your host machine

```sh
docker cp your-rails7-container:/storage/production.sqlite3 ./backup/production.sqlite3
docker cp 290055864fd3:/storage/production-backup.sqlite3 ./production.sqlite3
```

Restore Process: To your new Rails 8 container

```sh
docker cp --chown rails:rails ./production.sqlite3 your-rails8-container:/rails/storage/production.sqlite3
docker cp ./production.sqlite3 290055864fd3:/rails/storage/production.sqlite3
```

And backup locally

```sh
scp ./production.sqlite3 root@162.55.185.37:/root/production.sqlite3
```

Inspect container via bash

```sh
docker exec -it 290055864fd3 bash
```

### KAMAL deployment setup

`run kamal init`

if not using root account, in ./delpoy.yaml add

```yaml
ssh:
  user: kamal
  keys: [ "~/.ssh/id_ed25519" ]
```

Create e.f. Hetzner machine with ssh
Add identity to ssh
Confirm it via `ssh-add -l`

create RAILS_MASTER_KEY

`VISUAL="code --wait" bin/rails credentials:edit`

export key from console from previous commant to env variable `export RAILS_MASTER_KEY=<key from console>`

`VISUAL="code --wait" bin/rails credentials:edit`

export key from console from previous command to env variable or copy it from `config/master.key`

`export RAILS_MASTER_KEY=<key from console>`

`docker login`

`run kamal setup`

---

Rails dev-container configuration
https://dev.to/konyu/how-to-use-docker-containers-for-ruby-on-rails-development-in-visual-studio-code-23np
