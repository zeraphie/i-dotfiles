# Style Guide

A living reference for how Izzy writes code. When in doubt, match what's already here.

---

## Table of Contents

- [General Principles](#general-principles)
- [JavaScript / TypeScript](#javascript--typescript)
  - [Formatting](#formatting)
  - [Naming Conventions](#naming-conventions)
  - [Constants & Variables](#constants--variables)
  - [Functions](#functions)
  - [Classes](#classes)
  - [Guards — Early Returns](#guards--early-returns)
  - [Code Rhythm — Blank Lines](#code-rhythm--blank-lines)
  - [Imports](#imports)
  - [Events](#events)
  - [JSDoc](#jsdoc)
  - [File Structure](#file-structure)
- [SCSS](#scss)
- [React / Components](#react--components)
- [Tooling](#tooling)

---

## General Principles

- **Readable over clever.** Code is read far more than it is written.
- **Flat over nested.** Guards keep nesting shallow. Prefer early returns.
- **Explicit over implicit.** Name things well. Don't make the reader guess.
- **Consistent over perfect.** Follow the existing pattern in a file, even if you'd do it differently fresh.
- **Visual grepping matters.** Blank lines, section comments, and consistent structure let you scan a file fast.

---

## JavaScript / TypeScript

### Formatting

- **Indentation:** 2 spaces. No tabs.
- **Quotes:** Single quotes `'` everywhere. Template literals only when interpolating.
- **Semicolons:** Always. No ASI reliance.
- **Line length:** Aim for 100 chars. Don't be rigid about it, but don't write 200-char lines.
- **Trailing commas:** Yes, in multi-line arrays/objects/params.
- **Braces on conditionals:** Always `{}`, even for single-line bodies — no exceptions.
- **Space before paren in `if`/`for`/`while`:** No space. Write `if(condition)`, not `if (condition)`.

```/dev/null/examples.js
// ✗ bad — no braces, space before paren
if (thing) doSomething();

// ✓ good — braces, no space before paren
if(thing) {
  doSomething();
}

// ✗ bad — ternary obscures intent
const label = isActive ? 'Active' : 'Inactive';

// ✓ good — guard + early return makes intent clear
if(isActive) {
  return 'Active';
}

return 'Inactive';
```

---

### Naming Conventions

| Thing                          | Convention           | Example                        |
| ------------------------------ | -------------------- | ------------------------------ |
| Files & folders                | `kebab-case`         | `user-profile.ts`              |
| Variables & functions          | `camelCase`          | `getUserName()`                |
| Classes & components           | `PascalCase`         | `UserProfile`                  |
| Module-level constants         | `SCREAMING_SNAKE_CASE` | `MAX_RETRY_COUNT`            |
| Private / internal methods     | `_camelCase` prefix  | `_handleClick()`               |
| React component files          | `PascalCase`         | `UserProfile.tsx`              |

---

### Constants & Variables

- `const` by default — always.
- `let` only when you genuinely need to reassign.
- Never `var`.

```/dev/null/variables.js
// ✗ bad
var count = 0;
let name = 'Izzy'; // never reassigned

// ✓ good
const name = 'Izzy';
let count = 0; // will be incremented
count++;
```

Module-level constants use `SCREAMING_SNAKE_CASE`:

```/dev/null/constants.js
// ── Constants ──────────────────────────────────────────

const BASE_URL = 'https://api.example.com';
const MAX_RETRY_COUNT = 3;
const DEFAULT_TIMEOUT_MS = 5000;
```

---

### Functions

- **Top-level & named functions:** `function` declaration syntax.
- **Callbacks & handlers:** Arrow functions.
- **Avoid anonymous functions** in places where a name would help the stack trace.

```/dev/null/functions.js
// ✓ top-level — named function declaration
function processUser(user) {
  return user.name.trim();
}

// ✓ callback — arrow function
const names = users.map((user) => user.name);

// ✓ event handler — arrow function
element.addEventListener('click', (event) => {
  handleClick(event);
});
```

---

### Classes

- ES6 class syntax always.
- `static get` for static properties.
- Class field arrow syntax for methods that need a stable `this` (e.g. event handlers wired up in the constructor).
- `_camelCase` prefix for private/internal methods.
- Fluent chaining: methods that don't return a meaningful value should `return this`.

```/dev/null/classes.js
// component.js — example class showing all conventions

// ── Constants ──────────────────────────────────────────

const DEFAULT_OPTIONS = {
  autoPlay: false,
  loop: true,
};

// ── Component ──────────────────────────────────────────

/**
 * A self-contained UI component.
 *
 * @example
 * const player = new Player(element, { autoPlay: true });
 * player.init().play();
 */
class Player {
  // Static properties
  static get defaultOptions() {
    return DEFAULT_OPTIONS;
  }

  static get events() {
    return {
      PLAY: 'player:play',
      PAUSE: 'player:pause',
      END: 'player:end',
    };
  }

  /**
   * @param {HTMLElement} element
   * @param {object} [options]
   */
  constructor(element, options = {}) {
    this.element = element;
    this.options = { ...Player.defaultOptions, ...options };
    this.isPlaying = false;
  }

  // ── Public API ─────────────────────────────────────

  /** Initialise event listeners and prepare state. */
  init() {
    this.element.addEventListener('click', this._handleClick);
    return this; // fluent
  }

  /** Start playback. */
  play() {
    if(this.isPlaying) {
      return this;
    }

    this.isPlaying = true;
    this._emit(Player.events.PLAY);

    return this;
  }

  /** Pause playback. */
  pause() {
    if(!this.isPlaying) {
      return this;
    }

    this.isPlaying = false;
    this._emit(Player.events.PAUSE);

    return this;
  }

  // ── Private ────────────────────────────────────────

  /**
   * Stable reference needed because it's passed to addEventListener.
   * @param {MouseEvent} event
   */
  _handleClick = (event) => {
    event.preventDefault();
    this.isPlaying ? this.pause() : this.play();
  };

  /**
   * @param {string} name
   * @param {object} [detail]
   */
  _emit(name, detail = {}) {
    const event = new CustomEvent(name, { detail, bubbles: true });
    this.element.dispatchEvent(event);
    return this;
  }
}
```

---

### Guards — Early Returns

Guards are the primary tool for handling conditionals. They keep code flat, readable, and easy to scan. The rule: **handle the unhappy path first, then continue with the happy path**.

Never use a ternary or a long boolean chain where a guard would be clearer.

---

#### 1. Simple condition guard

```/dev/null/guard-simple.js
// ✗ bad — else branch adds nesting for no reason
function greet(user) {
  if(user.isLoggedIn) {
    return `Hello, ${user.name}!`;
  } else {
    return 'Hello, guest!';
  }
}

// ✓ good — guard the unhappy path first, fall through
function greet(user) {
  if(!user.isLoggedIn) {
    return 'Hello, guest!';
  }

  return `Hello, ${user.name}!`;
}
```

---

#### 2. Null / undefined guard

```/dev/null/guard-null.js
// ✗ bad — everything nested inside the truthy check
function getDisplayName(profile) {
  if(profile) {
    if(profile.displayName) {
      return profile.displayName;
    } else {
      return profile.email;
    }
  } else {
    return 'Anonymous';
  }
}

// ✓ good — each failure exits immediately, happy path at the bottom
function getDisplayName(profile) {
  if(!profile) {
    return 'Anonymous';
  }

  if(!profile.displayName) {
    return profile.email;
  }

  return profile.displayName;
}
```

---

#### 3. Replacing a ternary with a guard + early return

```/dev/null/guard-ternary.js
// ✗ bad — ternary reads oddly, especially when values are non-trivial
function getStatusLabel(status) {
  return status === 'active'
    ? 'Currently Active'
    : status === 'pending'
      ? 'Awaiting Approval'
      : 'Inactive';
}

// ✓ good — one exit per case, instantly scannable
function getStatusLabel(status) {
  if(status === 'active') {
    return 'Currently Active';
  }

  if(status === 'pending') {
    return 'Awaiting Approval';
  }

  return 'Inactive';
}
```

---

#### 4. Replacing a long boolean chain

```/dev/null/guard-boolean.js
// ✗ bad — one long condition is hard to parse and hard to debug
function canPublish(user, post) {
  if(user.isLoggedIn && user.role === 'editor' && !post.isLocked && post.authorId === user.id) {
    publish(post);
  }
}

// ✓ good — each condition is its own named guard
function canPublish(user, post) {
  if(!user.isLoggedIn) {
    return;
  }

  if(user.role !== 'editor') {
    return;
  }

  if(post.isLocked) {
    return;
  }

  if(post.authorId !== user.id) {
    return;
  }

  publish(post);
}
```

---

### Code Rhythm — Blank Lines

Blank lines are used to group related lines into visual "paragraphs" — even inside a single function, even without block statements. This makes functions scannable without having to read every word.

Think of it like prose: sentences belong to paragraphs, and paragraphs have breaks between them.

```/dev/null/rhythm.js
// ✗ bad — wall of code, no visual breaks
function submitForm(formData) {
  const name = formData.get('name').trim();
  const email = formData.get('email').trim().toLowerCase();
  const message = formData.get('message').trim();
  if(!name || !email || !message) {
    showError('All fields are required.');
    return;
  }
  const payload = { name, email, message, submittedAt: Date.now() };
  const response = await fetch('/api/contact', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload),
  });
  if(!response.ok) {
    showError('Something went wrong. Please try again.');
    return;
  }
  showSuccess('Message sent!');
  resetForm();
}

// ✓ good — paragraphs make the shape of the function obvious at a glance
async function submitForm(formData) {
  // Extract and normalise inputs
  const name = formData.get('name').trim();
  const email = formData.get('email').trim().toLowerCase();
  const message = formData.get('message').trim();

  // Guard: all fields required
  if(!name || !email || !message) {
    showError('All fields are required.');
    return;
  }

  // Build and send the request
  const payload = { name, email, message, submittedAt: Date.now() };
  const response = await fetch('/api/contact', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload),
  });

  // Guard: handle server error
  if(!response.ok) {
    showError('Something went wrong. Please try again.');
    return;
  }

  // Success
  showSuccess('Message sent!');
  resetForm();
}
```

The rule: **any time you switch mental context inside a function — from input extraction, to validation, to logic, to output — add a blank line.**

---

### Imports

- Explicit `.js` extensions on all ESM imports (even if the source is `.ts` — the output is `.js`).
- Group imports: external packages first, then internal modules, separated by a blank line.
- No default exports from library/utility files — prefer named exports.

```/dev/null/imports.js
import { readFile } from 'node:fs/promises';
import { z } from 'zod';

import { parseConfig } from './config.js';
import { Logger } from './logger.js';
```

---

### Events

Custom events are namespaced with a colon: `'namespace:event'`. This prevents collisions and makes it obvious at the call site where an event comes from.

```/dev/null/events.js
// ✗ bad — could collide with native events or other libraries
element.dispatchEvent(new CustomEvent('change'));
element.dispatchEvent(new CustomEvent('loaded'));

// ✓ good — namespaced, unambiguous
element.dispatchEvent(new CustomEvent('carousel:change'));
element.dispatchEvent(new CustomEvent('carousel:loaded'));
```

Static event maps on classes make them discoverable:

```/dev/null/event-map.js
static get events() {
  return {
    CHANGE: 'carousel:change',
    LOADED: 'carousel:loaded',
  };
}

// Usage
element.addEventListener(Carousel.events.CHANGE, handler);
```

---

### JSDoc

JSDoc is required on:
- All public class methods
- All exported functions in library/utility files
- Component props types (when not using TypeScript)
- Anything non-obvious

JSDoc is optional (but welcome) on:
- Private methods with obvious signatures
- Internal helpers in application code

```/dev/null/jsdoc.js
/**
 * Formats a date for display in the UI.
 *
 * @param {Date|string|number} date - Accepts a Date object, ISO string, or timestamp.
 * @param {object} [options]
 * @param {string} [options.locale='en-GB'] - BCP 47 locale string.
 * @param {boolean} [options.includeTime=false] - Whether to include the time portion.
 * @returns {string} A human-readable date string.
 *
 * @example
 * formatDate(new Date(), { includeTime: true });
 * // => '12 July 2025, 14:30'
 */
function formatDate(date, options = {}) {
  const { locale = 'en-GB', includeTime = false } = options;

  const d = date instanceof Date ? date : new Date(date);
  const dateStyle = 'long';
  const timeStyle = includeTime ? 'short' : undefined;

  return new Intl.DateTimeFormat(locale, { dateStyle, timeStyle }).format(d);
}
```

---

### File Structure

Every file starts with a header comment on line 1:

```/dev/null/header.js
// user-service.js — handles user fetching, caching, and session management
```

Long files use section dividers to break up regions. The `──` dashes are decorative but consistent — use them:

```/dev/null/sections.js
// user-service.js — handles user fetching, caching, and session management

import { db } from './db.js';

// ── Constants ──────────────────────────────────────────

const CACHE_TTL_MS = 60_000;
const MAX_SESSIONS = 5;

// ── Helpers ────────────────────────────────────────────

function normaliseUser(raw) {
  // ...
}

// ── Public API ─────────────────────────────────────────

export async function getUser(id) {
  // ...
}

export async function createUser(data) {
  // ...
}
```

---

## SCSS

### Styling context
Personal projects use SCSS by default. Work projects may use different styling approaches — always match what the repo already uses:
- If the repo uses **Tailwind** — use Tailwind, follow its conventions
- If the repo uses **styled-components**, **emotion**, or **NativeWind/Uniwind** (React Native) — follow existing patterns
- If there is no existing styling — default to SCSS
- Never mix styling approaches within the same project without asking first

### Fundamentals

- Deep nesting with `&` parent selectors — keep the component's styles self-contained.
- CSS custom properties (`--token`) for design tokens (colours, spacing scale, typography).
- SCSS `$variables` for computed values used only in SCSS (e.g. pixel-art grids).
- BEM-influenced class naming: `.block`, `.block__element`, `.block--modifier`.

### Design Tokens

```/dev/null/tokens.scss
// ── Tokens ─────────────────────────────────────────────

:root {
  --color-bg: #0a0a0a;
  --color-surface: #141414;
  --color-primary: #7c6aff;
  --color-text: #f0f0f0;
  --color-muted: #888;

  --unit: 8px;
  --radius: 4px;
  --transition-speed: 200ms;
  --transition-easing: cubic-bezier(0.4, 0, 0.2, 1);
}
```

### Spacing

Use `calc(var(--unit) * N)` for spacing, not magic numbers:

```/dev/null/spacing.scss
.card {
  padding: calc(var(--unit) * 2);     // 16px
  margin-bottom: calc(var(--unit) * 3); // 24px
  gap: var(--unit);                    // 8px
}
```

### Animation

Always pair `transition` with `will-change`. Use `translate3d` instead of `translateX`/`translateY` to force GPU compositing:

```/dev/null/animation.scss
.drawer {
  transform: translate3d(-100%, 0, 0);
  transition: transform var(--transition-speed) var(--transition-easing);
  will-change: transform;

  &--open {
    transform: translate3d(0, 0, 0);
  }
}
```

### Deep nesting with `&`

```/dev/null/nesting.scss
.card {
  background: var(--color-surface);
  border-radius: var(--radius);
  padding: calc(var(--unit) * 2);
  transition: box-shadow var(--transition-speed) var(--transition-easing);
  will-change: box-shadow;

  &__header {
    display: flex;
    align-items: center;
    gap: var(--unit);
    margin-bottom: calc(var(--unit) * 1.5);
  }

  &__title {
    color: var(--color-text);
    font-size: 1.125rem;
    font-weight: 600;
  }

  &__body {
    color: var(--color-muted);
    font-size: 0.875rem;
    line-height: 1.6;
  }

  &--featured {
    border: 1px solid var(--color-primary);
  }

  &:hover {
    box-shadow: 0 4px 24px rgb(0 0 0 / 40%);
  }
}
```

### The `$pixel` pattern

For pixel-art dot grids built with `box-shadow`, use a `$pixel` SCSS variable for the base unit and inline comments to label each dot or row:

```/dev/null/pixel.scss
// pixel-grid.scss — pixel-art dot grid via box-shadow

$pixel: 2px;

.pixel-icon {
  // The element itself is the top-left pixel
  width: $pixel;
  height: $pixel;
  background: var(--color-primary);

  // box-shadow grid — each value is one pixel dot
  // Format: X Y 0 0 color
  box-shadow:
    // Row 1
    calc($pixel * 1) 0               0 0 var(--color-primary), // Top centre
    calc($pixel * 2) 0               0 0 var(--color-primary), // Top right
    // Row 2
    0                calc($pixel * 1) 0 0 var(--color-primary), // Left
    calc($pixel * 3) calc($pixel * 1) 0 0 var(--color-primary), // Right
    // Row 3
    calc($pixel * 1) calc($pixel * 2) 0 0 var(--color-primary), // Bottom centre-left
    calc($pixel * 2) calc($pixel * 2) 0 0 var(--color-primary); // Bottom centre-right
}
```

---

## React / Components

### Atomic Design (loose)

Organise components into layers. The boundaries are guidelines, not laws:

| Layer        | Description                                              | Examples                        |
| ------------ | -------------------------------------------------------- | ------------------------------- |
| **Atoms**    | Smallest indivisible UI units                            | `Button`, `Input`, `Icon`       |
| **Molecules**| Combinations of atoms with a single responsibility       | `SearchField`, `FormRow`        |
| **Organisms**| Complex, self-contained UI sections                      | `Header`, `ProductCard`, `Form` |
| **Pages**    | Route-level components that compose organisms            | `HomePage`, `ProfilePage`       |

### Component Rules

- Functional components with **named `function` declarations** — not arrow functions at the top level.
- Props **destructured in the function signature**.
- One component per file.
- File named the same as the component in PascalCase: `UserCard.jsx`.
- Import the companion SCSS file at the top.

```/dev/null/Component.jsx
// UserCard.jsx — displays a user's avatar, name, and role

import './UserCard.scss';

/**
 * Displays a user's avatar, display name, and role badge.
 *
 * @param {object} props
 * @param {object} props.user - The user object.
 * @param {string} props.user.name - The user's display name.
 * @param {string} props.user.avatarUrl - URL to the user's avatar image.
 * @param {string} [props.user.role] - Optional role label.
 * @param {boolean} [props.compact=false] - Whether to render in compact mode.
 */
function UserCard({ user, compact = false }) {
  // Guard: nothing to render without a user
  if(!user) {
    return null;
  }

  // Guard: compact variant has its own layout
  if(compact) {
    return (
      <div className='user-card user-card--compact'>
        <img className='user-card__avatar' src={user.avatarUrl} alt={user.name} />
        <span className='user-card__name'>{user.name}</span>
      </div>
    );
  }

  return (
    <div className='user-card'>
      <img className='user-card__avatar' src={user.avatarUrl} alt={user.name} />

      <div className='user-card__info'>
        <p className='user-card__name'>{user.name}</p>

        {user.role && (
          <span className='user-card__role'>{user.role}</span>
        )}
      </div>
    </div>
  );
}

export default UserCard;
```

### Guards in Components

Guards work the same in JSX as in plain JS. Handle missing data, loading states, and edge cases at the top of the component before rendering anything complex.

```/dev/null/guards-react.jsx
function ProfilePage({ userId }) {
  const { data: user, isLoading, error } = useUser(userId);

  if(isLoading) {
    return <LoadingSpinner />;
  }

  if(error) {
    return <ErrorMessage message={error.message} />;
  }

  if(!user) {
    return <EmptyState message='User not found.' />;
  }

  return (
    <main className='profile-page'>
      <UserCard user={user} />
    </main>
  );
}
```

---

## Tooling

For all new projects, prefer:

| Purpose           | Tool              | Notes                                          |
| ----------------- | ----------------- | ---------------------------------------------- |
| Package manager   | **bun**           | Fast installs, built-in test runner            |
| Task runner       | **just**          | Simple, explicit, language-agnostic            |
| Linter            | **oxlint**        | Rust-based, extremely fast                     |
| Formatter         | **oxfmt**         | Companion to oxlint                            |
| Test runner       | **Vitest**        | Fast, ESM-native, compatible with Jest API     |
| Styles            | **SCSS**          | No Tailwind, no CSS-in-JS                      |

For personal projects, always default to SCSS. For work projects, match the existing styling approach in the repo — Tailwind, styled-components, or NativeWind are all acceptable if already in use. Never mix styling approaches within the same project without asking first.

### Commits & Versioning
- **commitlint** with conventional commits for non-WIP commits
- WIP commits (`wip: ...`) are exempt from commitlint rules
- Feature work happens on branches (`feature/thing`, `fix/thing`, `chore/thing`)
- Squash merge to `main` only — main branch commits are version bumps only (`v1.2.0`)
- Semantic versioning (`vMAJOR.MINOR.PATCH`)
- CHANGELOG.md updated on every release in Keep a Changelog format
- Changelog entries describe **behaviour changes** not file changes — "add x feature" not "update x file"

### Testing Philosophy
- Tests exist to **protect behaviour** and **aid development** — not to hit coverage numbers
- No coverage targets, no coverage CI gates
- Test core features, edge cases, and regression-prone behaviour
- Do not test implementation details
- Do not write tests just to increase coverage — if a test doesn't help you develop or protect a feature, don't write it

---

## Commenting

### When to comment
- **JSDoc** on all public functions, classes, and methods — describe intent, not implementation
- **Inline comments** only when the intent of a block of code is not obvious from reading it
- Code should be self-explanatory after reading the JSDoc — don't narrate what the code does, explain *why* it does it

### JSDoc
- Always include `@param` and `@returns` for non-obvious signatures
- Add `@complexity O(n)` (or appropriate notation) on non-trivial functions
- Add `@throws` when a function can throw
- Add `@example` for utility functions that benefit from a usage example

```js
/**
 * Normalises a raw score into the 0–1 range for a given category.
 * Raw values vary wildly by category and would produce misleading
 * rankings without normalisation.
 *
 * @param {number} raw      - The raw score value
 * @param {number} min      - The minimum possible value for this category
 * @param {number} max      - The maximum possible value for this category
 * @returns {number}        - Normalised score in [0, 1]
 * @complexity O(1)
 */
function normaliseScore(raw, min, max) {
  if(max === min) {
    return 0;
  }

  return (raw - min) / (max - min);
}
```

### What not to comment
- Don't comment obvious code (`// increment i` above `i++`)
- Don't leave commented-out code in commits — delete it
- Don't write comments that just restate the code in English

### Good intent comment example
```js
// Normalise scores before comparison — raw values vary wildly by category
// and would produce misleading rankings without this step.
const normalised = scores.map(normalise);
```

---

## Security

Apply these rules to all code. Do not wait to be asked.

### General
- Never hardcode secrets, tokens, API keys, or credentials — always use environment variables
- Never log sensitive data (passwords, tokens, PII, financial data, health data)
- Always validate and sanitise input — never trust user-supplied data
- Use parameterised queries — never interpolate user input into SQL or shell commands
- Avoid `eval()`, `innerHTML` with user content, `dangerouslySetInnerHTML`, and `Function()` constructor

### Authentication & OAuth
- OAuth flows must use the `state` parameter for CSRF protection
- PKCE must be used for public clients
- Tokens must never be stored in `localStorage` — use `httpOnly` cookies or in-memory storage
- Implement refresh token rotation
- Auth errors must not leak whether a user exists — use generic error messages

### XSS
- Never render unsanitised user content as HTML
- Avoid `dangerouslySetInnerHTML` — if unavoidable, sanitise with a well-maintained library (e.g. DOMPurify)
- Set Content Security Policy headers

### CSRF
- All state-mutating requests must be protected via CSRF tokens or `SameSite` cookies

### Dependencies
- Prefer well-maintained, minimal-dependency packages
- Avoid packages with known vulnerabilities or that haven't been updated in over 2 years

### Fintech context (Advisa org)
- All data mutations must be traceable — log who did what, when, to what record
- Audit logs must be append-only and must not contain PII in plaintext
- Every endpoint must have authentication and authorisation checks
- Financial data must be encrypted at rest and in transit
- Rate limiting is required on all auth and sensitive endpoints

---

## Privacy & GDPR

Apply these rules whenever handling user data. Flag genuinely risky patterns — don't flag every field access.

### Data minimisation
- Only collect and store data that is actually needed for the feature
- For OAuth/SSO (e.g. Discord): only request the minimum required scopes

### PII handling
- Do not log names, emails, IDs, IP addresses, or any user-identifying data
- Do not store PII without a clear retention or deletion strategy

### User rights
- When a feature stores user data, ensure a deletion/erasure path exists or is planned
- Do not design features that make it hard to export or delete user data

### Consent
- Do not load analytics, tracking pixels, or third-party scripts without user consent
- Do not use cookies beyond strictly necessary ones without a consent mechanism

---

## Performance

### React rendering
- Use `useMemo`, `useCallback`, and `React.memo` where genuinely beneficial — don't over-optimise prematurely
- Avoid passing new object/array literals directly as props (e.g. `style={{ color: 'red' }}`)
- Keep `key` values stable in lists — avoid using array index as key in dynamic lists
- Lazy-load heavy components with `React.lazy` + `Suspense`

### Canvas & rendering
- Use `requestAnimationFrame` for animation loops — never `setInterval`
- Consider offscreen canvas for heavy drawing operations
- Avoid reading layout properties (e.g. `offsetWidth`) and writing to the DOM in the same frame (layout thrashing)

### Algorithmic complexity
- Add `@complexity O(n)` (or appropriate) JSDoc on any non-trivial function
- Avoid O(n²) or worse in hot paths
- Avoid nested loops over large datasets — consider Maps or Sets for lookups

### Concurrency & parallelism
- Only introduce web workers or concurrency when there is a clear, demonstrated performance need
- Premature parallelisation adds complexity without measurable benefit — avoid it
- When concurrency is introduced, document the complexity cost explicitly

### General
- Avoid blocking the main thread with synchronous heavy work
- Prefer streaming or pagination over loading large datasets at once
- Never make unbounded data fetches — always paginate or limit results

### Commits & Versioning
- **commitlint** with conventional commits for non-WIP commits
- WIP commits (`wip: ...`) are exempt from commitlint rules
- Feature work happens on branches (`feature/thing`, `fix/thing`, `chore/thing`)
- Squash merge to `main` only — main branch commits are version bumps only (`v1.2.0`)
- Semantic versioning (`vMAJOR.MINOR.PATCH`)
- CHANGELOG.md updated on every release in Keep a Changelog format
- Changelog entries describe **behaviour changes** not file changes — "add x feature" not "update x file"

### Testing Philosophy
- Tests exist to **protect behaviour** and **aid development** — not to hit coverage numbers
- No coverage targets, no coverage CI gates
- Test core features, edge cases, and regression-prone behaviour
- Do not test implementation details
- Do not write tests just to increase coverage — if a test doesn't help you develop or protect a feature, don't write it