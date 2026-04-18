// Component.jsx — template React component

import './Component.scss';

/**
 * Component — brief description of what this component does.
 *
 * @param {object}   props
 * @param {string}   props.title    - The title to display
 * @param {string}   [props.label]  - Optional label text
 * @param {boolean}  [props.active] - Whether the component is active
 * @param {Function} [props.onAction] - Callback fired when the action occurs
 * @returns {JSX.Element}
 */
export default function Component({ title, label = null, active = false, onAction = null }) {
  // ── Guards ─────────────────────────────────────────────────────────────────

  if(!title) {
    return null;
  }

  if(!active) {
    return (
      <div className="component component--inactive">
        <span className="component__title">{title}</span>
      </div>
    );
  }

  // ── Handlers ───────────────────────────────────────────────────────────────

  const handleAction = (event) => {
    if(!onAction) {
      return;
    }

    onAction(event);
  };

  // ── Render ─────────────────────────────────────────────────────────────────

  return (
    <div className="component component--active">
      <h2 className="component__title">{title}</h2>

      {label && (
        <p className="component__label">{label}</p>
      )}

      <button
        className="component__action"
        type="button"
        onClick={handleAction}
      >
        Activate
      </button>
    </div>
  );
}
