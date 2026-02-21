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
```

## Code style

This project uses **strict GDScript type safety** - all warnings are treated as errors. Before submitting:

- All variables must have explicit type annotations (`var foo: String`) unless the type is clearly inferred with `:=`
- All function parameters and return types must be typed
- No unsafe casts, unsafe calls, or unsafe property access
- Use `class_name` for all classes
- Use `await` for async operations

Follow the patterns in existing API and entity files. The CI build will fail on any script error.

## Testing your changes

There are no automated unit tests — validation is done by building for all platforms and checking for script errors:

```bash
godot --headless --export-release 'Windows Desktop'
godot --headless --export-release 'macOS'
godot --headless --export-release 'Linux'
godot --headless --export-release 'Web'
```

The CI runs these checks automatically on every push. You can also test interactively using the sample scenes — the [Playground](addons/talo/samples/playground/playground.tscn) is the quickest way to exercise most APIs.

## Submitting a PR

- Keep PRs focused - one feature or fix per PR
- Test against at least one platform export before opening
- Target the `develop` branch
