## Coding Standards

### Rails Conventions

- Stay close to vanilla Rails — no premature abstractions.
- Prefer Rails built-ins: `solid_cache`, `solid_queue`, `solid_cable`, `ActiveStorage`, `Action Mailer`.
- Use `resources` routing; keep controllers RESTful. Add custom actions only when truly needed.
- Keep controllers thin — move business logic to models or (sparingly) service objects.
- Service objects, presenters, and decorators only when logic is complex and reused across multiple places.
- Views: use partials in `app/views/partials/` for shared UI fragments.
- Naming: snake_case files and methods, CamelCase classes, kebab-case CSS class names.

### Frontend

- **Hotwire first**: Use Turbo Frames and Turbo Streams for interactivity before writing any JavaScript.
- **DaisyUI by default**: Use DaisyUI components for UI elements.
- **Tailwind sparingly**: Use raw Tailwind utility classes only when DaisyUI does not cover the need.
- New JavaScript logic belongs in Stimulus controllers (`app/javascript/controllers/`).

### Code Style

- Follow **RuboCop Rails Omakase** in all Ruby files. Run `rubocop` before committing.
- Do not add unnecessary comments — code should be self-explanatory.
- Do not add docstrings or type annotations to code you did not change.
- Do not add error handling for scenarios that cannot happen.
- Database is SQLite in all environments (development, test, production).
- Always create a new migration for schema changes — never edit `db/schema.rb` directly.
- Never edit existing migration files in `db/migrate/`.
