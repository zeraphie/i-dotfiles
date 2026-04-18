// commitlint.config.js — conventional commits config
export default {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'body-max-line-length': [1, 'always', 100],
    'subject-case': [0], // don't enforce case
    'type-enum': [
      2,
      'always',
      ['feat', 'fix', 'chore', 'docs', 'refactor', 'test', 'style', 'ci', 'perf', 'revert']
    ]
  },
  ignores: [
    // Allow WIP commits to bypass rules
    (commit) => commit.startsWith('wip') || commit.startsWith('WIP')
  ]
};
