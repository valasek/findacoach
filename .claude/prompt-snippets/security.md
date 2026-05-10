## Security

- Devise manages all authentication — do not implement custom auth logic.
- Every controller action accepting user input must use **strong parameters** (`params.require(...).permit(...)`).
- Run `brakeman` after any change to routes, params, or file upload handling.
- Never read or write `config/master.key` or `config/credentials*.enc`.
- Avo admin (`/admin`) is route-constrained to the owner email — do not change this constraint.
- Always run `brakeman` after adding new routes, params handling, or file uploads.
