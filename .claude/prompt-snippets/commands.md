## Key Commands

```sh
bin/dev                          # start dev server (Puma + Tailwind watcher)
bin/rails test                   # run all tests
bin/rails test:system            # run system tests
bin/ci                           # full CI pipeline locally
rubocop                          # lint Ruby
rubocop -a                       # auto-fix safe offenses
brakeman                         # security scan
bin/rails tailwindcss:build      # compile Tailwind CSS
bin/rails db:migrate             # run pending migrations
bin/rails db:rollback            # undo last migration
kamal deploy                     # production deploy
kamal console                    # production Rails console
rails demo_user:reset            # reset demo user data
VISUAL="code --wait" bin/rails credentials:edit  # edit credentials
```

## Before Committing

1. Run `rubocop` — fix all offenses.
2. Run `bin/rails test` — all tests must pass.
3. Run `brakeman` — no new warnings.
4. If you changed CSS or added Tailwind classes, run `bin/rails tailwindcss:build`.

## Files — Never Modify

```
config/master.key              # Rails encryption key — NEVER read or write
config/credentials.yml.enc     # Encrypted credentials
config/credentials*.enc        # Any env-specific credentials
Gemfile.lock                   # Managed by Bundler
db/schema.rb                   # Auto-generated — use migrations only
db/migrate/<existing files>    # Never edit; create new migrations instead
.env*                          # Environment files
```
