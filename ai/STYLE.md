# Style Guide

A living reference for how Izzy writes code. Mechanical formatting (indentation, quotes, semicolons, line length, trailing commas, bracket spacing) is enforced by **oxfmt**. Mechanical lint rules (no-var, prefer-const, eqeqeq, no-eval, no-else-return, etc.) are enforced by **oxlint**. This file covers **judgment calls only**.

---

## Naming Conventions

| Thing                          | Convention             | Example              |
| ------------------------------ | ---------------------- | -------------------- |
| Files & folders                | `kebab-case`           | `user-profile.ts`    |
| Variables & functions          | `camelCase`            | `getUserName()`      |
| Classes & components           | `PascalCase`           | `UserProfile`        |
| Module-level constants         | `SCREAMING_SNAKE_CASE` | `MAX_RETRY_COUNT`    |
| Private / internal methods     | `_camelCase` prefix    | `_handleClick()`     |
| React component files          | `PascalCase`           | `UserProfile.tsx`    |

---

## Functions

- **Top-level & named functions:** `function` declaration syntax.
- **Callbacks & handlers:** Arrow functions.
- **Class field arrow syntax** for methods needing stable `this` binding.

```js
// top-level
function processUser(user) {
  return user.name.trim();
}

// callback
const names = users.map((user) => user.name);
```

---

## Classes

- ES6 class syntax. `static get` for static properties.
- `_camelCase` prefix for private/internal methods.
- Fluent chaining: methods that don't return a meaningful value should `return this`.

```js
class Player {
  static get events() {
    return {
      PLAY: 'player:play',
      PAUSE: 'player:pause',
    };
  }

  constructor(element, options = {}) {
    this.element = element;
    this.options = { ...Player.defaultOptions, ...options };
  }

  play() {
    if (this.isPlaying) {
      return this;
    }

    this.isPlaying = true;
    this._emit(Player.events.PLAY);

    return this;
  }

  _handleClick = (event) => {
    event.preventDefault();
    this.isPlaying ? this.pause() : this.play();
  };
}
```

---

## Guards — Early Returns

Guards are the primary tool for conditionals. Handle the unhappy path first, then continue with the happy path. Never use a ternary or long boolean chain where a guard would be clearer.

```js
// ✗ bad — nested, hard to scan
function getDisplayName(profile) {
  if (profile) {
    if (profile.displayName) {
      return profile.displayName;
    } else {
      return profile.email;
    }
  } else {
    return 'Anonymous';
  }
}

// ✓ good — each failure exits immediately
function getDisplayName(profile) {
  if (!profile) {
    return 'Anonymous';
  }

  if (!profile.displayName) {
    return profile.email;
  }

  return profile.displayName;
}
```

Replace ternary chains with guard + early return:

```js
// ✓ good — one exit per case, instantly scannable
function getStatusLabel(status) {
  if (status === 'active') {
    return 'Currently Active';
  }

  if (status === 'pending') {
    return 'Awaiting Approval';
  }

  return 'Inactive';
}
```

Replace long boolean chains with named guards:

```js
// ✓ good — each condition is its own guard
function canPublish(user, post) {
  if (!user.isLoggedIn) {
    return;
  }

  if (user.role !== 'editor') {
    return;
  }

  if (post.isLocked) {
    return;
  }

  if (post.authorId !== user.id) {
    return;
  }

  publish(post);
}
```

---

## Code Rhythm — Blank Lines

Blank lines group related lines into visual "paragraphs". Any time you switch mental context inside a function — from input extraction, to validation, to logic, to output — add a blank line.

```js
async function submitForm(formData) {
  // Extract and normalise inputs
  const name = formData.get('name').trim();
  const email = formData.get('email').trim().toLowerCase();
  const message = formData.get('message').trim();

  // Guard: all fields required
  if (!name || !email || !message) {
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
  if (!response.ok) {
    showError('Something went wrong. Please try again.');
    return;
  }

  // Success
  showSuccess('Message sent!');
  resetForm();
}
```

---

## Imports

- Explicit `.js` extensions on all ESM imports (even for TypeScript source).
- Group: external packages first, then internal modules, separated by a blank line.
- Named exports from library/utility files — no default exports.

```js
import { readFile } from 'node:fs/promises';
import { z } from 'zod';

import { parseConfig } from './config.js';
import { Logger } from './logger.js';
```

---

## Events

Custom events are namespaced with a colon: `'namespace:event'`.

```js
static get events() {
  return {
    CHANGE: 'carousel:change',
    LOADED: 'carousel:loaded',
  };
}
```

---

## JSDoc

Required on:
- All public class methods
- All exported functions in library/utility files
- Component props types (when not using TypeScript)
- Anything non-obvious

Optional on private methods with obvious signatures and internal helpers.

Include `@param`, `@returns` for non-obvious signatures. Add `@complexity O(n)` on non-trivial functions. Add `@throws` when a function can throw. Add `@example` for utility functions.

```js
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

## File Structure

Every file starts with a header comment on line 1:

```js
// user-service.js — handles user fetching, caching, and session management
```

Long files use section dividers:

```js
// ── Constants ──────────────────────────────────────────
// ── Helpers ────────────────────────────────────────────
// ── Public API ─────────────────────────────────────────
```

---

## Commenting

- **JSDoc** on all public functions, classes, and methods — describe intent, not implementation
- **Inline comments** only when intent is not obvious from reading the code
- Don't comment obvious code, don't leave commented-out code, don't restate code in English

```js
// Normalise scores before comparison — raw values vary wildly by category
// and would produce misleading rankings without this step.
const normalised = scores.map(normalise);
```

---

## SCSS

### Context
Personal projects use SCSS. Work projects match whatever the repo already uses (Tailwind, styled-components, NativeWind). Never mix approaches without asking.

### Patterns
- Deep nesting with `&` parent selectors
- CSS custom properties (`--token`) for design tokens
- SCSS `$variables` for computed values (e.g. `$pixel: 2px`)
- BEM-influenced class naming: `.block`, `.block__element`, `.block--modifier`
- `calc(var(--unit) * N)` for spacing — no magic numbers
- `will-change` always alongside `transition` on animated elements
- `translate3d` preferred over `translateX`/`translateY`

```scss
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

For pixel-art grids via `box-shadow`:

```scss
$pixel: 2px;

.pixel-icon {
  width: $pixel;
  height: $pixel;
  background: var(--color-primary);

  box-shadow:
    // Row 1
    calc($pixel * 1) 0               0 0 var(--color-primary),
    calc($pixel * 2) 0               0 0 var(--color-primary),
    // Row 2
    0                calc($pixel * 1) 0 0 var(--color-primary),
    calc($pixel * 3) calc($pixel * 1) 0 0 var(--color-primary);
}
```

---

## React / Components

### Atomic Design (loose)

| Layer        | Examples                        |
| ------------ | ------------------------------- |
| **Atoms**    | `Button`, `Input`, `Icon`       |
| **Molecules**| `SearchField`, `FormRow`        |
| **Organisms**| `Header`, `ProductCard`, `Form` |
| **Pages**    | `HomePage`, `ProfilePage`       |

### Component Rules

- Functional components with **named `function` declarations** — not arrow const.
- Props **destructured in the function signature**.
- One component per file. File named same as component in PascalCase.
- Import companion SCSS file at the top.

### Guards in Components

Handle missing data, loading, and edge cases at the top before rendering:

```jsx
function ProfilePage({ userId }) {
  const { data: user, isLoading, error } = useUser(userId);

  if (isLoading) {
    return <LoadingSpinner />;
  }

  if (error) {
    return <ErrorMessage message={error.message} />;
  }

  if (!user) {
    return <EmptyState message='User not found.' />;
  }

  return (
    <main className='profile-page'>
      <UserCard user={user} />
    </main>
  );
}
```
