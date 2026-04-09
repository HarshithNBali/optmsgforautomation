# App Icon Generation Guide

## Source Files

All source icons live in `assets/icons/`. Do not rename these files — the generation script depends on these exact names.

| Flavor | iOS source | Android foreground | Android background | Android monochrome |
|--------|-----------|-------------------|-------------------|-------------------|
| Prod   | `Icon-OptMsg.png` | `Icon-OptMsg-Foreground.png` | `Icon-OptMsg-Background.png` | `Icon-OptMsg-Monochrome.png` |
| Stage  | `Icon-OptMsg-Stg.png` | `Icon-OptMsg-Stg-Foreground.png` | `Icon-OptMsg-Stg-Background.png` | `Icon-OptMsg-Stg-Monochrome.png` |
| Dev    | `Icon-OptMsg-Dev.png` | `Icon-OptMsg-Dev-Foreground.png` | `Icon-OptMsg-Dev-Background.png` | `Icon-OptMsg-Dev-Monochrome.png` |

All source images must be **1024×1024px RGBA PNG**.

---

## Output Destinations

### iOS

| Flavor | Appiconset path | Naming scheme |
|--------|----------------|---------------|
| Prod   | `ios/Runner/Assets.xcassets/AppIcon-prod.appiconset/` | `Icon-App-{W}x{H}@{S}x.png` |
| Stage  | `ios/Runner/Assets.xcassets/AppIcon-Stage.appiconset/` | `AppIcon-*.png` |
| Dev    | `ios/Runner/Assets.xcassets/AppIcon-Dev.appiconset/` | `AppIcon-*.png` |

iOS icons are flattened to **RGB (no alpha channel)** — Apple rejects marketing icons with an alpha channel.

### Android

Adaptive layers go in each `android/app/src/main/res/mipmap-{density}/` folder.
The adaptive icon XML files are in `android/app/src/main/res/mipmap-anydpi-v26/`.

| Flavor | XML file | Layer prefix |
|--------|----------|-------------|
| Prod   | `launcher_icon.xml` | `launcher_icon` |
| Stage  | `launcher_icon_stage.xml` | `launcher_icon_stage` |
| Dev    | `launcher_icon_dev.xml` | `launcher_icon_dev` |

Each prefix generates three adaptive files per density:
- `{prefix}_foreground.png` — logo on transparent background, padded for safe zone
- `{prefix}_background.png` — gradient/brand background, fills full canvas
- `{prefix}_monochrome.png` — grayscale silhouette on transparent background, same padding as foreground

Plus one legacy file per density:
- `{prefix}.png` (e.g. `launcher_icon_stage.png`) — full composite icon, RGB, for pre-API 26 devices

---

## Android Adaptive Icon Safe Zone

Android launchers crop icons to a mask (circle, squircle, rounded square). The safe zone is the **inner 66.67%** of the 108dp canvas. Content in the outer ~17% on each side may be clipped.

**Foreground/monochrome scale factors used** (applied to the full source image before centering on canvas):

| Flavor | Scale | Reason |
|--------|-------|--------|
| Prod   | 60%   | Prod foreground content fills ~68% of source |
| Stage  | 55%   | Stage foreground content fills ~83% of source (taller due to STG badge) |
| Dev    | 55%   | Dev foreground content fills ~83% of source |

Background layer always fills 100% of canvas (no safe zone padding needed — background colour behind the mask edge is fine).

### Android density canvas sizes

| Density | Adaptive canvas | Legacy icon |
|---------|----------------|-------------|
| mdpi    | 108×108px      | 48×48px     |
| hdpi    | 162×162px      | 72×72px     |
| xhdpi   | 216×216px      | 96×96px     |
| xxhdpi  | 324×324px      | 144×144px   |
| xxxhdpi | 432×432px      | 192×192px   |

---

## Regeneration Script

Requires Python 3 with Pillow. If Pillow is not installed:

```bash
python3 -m venv /tmp/icon_venv && /tmp/icon_venv/bin/pip install --quiet Pillow
```

Run the full regeneration (all flavors, iOS + Android):

```python
/tmp/icon_venv/bin/python3 << 'EOF'
from PIL import Image
import os

ICONS_DIR = 'assets/icons'
IOS_BASE  = 'ios/Runner/Assets.xcassets'
AND_BASE  = 'android/app/src/main/res'

def ios_flatten(src, size):
    img = src.resize((size, size), Image.LANCZOS)
    bg  = Image.new('RGB', (size, size), (255, 255, 255))
    bg.paste(img, mask=img.split()[3] if img.mode == 'RGBA' else None)
    return bg

STAGE_DEV_ICONS = {
    'AppIcon@2x.png': 120,        'AppIcon@3x.png': 180,
    'AppIcon~ipad.png': 76,       'AppIcon@2x~ipad.png': 152,
    'AppIcon-83.5@2x~ipad.png': 167,
    'AppIcon-40@2x.png': 80,      'AppIcon-40@3x.png': 120,
    'AppIcon-40~ipad.png': 40,    'AppIcon-40@2x~ipad.png': 80,
    'AppIcon-20@2x.png': 40,      'AppIcon-20@3x.png': 60,
    'AppIcon-20~ipad.png': 20,    'AppIcon-20@2x~ipad.png': 40,
    'AppIcon-29.png': 29,         'AppIcon-29@2x.png': 58,  'AppIcon-29@3x.png': 87,
    'AppIcon-29~ipad.png': 29,    'AppIcon-29@2x~ipad.png': 58,
    'AppIcon-60@2x~car.png': 120, 'AppIcon-60@3x~car.png': 180,
    'AppIcon~ios-marketing.png': 1024,
}

PROD_ICONS = {
    'Icon-App-20x20@1x.png': 20,  'Icon-App-20x20@2x.png': 40,  'Icon-App-20x20@3x.png': 60,
    'Icon-App-29x29@1x.png': 29,  'Icon-App-29x29@2x.png': 58,  'Icon-App-29x29@3x.png': 87,
    'Icon-App-40x40@1x.png': 40,  'Icon-App-40x40@2x.png': 80,  'Icon-App-40x40@3x.png': 120,
    'Icon-App-50x50@1x.png': 50,  'Icon-App-50x50@2x.png': 100,
    'Icon-App-57x57@1x.png': 57,  'Icon-App-57x57@2x.png': 114,
    'Icon-App-60x60@2x.png': 120, 'Icon-App-60x60@3x.png': 180,
    'Icon-App-72x72@1x.png': 72,  'Icon-App-72x72@2x.png': 144,
    'Icon-App-76x76@1x.png': 76,  'Icon-App-76x76@2x.png': 152,
    'Icon-App-83.5x83.5@2x.png': 167,
    'Icon-App-1024x1024@1x.png': 1024,
}

ADAPTIVE = {'mdpi': 108, 'hdpi': 162, 'xhdpi': 216, 'xxhdpi': 324, 'xxxhdpi': 432}
LEGACY   = {'mdpi': 48,  'hdpi': 72,  'xhdpi': 96,  'xxhdpi': 144, 'xxxhdpi': 192}

def gen_adaptive(fg_src, bg_src, mono_src, prefix, scale):
    for density, canvas in ADAPTIVE.items():
        scaled = int(canvas * scale)
        offset = (canvas - scaled) // 2
        fg = Image.new('RGBA', (canvas, canvas), (0,0,0,0))
        fg.paste(fg_src.resize((scaled, scaled), Image.LANCZOS), (offset, offset))
        fg.save(f'{AND_BASE}/mipmap-{density}/{prefix}_foreground.png', 'PNG')
        bg_src.resize((canvas, canvas), Image.LANCZOS).save(f'{AND_BASE}/mipmap-{density}/{prefix}_background.png', 'PNG')
        mono = Image.new('RGBA', (canvas, canvas), (0,0,0,0))
        mono.paste(mono_src.resize((scaled, scaled), Image.LANCZOS), (offset, offset))
        mono.save(f'{AND_BASE}/mipmap-{density}/{prefix}_monochrome.png', 'PNG')

def gen_legacy(composite_src, filename):
    for density, size in LEGACY.items():
        img = composite_src.resize((size, size), Image.LANCZOS)
        bg  = Image.new('RGB', (size, size), (255, 255, 255))
        bg.paste(img, mask=img.split()[3] if img.mode == 'RGBA' else None)
        bg.save(f'{AND_BASE}/mipmap-{density}/{filename}', 'PNG')

# PROD
prod_src = Image.open(f'{ICONS_DIR}/Icon-OptMsg.png')
for fname, size in PROD_ICONS.items():
    ios_flatten(prod_src, size).save(f'{IOS_BASE}/AppIcon-prod.appiconset/{fname}', 'PNG')
gen_adaptive(Image.open(f'{ICONS_DIR}/Icon-OptMsg-Foreground.png'), Image.open(f'{ICONS_DIR}/Icon-OptMsg-Background.png'), Image.open(f'{ICONS_DIR}/Icon-OptMsg-Monochrome.png'), 'launcher_icon', scale=0.60)
gen_legacy(prod_src, 'launcher_icon.png')

# STAGE
stg_src = Image.open(f'{ICONS_DIR}/Icon-OptMsg-Stg.png')
for fname, size in STAGE_DEV_ICONS.items():
    ios_flatten(stg_src, size).save(f'{IOS_BASE}/AppIcon-Stage.appiconset/{fname}', 'PNG')
gen_adaptive(Image.open(f'{ICONS_DIR}/Icon-OptMsg-Stg-Foreground.png'), Image.open(f'{ICONS_DIR}/Icon-OptMsg-Stg-Background.png'), Image.open(f'{ICONS_DIR}/Icon-OptMsg-Stg-Monochrome.png'), 'launcher_icon_stage', scale=0.55)
gen_legacy(stg_src, 'launcher_icon_stage.png')

# DEV
dev_src = Image.open(f'{ICONS_DIR}/Icon-OptMsg-Dev.png')
for fname, size in STAGE_DEV_ICONS.items():
    ios_flatten(dev_src, size).save(f'{IOS_BASE}/AppIcon-Dev.appiconset/{fname}', 'PNG')
gen_adaptive(Image.open(f'{ICONS_DIR}/Icon-OptMsg-Dev-Foreground.png'), Image.open(f'{ICONS_DIR}/Icon-OptMsg-Dev-Background.png'), Image.open(f'{ICONS_DIR}/Icon-OptMsg-Dev-Monochrome.png'), 'launcher_icon_dev', scale=0.55)
gen_legacy(dev_src, 'launcher_icon_dev.png')

print('Done!')
EOF
```

> Run from the project root (`app/`). Use absolute paths if running from elsewhere.

---

## After Updating Icons

### iOS
No extra steps — icons are compiled into the app bundle automatically.

### Android
Uninstall the app from the device before reinstalling — Android caches the launcher icon at install time and will not update it on a re-run:

```bash
adb uninstall com.optmsg.stag   # or com.optmsg.mail / com.optmsg.dev
flutter run --flavor stage       # or prod / dev
```

On emulators, a **cold boot** may be needed (`AVD Manager → ▼ → Cold Boot Now`) after uninstalling.

---

## iOS App Store Requirement

The 1024×1024 marketing icon (`AppIcon~ios-marketing.png` / `Icon-App-1024x1024@1x.png`) **must not contain an alpha channel**. The script handles this automatically by flattening onto a white background. If you ever generate icons manually, run:

```bash
sips -g hasAlpha path/to/icon.png
```

The value must be `no`. If it says `yes`, the App Store upload will be rejected.
