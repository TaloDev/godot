# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the **Talo Godot Plugin** - a self-hostable game development backend plugin for the Godot Engine (v4.4+). Talo provides leaderboards, player authentication, event tracking, game saves, stats, channels, live config, and more. The plugin is distributed via the Godot Asset Library and GitHub releases.

## Development Commands

### Building & Testing
```bash
# Export for all platforms (runs on push via CI)
godot --headless --export-release 'Windows Desktop'
godot --headless --export-release 'macOS'
godot --headless --export-release 'Linux'
godot --headless --export-release 'Web'

# The CI checks for SCRIPT ERROR in build output and fails if found
```

### Running Samples
The project includes sample scenes demonstrating plugin features. The main scene is configured as `res://addons/talo/samples/playground/playground.tscn`. To test samples, change the main scene in [project.godot](project.godot) or run scenes directly from the editor.

Available samples:
- **Playground**: Text-based playground for testing identify, events, stats, leaderboards
- **Authentication**: Registration/login/account management flow
- **Leaderboards**: Basic leaderboard UI
- **Multi-scene saves**: Persist save data across multiple scenes
- **Persistent buttons**: Simple save/load demo
- **Chat**: Real-time messaging using channels
- **Channel storage**: Shared player data storage

## Architecture

### Core Structure

The plugin is an **autoload singleton** called `Talo` (defined in [talo_manager.gd](addons/talo/talo_manager.gd:20)) that initializes on `_ready()` and provides access to all APIs, settings, and utilities.

**Key architectural components:**

1. **TaloManager** ([talo_manager.gd](addons/talo/talo_manager.gd)) - Main autoload singleton
   - Initializes all API instances, crypto manager, continuity manager, and socket
   - Manages current player/alias state
   - Emits `init_completed`, `connection_lost`, and `connection_restored` signals
   - Handles app quit and focus events to flush pending data

2. **TaloClient** ([talo_client.gd](addons/talo/talo_client.gd)) - HTTP client wrapper
   - Used by all API classes (via [apis/api.gd](addons/talo/apis/api.gd))
   - Builds authenticated requests with proper headers (access key, player/alias/session tokens)
   - Logs requests/responses if enabled in settings
   - Triggers continuity system on failed requests
   - Version: Auto-updated by pre-commit hook

3. **TaloSettings** ([talo_settings.gd](addons/talo/talo_settings.gd)) - Configuration management
   - Reads/writes [settings.cfg](addons/talo/settings.cfg)
   - Key settings: `access_key`, `api_url`, `socket_url`, `auto_connect_socket`, `continuity_enabled`, `debounce_timer_seconds`
   - Auto-creates settings.cfg with defaults if missing
   - Feature tags: `talo_dev` (force debug), `talo_live` (force release)

4. **Continuity System** ([utils/continuity_manager.gd](addons/talo/utils/continuity_manager.gd)) - Offline resilience
   - Automatically retries failed POST/PUT/PATCH/DELETE requests
   - Excludes: health checks, auth, identify, socket tickets
   - Stores encrypted requests in `user://tc.bin`
   - Replays up to 10 requests every 10 seconds when online
   - Ignores time scale for reliability

5. **TaloSocket** ([talo_socket.gd](addons/talo/talo_socket.gd)) - WebSocket communication
   - Connects to `wss://api.trytalo.com` by default
   - Requires ticket creation via [socket_tickets_api.gd](addons/talo/apis/socket_tickets_api.gd)
   - Handles player identification with socket token
   - Polls in `_process()` loop
   - Used by channels, player presence, and custom real-time features

### API Layer

All API classes extend `TaloAPI` ([apis/api.gd](addons/talo/apis/api.gd)), which provides a `TaloClient` instance. There are 14 API classes:

- [players_api.gd](addons/talo/apis/players_api.gd) - Player identification and management
- [player_auth_api.gd](addons/talo/apis/player_auth_api.gd) - Authentication and sessions
- [events_api.gd](addons/talo/apis/events_api.gd) - Event tracking
- [stats_api.gd](addons/talo/apis/stats_api.gd) - Player and global stats
- [leaderboards_api.gd](addons/talo/apis/leaderboards_api.gd) - Leaderboard management
- [saves_api.gd](addons/talo/apis/saves_api.gd) - Game save operations
- [feedback_api.gd](addons/talo/apis/feedback_api.gd) - Player feedback collection
- [game_config_api.gd](addons/talo/apis/game_config_api.gd) - Live config
- [health_check_api.gd](addons/talo/apis/health_check_api.gd) - Connectivity checks (debounced)
- [player_groups_api.gd](addons/talo/apis/player_groups_api.gd) - Player grouping
- [channels_api.gd](addons/talo/apis/channels_api.gd) - Real-time messaging
- [socket_tickets_api.gd](addons/talo/apis/socket_tickets_api.gd) - Socket authentication
- [player_presence_api.gd](addons/talo/apis/player_presence_api.gd) - Online status

### Entity System

18 entity classes in [addons/talo/entities/](addons/talo/entities/) represent API data models. Key entities:
- `TaloPlayer` - Player data with props
- `TaloPlayerAlias` - Player identity/device association
- `TaloLeaderboardEntry` - Leaderboard scores
- `TaloGameSave` - Saved game state
- `TaloLiveConfig` - Dynamic configuration
- `TaloChannel` - Real-time messaging channels

Most entities extend `TaloLoadable` ([entities/loadable.gd](addons/talo/entities/loadable.gd)) which provides JSON serialization and `from_api()` factory methods.

### Utilities

Key utilities in [addons/talo/utils/](addons/talo/utils/):
- **SavesManager** - Handles save CRUD, caching, offline support
- **LeaderboardEntriesManager** - Manages leaderboard entry state
- **ChannelStorageManager** - Manages channel-based shared storage
- **CryptoManager** - Encryption key generation/storage for offline data
- **SessionManager** - Session token persistence
- **DebounceTimer** - Debounces health checks, player updates, save updates (1s default, configurable via `debounce_timer_seconds`)

## GDScript Standards

This project enforces **strict type safety** - all warnings are set to error level (2) in [project.godot](project.godot:24-58):
- All variables must be explicitly typed (`var foo: String`)
- No inferred declarations
- No unsafe property/method access
- No unsafe casts or call arguments
- All function parameters and return types must be typed

When writing code:
- Always use explicit type annotations
- Use `class_name` for all classes
- Prefer `await` for async operations (avoid `yield`)
- Follow existing patterns in API/entity/utility files

## Plugin Configuration

The plugin autoload is configured in [project.godot](project.godot:20):
```
Talo="*res://addons/talo/talo_manager.gd"
```

Settings are in [addons/talo/settings.cfg](addons/talo/settings.cfg) - this file is auto-generated and should be filled with the user's access key.

## CI/CD

GitHub Actions workflows in [.github/workflows/](/.github/workflows/):
- **ci.yml** - Runs on every push, exports for all platforms, fails on script errors
- **create-release.yml** - Automates releases
- **tag.yml** - Handles version tagging
- **claude-code-review.yml** - Automated code review

## Important Notes

- **Process mode**: TaloManager uses `PROCESS_MODE_ALWAYS` ([talo_manager.gd](addons/talo/talo_manager.gd:48))
- **Auto accept quit**: Disabled to ensure proper flush on exit ([talo_manager.gd](addons/talo/talo_manager.gd:47))
- **Identity checks**: Most API operations require `Talo.players.identify()` first
- **Offline mode**: Setting `offline_mode = true` simulates no internet for testing
- **Debouncing**: Health checks, player updates, and save updates are debounced (configurable via `debounce_timer_seconds`)
- **Time scale**: Continuity manager and debounce timer ignore time scale for reliability
