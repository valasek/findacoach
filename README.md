# Find a Coach

Focus on coaching and Find a Coach will manage all what you need: your coaching session times and notes and clients.

## Roadmap

[Roadmap](https://github.com/users/valasek/projects/2/views/1?layout=board)

## License

All source code in this repository is released under the **[CC BY‑NC 4.0](https://creativecommons.org/licenses/by‑nc/4.0/)** license.

- ❌ **Commercial use is not permitted**
- 🔒 No patent rights are granted
- 📝 Attribution and copyright notice must be included
- ⚠️ No liability and no warranty

If you'd like to use this software commercially, please [contact me](https://www.stanislavvalasek.com/en/contact/) to discuss a commercial license.

# ToDo

- export also group sessions
- show add new session
- add font awesome so I can use fab fav ...
- admin
- welcome email
- auto expire notice alerts
- add backups 

## How to deploy

`export KAMAL_REGISTRY_PASSWORD=<pwd>`
`kamal deploy`

And optional:

```sh
kamal reset_demo
kamal logs
kamal console
```

## Technical notes

Start app with `bin/dev`

Run tests `bin/rails test`

Precompile rails assets: `rails assets:clean assets:precompile` 

Build Tailwind `bin/rails tailwindcss:build` 

Clean all assets `rails assets:clobber` 

Include into precommit hook:

`rubocop` 
`rails db:test:prepare test test:system`

Reset demo user `rails demo_user:reset` 

 ## Upgrate gems

`bundle outdated`
 
`bundle update`

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

Create private docker repository e.h. on DockerHub
add access token (Read, Write, Delete) and store it in `./kamal/secrets` in variable `KAMAL_REGISTRY_PASSWORD` or set as en environment variable export `KAMAL_REGISTRY_PASSWORD=password`

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
