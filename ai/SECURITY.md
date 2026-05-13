# Security & Privacy

## General

- No hardcoded secrets — use environment variables
- No logging of sensitive data (passwords, tokens, PII)
- Validate and sanitise all input — parameterised queries only
- Avoid `eval()`, `innerHTML` with user content, `dangerouslySetInnerHTML`, `Function()`
- Prefer well-maintained, minimal-dependency packages

## Authentication & Tokens

- OAuth: require `state` param + PKCE for public clients
- Tokens: never `localStorage` — use `httpOnly` cookies or memory
- Implement refresh token rotation
- Auth errors must not leak user existence

## Web Security

- CSP headers on all responses
- CSRF protection on state-mutating requests
- No non-essential cookies without consent

## Privacy & GDPR

- Only collect data actually needed for the feature
- Minimum OAuth scopes
- No PII storage without retention/deletion strategy
- Ensure deletion/erasure paths exist for stored user data
- No analytics/tracking without consent

## Fintech Context

When working in a fintech org (e.g. Advisa GitHub org):

- All mutations traceable — log who, what, when, to which record
- Audit logs: append-only, no plaintext PII
- Every endpoint needs authn + authz checks
- Financial data encrypted at rest and in transit
- Rate limiting on auth and sensitive endpoints
