# 🎬 DISPLAY SETTINGS GUIDE — 16:9 FOR ALL PLATFORMS
## Complete Configuration for Desktop & Mobile

**Project:** Undertale Visual Novel (Godot 4.6.2)  
**Focus:** Ensuring True 16:9 Aspect Ratio Across All Devices  
**Date:** April 18, 2026

---

## 🎯 THE CORE PROBLEM (FIXED)

### What Was Wrong
```
Original project.godot settings:
window/size/viewport_width=1280
window/size/viewport_height=780

Math:  1280 ÷ 780 = 1.641:1
16:9 should be: 16 ÷ 9 = 1.777:1

DIFFERENCE: 1.641 vs 1.777 = 0.136 units
This is a 7.6% distortion! ❌
```

### Why This Matters
- **Desktop:** Game appears horizontally stretched
- **Mobile (portrait):** Game is squished, UI is cramped
- **Tablet (landscape):** Inconsistent scaling
- **Overall:** No uniform experience across devices

### The Solution
```
New project.godot settings:
window/size/viewport_width=1920
window/size/viewport_height=1080

Math:  1920 ÷ 1080 = 1.777:1
16:9 should be: 16 ÷ 9 = 1.777:1

MATCH: Perfect 16:9 ✅
```

---

## ⚙️ COMPLETE CONFIGURATION REFERENCE

### In project.godot File

```ini
[display]

# VIEWPORT SIZE (Internal render resolution)
window/size/viewport_width=1920
window/size/viewport_height=1080

# WINDOW PROPERTIES (What players see)
window/size/window_width_override=0        # 0 = use device size
window/size/window_height_override=0       # 0 = use device size
window/size/resizable=true                 # Allow window resizing
window/size/mode=0                         # WINDOWED (0), FULLSCREEN (1)
window/size/always_on_top=false            # Don't force window on top
window/size/transparent_background=false   # No transparency
window/size/borderless=false               # Show window borders

# STRETCHING/SCALING (CRITICAL)
window/stretch/mode="canvas_items"         # Scale UI and game elements
window/stretch/aspect="keep_size"          # ⭐ MAINTAIN 16:9 ON ALL DEVICES
window/stretch/scale=1.0                   # Base scale multiplier

# VISUAL FEATURES
window/handheld/use_dynamic_scale=false    # Mobile: Don't auto-scale
window/hdr_2d=false                        # No HDR rendering
window/transparent_background=false        # Solid background
```

### What Each Setting Does

#### `window/size/viewport_width & viewport_height`
```
These define the INTERNAL CANVAS SIZE
(What Godot renders internally)

1920x1080 = Full HD resolution
- Standard for desktop games
- Good balance of detail vs performance
- Divisible by common mobile resolutions

If you change this:
- All UI scales relative to this size
- Higher = sharper on desktop, slower on mobile
- Lower = blurrier on desktop, faster on mobile
```

#### `window/stretch/mode="canvas_items"`
```
Tells Godot how to scale the internal canvas

Options:
- "disabled":      No scaling (viewport fills screen)
- "canvas_items":  Scale game elements (⭐ recommended)
- "viewport":      Scale entire render target
```

#### `window/stretch/aspect="keep_size"`
```
THE MOST IMPORTANT SETTING FOR 16:9 CONSISTENCY

Options:
- "ignore":        Ignore viewport aspect, just fill screen
- "keep":          Maintain aspect ratio, add letterbox
- "keep_width":    Keep width, change height
- "keep_height":   Keep height, change width
- "expand":        Fill screen (can distort)
- "keep_size":     ⭐ Maintain aspect with optimal scaling

"keep_size" DOES:
✅ Maintains 1.777:1 aspect ratio
✅ Adds black bars if needed (letterbox)
✅ Scales up to fill available space
✅ Never distorts game content

This is CRITICAL for mobile!
```

#### `window/stretch/scale=1.0`
```
Multiplier for the final scale

1.0 = Normal size
0.5 = Half size (sharper, faster)
2.0 = Double size (more pixelated)

Usually keep at 1.0 unless optimizing
```

---

## 📱 HOW THIS WORKS ON DIFFERENT DEVICES

### Desktop Computer (1920x1080 monitor)

```
┌─────────────────────────────────┐
│  Monitor: 1920x1080 (16:9)      │
├─────────────────────────────────┤
│                                 │
│  Godot Viewport: 1920x1080      │
│  ┌───────────────────────────┐  │
│  │                           │  │
│  │  Game renders at 1920x1080│  │
│  │  (Full screen, no bars)   │  │
│  │                           │  │
│  └───────────────────────────┘  │
│                                 │
└─────────────────────────────────┘

Result: Perfect 1:1 mapping
Aspect: 16:9 ✅
Quality: Native resolution ✅
```

### Desktop Computer (1280x720 monitor)

```
┌──────────────────────────┐
│  Monitor: 1280x720 (16:9)│
├──────────────────────────┤
│                          │
│ Godot Internal: 1920x1080│
│ Scales down to: 1280x720 │
│                          │
│ ┌──────────────────────┐ │
│ │   Game at 1280x720   │ │
│ │  (Full screen)       │ │
│ └──────────────────────┘ │
│                          │
└──────────────────────────┘

Result: 1920x1080 scaled down to 1280x720
Aspect: 16:9 ✅ (maintained)
Quality: Slightly blurrier (expected) ✅
```

### Smartphone Portrait (1080x1920)

```
┌────────────────┐
│ Phone Portrait:│
│ 1080x1920 (9:16)
├────────────────┤
│ ██████████████ │  ← Black bar (letterbox)
│ ██            ██│
│ ██            ██│  ← Game content
│ ██  1080x607  ██│     (16:9 ratio)
│ ██            ██│
│ ██            ██│
│ ██████████████ │  ← Black bar (letterbox)
│                │
│ Calculation:   │
│ Phone height=1920px
│ Game width=1080px
│ Game height=1080÷(16/9)=607px
│ Top bar=(1920-607)/2=656px
│
│ Aspect maintained: 1080÷607=1.777:1 ✅
└────────────────┘

Result: Portrait displays game at 16:9 with black bars
Aspect: 16:9 ✅ (maintained perfectly)
UX: Expected for portrait mode ✅
```

### Tablet Landscape (2560x1600)

```
┌────────────────────────────────┐
│  Tablet Landscape: 2560x1600   │
│  (16:10 aspect, wider than 16:9)
├────────────────────────────────┤
│                                │
│  ┌──────────────────────────┐  │ ← Black bars
│  │                          │  │    (side pillar)
│  │   1600x900 game content  │  │
│  │   (16:9 ratio)           │  │
│  │                          │  │
│  └──────────────────────────┘  │
│                                │ ← Black bars
│
│ Calculation:
│ Device width = 2560, height = 1600
│ Maintain 16:9: game height = 1600
│ Game width = 1600×(16/9) = 2844px
│ Wait, that's too wide!
│
│ So: use width = 2560
│ Game height = 2560÷(16/9) = 1440px
│ Side bars = (1600-1440)/2 = 80px each
│
│ Aspect: 2560÷1440 = 1.777:1 ✅
└────────────────────────────────┘

Result: Landscape maintains 16:9 with side bars
Aspect: 16:9 ✅ (maintained perfectly)
UX: Professional look ✅
```

---

## 🔧 STEP-BY-STEP: SETTING UP IN GODOT EDITOR

### Method 1: Via GUI (Recommended)

**Step 1:** Open Project Settings
```
Godot Menu → Project → Project Settings
```

**Step 2:** Navigate to Display section
```
Left panel → Search: "window"
OR manually expand: Display → Window
```

**Step 3:** Set Viewport Size
```
Display → Window → Size

[✓] Viewport Width     → 1920
[✓] Viewport Height    → 1080
```

**Step 4:** Set Stretching
```
Display → Window → Stretch

[✓] Mode              → canvas_items
[✓] Aspect            → keep_size    ⭐ CRITICAL
[✓] Scale             → 1.0
```

**Step 5:** Close and Re-run
```
File → Close settings dialog
F5 to test project
```

### Method 2: Direct File Edit

**Step 1:** Locate project.godot
```
In your project folder: project.godot
Open with text editor (not Word!)
```

**Step 2:** Find [display] section
```
Search for: [display]
Should be around line 30
```

**Step 3:** Replace entire section
```
[display]

window/size/viewport_width=1920
window/size/viewport_height=1080
window/stretch/mode="canvas_items"
window/stretch/aspect="keep_size"
window/hdr_2d=false
window/transparent_background=false
```

**Step 4:** Save and reload
```
Ctrl+S to save
Switch back to Godot
Godot will reimport automatically
```

---

## 📊 ASPECT RATIO MATHEMATICS

### Understanding 16:9

```
16:9 = Ratio of width to height
16 ÷ 9 = 1.777:1

Common 16:9 Resolutions:
- 1920 × 1080  (Full HD)    → 1920÷1080 = 1.777 ✅
- 1280 × 720   (HD)         → 1280÷720 = 1.777 ✅
- 2560 × 1440  (2K)         → 2560÷1440 = 1.777 ✅
- 3840 × 2160  (4K)         → 3840÷2160 = 1.777 ✅
- 960 × 540    (qHD)        → 960÷540 = 1.777 ✅

Non-16:9 (WRONG):
- 1280 × 780   (old setting) → 1280÷780 = 1.641 ❌
- 1024 × 768   (4:3)         → 1024÷768 = 1.333 ❌
- 1080 × 1920  (portrait 9:16)→ 1080÷1920 = 0.5625 ❌
```

### Checking Your Aspect Ratio

```
Formula: Width ÷ Height = Aspect Ratio

Your setting: 1920 ÷ 1080 = 1.777
Target:                      1.777
Match? YES ✅

To fix any resolution to 16:9:
Height_needed = Width ÷ 1.777
OR
Width_needed = Height × 1.777

Example: Screen is 1440 pixels wide
Height = 1440 ÷ 1.777 = 810 pixels
(1440x810 = 16:9 ✅)
```

---

## 🌍 DEVICE-SPECIFIC CONFIGURATIONS

### Android Export

Go to: `Project` → `Export` → `Android`

Set these:
```
Device Orientation:
  [✓] Landscape
  [✓] Portrait (if supporting mobile)

Min SDK: 21 (Android 5.0)
Target SDK: 34 (Android 14)

Screen Orientation: 
  Choose: Landscape (if forcing landscape)
  OR: Sensor (for both portrait + landscape)
```

**With stretch/aspect="keep_size":**
- Landscape: Game fills screen at 16:9
- Portrait: Game letterboxes at 16:9 with black bars

### iOS Export

Go to: `Project` → `Export` → `iOS`

Set these:
```
Device Family: iPhone, iPad

Supported Orientations:
  [✓] Portrait
  [✓] Landscape
  [✓] Reverse Landscape

Scale Mode: 2x (for retina display)
```

---

## 🔍 TESTING YOUR ASPECT RATIO

### On Desktop

```
Method 1: Run in Window Mode
1. Resize game window manually
2. Notice: game maintains 16:9 with black bars
3. Verify: no stretching or squishing

Method 2: Run in Fullscreen
1. F11 to toggle fullscreen
2. Check if aspect maintained on your monitor

Method 3: Check Output Console
Run game and look for:
  "Godot Engine v4.6.2 running"
  No aspect ratio warnings
```

### On Mobile (Android)

```
Method 1: Build APK
1. Export → Android → Build APK
2. Transfer to phone
3. Install and run

Method 2: Test In Both Orientations
Portrait:
- Game should show with black bars top/bottom
- Content should not be squished
- UI should be readable

Landscape:
- Game should fill screen
- Maintain 16:9 ratio
- UI should not be stretched

Method 3: Visual Check
Take screenshots and measure:
- Width ÷ Height should = 1.777
- No visible stretching or compression
```

---

## ⚠️ COMMON MISTAKES & HOW TO FIX THEM

### Mistake 1: Using stretch/aspect="expand"

```
❌ WRONG:
window/stretch/aspect="expand"

This fills the screen but distorts your aspect ratio
On phone portrait: Game becomes VERY stretched horizontally

✅ CORRECT:
window/stretch/aspect="keep_size"

This maintains 16:9 with black bars on irregular screens
```

### Mistake 2: Wrong Viewport Size

```
❌ WRONG:
window/size/viewport_width=1280
window/size/viewport_height=780
Aspect: 1.641:1 (NOT 16:9)

✅ CORRECT:
window/size/viewport_width=1920
window/size/viewport_height=1080
Aspect: 1.777:1 (TRUE 16:9)

If you want different size:
- Use 1280x720 (16:9)
- Or 1600x900 (16:9)
- Or 2560x1440 (16:9)
- Anything × 1.777 = 16:9 ✅
```

### Mistake 3: Not Reimporting After Changes

```
❌ WRONG:
1. Edit project.godot
2. See no change in game
3. Assume fix didn't work

✅ CORRECT:
1. Edit project.godot
2. Close Godot completely (or reload project)
3. Godot re-reads project.godot
4. Changes apply
5. Test again
```

---

## 📋 FINAL CHECKLIST

Before deploying, verify:

```
VIEWPORT SIZE
☑ Viewport Width = 1920
☑ Viewport Height = 1080
☑ Aspect Ratio = 1920÷1080 = 1.777 ✅

STRETCH SETTINGS
☑ Stretch Mode = "canvas_items"
☑ Stretch Aspect = "keep_size"
☑ Stretch Scale = 1.0

RESULT ON DEVICES
☑ Desktop 16:9: Full screen, no bars
☑ Desktop 4:3: Game letterboxed
☑ Mobile portrait: Game letterboxed with bars
☑ Mobile landscape: Full screen
☑ Tablet landscape: Full screen
☑ Tablet portrait: Game letterboxed

VISUAL INSPECTION
☑ No stretching in game content
☑ No squishing in UI elements
☑ Text is readable at all scales
☑ Buttons are clickable and properly sized
☑ No weird black bars on 16:9 devices
☑ Consistent aspect across all scenes
```

---

## 🎬 QUICK SUMMARY TABLE

| Device | Screen | Game Internal | Display | Aspect |
|--------|--------|---------------|---------|--------|
| Desktop | 1920x1080 | 1920x1080 | Full screen | 16:9 ✅ |
| Desktop | 1280x720 | 1920x1080→1280x720 | Full screen | 16:9 ✅ |
| Phone | 1080x1920 | 1920x1080→1080x607 | Center + bars | 16:9 ✅ |
| Tablet | 2560x1440 | 1920x1080→2560x1440 | Full screen | 16:9 ✅ |
| TV | 3840x2160 | 1920x1080→3840x2160 | Full screen | 16:9 ✅ |

---

## 🚀 YOU'RE ALL SET!

Your project now has:
✅ True 16:9 aspect ratio (1920x1080)
✅ Proper scaling on all devices
✅ Black bars only when necessary
✅ No stretching or distortion
✅ Consistent experience everywhere

The game will look perfect on desktop, mobile, and tablets!

---

*For installation instructions, see INSTALLATION_GUIDE.md*  
*For error details, see ERROR_ANALYSIS_AND_FIXES.md*  
*For quick overview, see QUICK_REFERENCE.md*
