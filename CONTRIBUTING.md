# Contributing

## Project structure

```
addons/talo/
├── apis/               # One file per API (extend TaloAPI)
├── entities/           # Data model classes (most extend TaloLoadable)
├── utils/              # Managers and helpers
├── samples/            # Sample scenes demonstrating features
├── talo_manager.gd     # Main autoload singleton (Talo.*)
├── talo_client.gd      # HTTP client wrapper
└── talo_settings.gd    # Add new settings here

test/                   # Unit tests (gdUnit4), mirror of addons/talo/
├── apis/
├── entities/
├── settings/
└── utils/
```

## Code style

This project uses **strict GDScript type safety** - all warnings are treated as errors. Before submitting:

- All variables must have explicit type annotations (`var foo: String`) unless the type is clearly inferred with `:=`
- All function parameters and return types must be typed
- No unsafe casts, unsafe calls, or unsafe property access
- Use `class_name` for all classes
- Use `await` for async operations

Follow the patterns in existing API and entity files. The CI build will fail on any script error.

## Formatting

GDScript is formatted with the [GDQuest GDScript Formatter](https://github.com/GDQuest/GDScript-formatter), configured through [.editorconfig](.editorconfig) (tabs, width 4). Format the plugin source before submitting:

```bash
gdscript-formatter addons/talo
```

To check without writing (fails if changes are needed):

```bash
gdscript-formatter --check addons/talo
```

## Testing your changes

Unit tests use [gdUnit4](https://github.com/MikeSchulze/gdUnit4) and live in [test/](test), mirroring the layout of `addons/talo`.

The GdUnit4 panel inside the editor allows you to run the existing tests. You may also want to consider adding your own tests for substantial contributions.

You can also test interactively using the sample scenes — the [Playground](addons/talo/samples/playground/playground.tscn) is the quickest way to exercise most APIs.

## Submitting a PR

- Keep PRs focused - one feature or fix per PR
- Test against at least one platform export before opening
- Target the `develop` branch
