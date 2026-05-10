## Testing

- **Minitest only** — never use RSpec or suggest it.
- Write a unit test for every new model method (`test/models/`).
- Write a controller or integration test for every controller action (`test/controllers/`).
- Write a system test (Capybara) for every user-facing flow (`test/system/`).
- Use fixtures in `test/fixtures/` — do not use factory libraries (no FactoryBot).

### Commands

```sh
bin/rails test          # run all unit + integration tests
bin/rails test:system   # run system (Capybara) tests
bin/ci                  # full CI: tests + rubocop + brakeman + bundle-audit
```
