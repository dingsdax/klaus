# Klaus - an embeddable, ISO-aspirational Prolog interpreter in pure Ruby

<p align="center">
  <img src="docs/klaus.png" alt="Klaus the mountain goat" width="250">
</p>

[![CI](https://github.com/dingsdax/klaus/actions/workflows/ci.yml/badge.svg)](https://github.com/dingsdax/klaus/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/Klaus.svg)](https://badge.fury.io/rb/Klaus)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Klaus lets you define logical rules as data and query them at runtime. No external binaries, no FFI, no DSLs, just strings in, answers out.

## Installation

Add to your Gemfile:

```ruby
gem 'Klaus'
```

Or install directly:

```
gem install Klaus
```

## Quick Start

```ruby
require 'klaus'

# Define a knowledge base
kb = Klaus.parse_knowledge_base(<<~PROLOG)
  parent(john, bob).
  parent(john, lisa).
  parent(bob, ann).
  parent(bob, carl).

  grandparent(X, Z) :- parent(X, Y), parent(Y, Z).
PROLOG

# Query for direct relationships
query = Klaus.parse_query('parent(john, X)')
solutions = Klaus.solve(kb, query)
# => [{X: Atom("bob")}, {X: Atom("lisa")}]

# Query with rule resolution
query = Klaus.parse_query('grandparent(john, Z)')
solutions = Klaus.solve(kb, query)
# => [{Z: Atom("ann")}, {Z: Atom("carl")}]
```

## API

| Method | Description |
|--------|-------------|
| `Klaus.parse_knowledge_base(string)` | Parse a Prolog program (facts and rules) into its internal representation |
| `Klaus.parse_query(string)` | Parse a Prolog query into its internal representation |
| `Klaus.solve(knowledge_base, goals)` | Execute a query against a knowledge base, returns an array of solution environments |

## Architecture

See [AGENTS.md](AGENTS.md) for details.

## Current Limitations

The following ISO Prolog features are not yet implemented:

- Arithmetic (`is/2`, comparison operators)
- Lists (`[H|T]` syntax)
- Cut (`!`) and negation-as-failure (`\+`)
- Control constructs (`->`, `;`)
- Built-in predicates (`var/1`, `atom/1`, `findall/3`, etc.)
- I/O streams
- Exception handling (`catch/3`, `throw/1`)
- Occurs check (omitted intentionally, matching SWI-Prolog's default behavior)

## Potential Use Cases

An embeddable Prolog system offers a different way to structure logic: rules are treated as data rather than hard-coded into the application. This makes it possible to store them in databases or config files, edit them without touching the codebase, and update them without redeploying.

In practice, this can simplify things like access control, where permissions are expressed as rules instead of nested conditionals. It can also help with configuration validation, modeling decision logic in expert systems, or exploring data dependencies.

Because the rules are declarative and readable, they’re often easier to review, adjust, and extend. It can also make it more approachable to experiment with logic programming or apply it to areas like game AI, where exploring different outcomes is useful.

## Related Projects

- [ruby-prolog](https://github.com/preston/ruby-prolog) — Prolog-like DSL for Ruby with inline logic programming. Actively maintained, used in production for access control and layout engines.
- [porolog](https://github.com/wizardofosmium/porolog) — Prolog using plain old Ruby objects, designed to embed logic queries in regular Ruby programs.
- [upl](https://github.com/djellemah/upl) — FFI bridge to SWI-Prolog. Different approach: wraps a full Prolog runtime rather than reimplementing in Ruby.

Klaus differs by parsing standard Prolog syntax (not a Ruby DSL) and aiming for ISO compliance.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Why "Klaus"?

Prolog is based on [Horn clauses](https://en.wikipedia.org/wiki/Horn_clause). Say "clauses" with a German accent and you get Klaus. Naturally, Klaus is a mountain goat with ... 🎉 ... horns 🤦🐐!

## License

[MIT](LICENSE)
