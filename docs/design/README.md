# Design handoff

Screens (402×874, iPhone 16 Pro points) exported from the Flutter app as editable SVG:
`home.svg`, `payments.svg`, `payment-sheet.svg`, `profile.svg`.

**Import into Figma:** drag the SVG files onto a Figma canvas. Shapes and text stay editable.
Icons are simplified; swap them for Material Icons (Rounded). Text uses Inter in the SVGs; the app uses the system font.
`generate_screens.py` regenerates the SVGs (`python3 generate_screens.py`).

## Color tokens (`mobile/lib/core/theme.dart`)
| Token | Hex | Use |
|---|---|---|
| primary | `#0A6F82` | headings, icons, primary button, active nav |
| primaryDark | `#065666` | gradient/pressed |
| primaryLight | `#DCEFF2` | icon chips, badges |
| accent | `#E06F2C` | main call-to-action |
| surface | `#F5F8F8` | screen background |
| ink | `#16323A` | body text |
| muted | `#6C7F85` | secondary text |
| credit | `#0A8A6A` | incoming amounts |
| border | `#E3EBED` | card outline |

Header gradient: `#0A6F82` → `#3A9DAE` (60%) → `#F5F8F8`, 260 high, with white 12% contour lines.

## Type
Screen title 22/700 primary · Section title 17/800 primary · Row title 15/600 ink · Body 14/400 · Caption 12/400 muted · Balance 32/800 primary.

## Shape and spacing
Spacing 4 / 8 / 16 / 24. Screen gutter 16. Card radius 16 (balance card 18, profile 20), 1px border + shadow `0 4 12 rgba(10,111,130,.07)`. Buttons 52 high, radius 14. Quick-action tile 56, radius 16. Floating nav pill 68 high, radius 34, margin 16, shadow `0 6 18 rgba(10,111,130,.16)`.
