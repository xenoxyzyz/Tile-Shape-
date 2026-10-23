# QS Tile Shape — LineageOS 24 / Android 17

Lets the user change the Quick Settings tile shape:
**Dynamic / Rounded square (smooth) / Rounded square / Square / Circle**

Ported from Evolution X (cnb, Android 17) on 2026-10-20, adapted to be a
**tile-shape-only** port: Evolution X's other QS features (QS panel/classic
style, QS gradient, tile icon shape, label hide, haptic toggle) are NOT
included. Dry-run verified against the exact LineageOS `lineage-24.0`
sources; a full compile has not run yet.

## How it works
- `Settings.System.qs_tile_shape` holds the mode (0–4), default 0 (Dynamic).
- SystemUI `Tile.kt` observes it with a ContentObserver
  (`rememberTileShapeMode()`), and the tile corner radius / shape animates
  per mode. Small (icon-only) tiles use a true `CircleShape` in Circle mode;
  large labeled tiles get fully-rounded corners. Edit-mode previews follow
  the same setting.
- The option appears in **Settings → Display → Quick settings → Tile shape**.

## Contents
- `frameworks_base.patch`
  - `core/java/android/provider/Settings.java`: `QS_TILE_SHAPE` System key.
  - `packages/SystemUI/.../infinitegrid/Tile.kt`: `rememberTileShapeMode()`,
    shape mode threaded through `animateTileShapeAsState`/`animateShapeAsState`,
    Circle special-case for icon-only tiles.
- `packages_apps_Settings.patch` — `res/xml/display_settings.xml`: adds the
  Tile shape preference (new "Quick settings" category at the bottom).
- `files/` — new files at target paths:
  - `res/values/tile_shape_strings.xml`, `tile_shape_arrays.xml`
  - `src/org/lineageos/settings/preferences/SystemSettingListPreference.java`
    (NOTE: `lineageos.preference.LineageSystemSettingListPreference` can't be
    used — it writes to the LineageSettings provider table, not
    `Settings.System` which SystemUI reads.)

## Apply
From the top of the LOS tree (after sync, before lunch/brunch):
```bash
bash /path/to/apply-tile-shape.sh
```
Idempotent — safe to re-run; can be called from the build script after sync.

## Quick test without the UI
```bash
adb shell settings put system qs_tile_shape 4   # Circle
adb shell settings put system qs_tile_shape 0   # back to Dynamic
```
