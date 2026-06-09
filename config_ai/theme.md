---
name: Cybernetic Piano Interface
colors:
  surface: '#0d1515'
  surface-dim: '#0d1515'
  surface-bright: '#333b3b'
  surface-container-lowest: '#080f10'
  surface-container-low: '#151d1e'
  surface-container: '#192122'
  surface-container-high: '#232b2c'
  surface-container-highest: '#2e3637'
  on-surface: '#dce4e4'
  on-surface-variant: '#b9cacb'
  inverse-surface: '#dce4e4'
  inverse-on-surface: '#2a3232'
  outline: '#849495'
  outline-variant: '#3a494b'
  surface-tint: '#00dbe7'
  primary: '#e1fdff'
  on-primary: '#00363a'
  primary-container: '#00f2ff'
  on-primary-container: '#006a71'
  inverse-primary: '#00696f'
  secondary: '#fface8'
  on-secondary: '#5e0053'
  secondary-container: '#ff24e4'
  on-secondary-container: '#520049'
  tertiary: '#e0ffe4'
  on-tertiary: '#00391d'
  tertiary-container: '#00fa91'
  on-tertiary-container: '#006e3d'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#74f5ff'
  primary-fixed-dim: '#00dbe7'
  on-primary-fixed: '#002022'
  on-primary-fixed-variant: '#004f54'
  secondary-fixed: '#ffd7f0'
  secondary-fixed-dim: '#fface8'
  on-secondary-fixed: '#3a0033'
  on-secondary-fixed-variant: '#840076'
  tertiary-fixed: '#5bffa1'
  tertiary-fixed-dim: '#00e383'
  on-tertiary-fixed: '#00210e'
  on-tertiary-fixed-variant: '#00522c'
  background: '#0d1515'
  on-background: '#dce4e4'
  surface-variant: '#2e3637'
typography:
  display-lg:
    fontFamily: Space Grotesk
    fontSize: 48px
    fontWeight: '700'
    lineHeight: '1.1'
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Space Grotesk
    fontSize: 32px
    fontWeight: '600'
    lineHeight: '1.2'
  headline-lg-mobile:
    fontFamily: Space Grotesk
    fontSize: 24px
    fontWeight: '600'
    lineHeight: '1.2'
  body-md:
    fontFamily: Geist
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.6'
  label-mono:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '500'
    lineHeight: '1.0'
    letterSpacing: 0.1em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  unit: 4px
  gutter: 16px
  margin-mobile: 20px
  margin-desktop: 40px
  container-max: 1440px
---

## Brand & Style

This design system targets modern musicians and tech-enthusiasts who view the piano as an instrument of both tradition and high-tech performance. The brand personality is **Futuristic, High-Octane, and Precise**, designed to make the act of learning music feel like navigating a sophisticated digital cockpit.

The visual style is **Glassmorphism mixed with Cyber-Neon**. It leverages deep atmospheric depths and light-emitting elements to guide the user's focus. The emotional goal is to move the user from a passive learner to an active "pilot" of their musical journey, using gamified cues to drive motivation and engagement. High-contrast elements ensure readability during intense practice sessions, while the "glow" aesthetics celebrate achievements through visual spectacle.

## Colors

The palette is rooted in a **Deep Midnight Blue (#0A0E14)** foundation, creating a void-like space where interactive elements can pop. 

- **Neon Cyan (#00F2FF):** The primary action color, used for MIDI data streams, active notes, and core navigation.
- **Magenta (#FF00E5):** The secondary accent, representing performance milestones, "Power-up" states, and experimental features.
- **Emerald Green (#00FF94):** Reserved strictly for success states, perfect timing indicators, and "Smart Learning" progress.
- **Surface & Glass:** Backgrounds for cards use a 3% white tint over the background with a 20px-40px backdrop blur to create the frosted glass effect.

## Typography

This design system utilizes a trio of fonts to convey a technical, high-performance feel. 

- **Space Grotesk** is used for impactful headlines and performance scores, providing a geometric, futuristic character.
- **Geist** serves as the primary body font, offering maximum legibility with a clean, developer-centric aesthetic that fits the MIDI-data theme.
- **JetBrains Mono** is utilized for metadata, MIDI values (Velocity, CC), and technical labels, reinforcing the "instrument as a machine" metaphor. 

All typography should maintain high contrast (White or Neon Cyan) against the dark background.

## Layout & Spacing

The system uses a **Fluid Grid** model based on a 4px baseline unit. This "micro-grid" ensures that MIDI note bars and UI elements align perfectly with musical timing divisions.

- **Desktop:** 12-column grid with 24px gutters. Content is often centered in a "Cockpit" view where the sheet music or MIDI roll takes precedence.
- **Mobile:** 4-column grid with 16px gutters.
- **Rhythm:** Spacing follows a geometric progression (4, 8, 16, 32, 64) to maintain a structured, engineered look.
- **Reflow:** On mobile, sidebars collapse into bottom sheets to ensure the piano keyboard (horizontal) remains the primary interactive area.

## Elevation & Depth

Hierarchy is established through **Glassmorphism and Glow Radiance** rather than traditional shadows.

1.  **Base Layer:** The Deep Midnight Blue (#0A0E14) floor.
2.  **Glass Layer:** Frosted cards using `backdrop-filter: blur(24px)` and a thin 1px white border at 12% opacity.
3.  **Active Layer:** Elements that are currently "playing" or "selected" emit a 15px-30px outer glow (box-shadow) using their respective accent color (Cyan or Magenta).
4.  **Floating Layer:** Modals and tooltips feature a dual border: a 1px solid primary color border and an outer 4px soft glow to simulate light emission.

## Shapes

The shape language is **Technical and Precise**. We use "Soft" roundedness (0.25rem) for most interactive components to maintain a sharp, engineered feel without being overly aggressive. 

- **MIDI Notes:** Perfectly rectangular with 2px corner radii.
- **Interactive Cards:** `rounded-lg` (0.5rem) to provide a containerized feel for the glass effect.
- **System Buttons:** `rounded-xl` (0.75rem) or pill-shaped for high-frequency touch targets on mobile.

## Components

### Glowing Buttons
Buttons are primary navigation drivers. The "Active State" button features a solid Cyan fill with a matching `drop-shadow` glow. "Ghost" variants use the 1px glass border with Cyan text that glows on hover.

### Progress Bars & Gauges
The "Smart Learning" progress bars use linear gradients (Cyan to Magenta) to show difficulty or completion. Gauges for "Accuracy" or "Timing" use a circular arc with a segmented display (like a speedometer), using Emerald Green for the "Perfect" zone.

### Sleek List Items
Piano pieces in the jukebox are listed as semi-transparent glass rows. On hover/active, the row expands slightly, the text shifts to Cyan, and a vertical "Energy Bar" appears on the left edge.

### MIDI Waterfall
A core component where notes "fall" toward the keyboard. Notes are styled as translucent glowing capsules. Successful hits trigger a "Particle Burst" effect in Emerald Green.

### Interactive Data Cards
Small, high-density cards displaying BPM, Key, and Time Signature. These use JetBrains Mono for values and are framed with "L-shaped" corner accents rather than full borders to suggest a futuristic HUD (Heads-Up Display).