# AGENTS.md

Klaus is an embeddable, ISO-aspirational Prolog interpreter in pure Ruby (v0.1.0).

## Project Goal

Provide a pure-Ruby Prolog engine that can be embedded in Ruby applications. Rules are defined as strings, parsed at runtime, and queried programmatically. No external binaries or FFI.

## Architecture

### Pipeline

```
Source string
      │
      ▼
┌─────────────┐
│   Parser    │  Parslet-based PEG parser
│  (Parslet)  │  KnowledgeBaseParser / QueryParser
└──────┬──────┘
       │  parse tree (nested hashes/arrays)
       ▼
┌─────────────┐
│ Transformer │  Parslet::Transform rules
└──────┬──────┘
       │  domain objects
       ▼
┌─────────────┐
│   Domain    │  Atom, Variable, AnonymousVariable,
│   Objects   │  Compound, Rule
└──────┬──────┘
       │  knowledge base + query
       ▼
┌─────────────┐
│   Unifier   │  SLD resolution + unification
│  (Solver)   │  recursive backtracking
└──────┬──────┘
       │
       ▼
  Solution Environments
  (variable bindings)
```

### Domain Model

| Class | File | Description |
|-------|------|-------------|
| `Atom` | `lib/klaus/atom.rb` | Prolog constant (e.g., `bob`). `Data.define(:value)`. |
| `Variable` | `lib/klaus/variable.rb` | Named variable (e.g., `X`). `Data.define(:name)`. |
| `AnonymousVariable` | `lib/klaus/anonymous_variable.rb` | The `_` wildcard. `Data.define` (no members). |
| `Compound` | `lib/klaus/compound.rb` | Term with functor + arguments (e.g., `parent(tom, bob)`). `Data.define(:functor, :arguments)`. |
| `Rule` | `lib/klaus/rule.rb` | Head + body (e.g., `mortal(X) :- human(X).`). `Data.define(:head, :body)`. |
| `Environment` | `lib/klaus/environment.rb` | Mutable hash mapping variable names to bound values. Cycle detection on resolution. |
| `ChoicePoint` | `lib/klaus/choice_point.rb` | Backtracking state. **Defined but not yet wired into the solver** — scaffolding for future iterative solver. |

### Parsing

Two entry points extending `PrologParser` (shared grammar):
- `KnowledgeBaseParser` — one or more clauses terminated by periods
- `QueryParser` — conjunction of goals separated by commas

`Transformer` converts parse trees to domain objects. `_` becomes `AnonymousVariable`.

### Unification

`Unifier#unify(term1, term2, env)`:
1. Anonymous variables match anything without binding
2. Resolve both terms through environment (follow variable chains)
3. Equal resolved terms succeed
4. Variable terms get bound
5. Compounds with same functor/arity: recursively unify arguments
6. Otherwise fail

**No occurs check** (intentional, matches SWI-Prolog default). `MAX_RECURSION_DEPTH = 100` prevents infinite recursion.

### Backtracking

Current: recursive Ruby call-stack backtracking. Future: iterative solver using `ChoicePoint` stack (removes depth limit, enables cut/negation).

## Key Files

| Path | Purpose |
|------|---------|
| `lib/klaus.rb` | Public API: `parse_knowledge_base`, `parse_query`, `solve` |
| `lib/klaus/unifier.rb` | Core solver — SLD resolution and unification |
| `lib/klaus/environment.rb` | Variable binding storage with cycle detection |
| `lib/klaus/prolog_parser.rb` | Base Parslet grammar |
| `lib/klaus/transformer.rb` | Parse tree → domain objects |
| `test/integration_test.rb` | End-to-end tests (family relationships, authorization) |

## Development

```bash
bundle install
bundle exec rake default    # runs bundle:audit, rubocop, and tests
bundle exec rake test        # tests only
DEBUG=1 bundle exec rake test  # with pry/pry-byebug loaded
```

## Testing Conventions

- Minitest, files in `test/**/*_test.rb`
- Helper functions `parse_prolog_program` and `solve_prolog_query` in `test/test_helper.rb`
- Data classes (Atom, Variable, etc.) have dedicated unit tests
- Parser tests verify structure of transformed output
- Integration tests use realistic Prolog programs

## What's Not Implemented Yet

Arithmetic, lists, cut, negation-as-failure, control constructs, built-in predicates, I/O, exceptions. See README.md for the full list.
