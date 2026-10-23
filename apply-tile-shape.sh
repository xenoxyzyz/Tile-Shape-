#!/bin/bash
# QS Tile Shape port for LineageOS 24 — apply script
# Usage: run from the TOP of the LOS source tree (after repo sync):
#     bash /path/to/apply-tile-shape.sh
# or pass the tree path:  bash apply-tile-shape.sh /path/to/los-tree
# Idempotent: safe to re-run.
set -e
PKG="$(cd "$(dirname "$0")" && pwd)"
TREE="${1:-$PWD}"
cd "$TREE"

echo ">>> Tree: $TREE"
echo ">>> [1/3] frameworks/base: patch Settings.java (QS_TILE_SHAPE) + SystemUI Tile.kt"
if grep -q "QS_TILE_SHAPE" frameworks/base/core/java/android/provider/Settings.java; then
    echo "    already patched, skipping"
else
    (cd frameworks/base && patch -p1 --forward < "$PKG/frameworks_base.patch")
fi

echo ">>> [2/3] packages/apps/Settings: new files"
mkdir -p packages/apps/Settings/res/values \
         packages/apps/Settings/src/org/lineageos/settings/preferences
cp -f "$PKG/files/packages/apps/Settings/res/values/tile_shape_strings.xml" \
      "$PKG/files/packages/apps/Settings/res/values/tile_shape_arrays.xml" \
      packages/apps/Settings/res/values/
cp -f "$PKG/files/packages/apps/Settings/src/org/lineageos/settings/preferences/SystemSettingListPreference.java" \
      packages/apps/Settings/src/org/lineageos/settings/preferences/

echo ">>> [3/3] packages/apps/Settings: patch res/xml/display_settings.xml"
if grep -q "qs_tile_shape" packages/apps/Settings/res/xml/display_settings.xml; then
    echo "    already patched, skipping"
else
    (cd packages/apps/Settings && patch -p1 --forward < "$PKG/packages_apps_Settings.patch")
fi

echo ">>> QS Tile Shape port applied. Verify:"
grep -c "QS_TILE_SHAPE" frameworks/base/core/java/android/provider/Settings.java
grep -c "rememberTileShapeMode" frameworks/base/packages/SystemUI/src/com/android/systemui/qs/panels/ui/compose/infinitegrid/Tile.kt
