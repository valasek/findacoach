# Find a Coach — Agent Instructions

See [CLAUDE.md](./CLAUDE.md) for all project instructions and follow all rules defined there.

For direct access to individual sections:

- [Project Overview](./.claude/prompt-snippets/project.md)
- [Coding Standards](./.claude/prompt-snippets/coding-standards.md)
- [Testing](./.claude/prompt-snippets/testing.md)
- [Security](./.claude/prompt-snippets/security.md)
- [Commands & Checklists](./.claude/prompt-snippets/commands.md)

## Development Commands

```sh
bin/dev                          # start development server
bin/rails test                   # run all tests
bin/rails test:system            # run Capybara system tests
bin/ci                           # full CI: tests + rubocop + brakeman + bundle-audit
rubocop                          # Ruby linter (Rails Omakase)
rubocop -a                       # auto-fix safe linting offenses
brakeman                         # static security scan
bin/rails tailwindcss:build      # compile Tailwind CSS
bin/rails db:migrate             # run pending database migrations
bin/rails db:rollback            # undo the last migration
kamal deploy                     # deploy to production
rails demo_user:reset            # reset the demo account
```
