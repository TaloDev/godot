# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the **Talo Godot Plugin** - a self-hostable game development backend plugin for the Godot Engine (v4.6+). Talo provides leaderboards, player authentication, event tracking, game saves, stats, channels, live config, and more. The plugin is distributed via the Godot Asset Library and GitHub releases.

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
   - Used by channels, player presence and player relationships

### API Layer

All API classes extend `TaloAPI` ([apis/api.gd](addons/talo/apis/api.gd)), which provides a `TaloClient` instance.

### Entity System

Entity classes in [addons/talo/entities/](addons/talo/entities/) represent API data models.

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
- All variables must be explicitly typed (`var foo: String`) unless their type can be easily inferred using the `:=` operator
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

## Important Notes

- **Process mode**: TaloManager uses `PROCESS_MODE_ALWAYS` ([talo_manager.gd](addons/talo/talo_manager.gd:48))
- **Auto accept quit**: Disabled to ensure proper flush on exit ([talo_manager.gd](addons/talo/talo_manager.gd:47))
- **Identity checks**: Most API operations require `Talo.players.identify()` first
- **Offline mode**: Setting `offline_mode = true` simulates no internet for testing
- **Debouncing**: Health checks, player updates, and save updates are debounced (configurable via `debounce_timer_seconds`)
- **Time scale**: Continuity manager and debounce timer ignore time scale for reliability
