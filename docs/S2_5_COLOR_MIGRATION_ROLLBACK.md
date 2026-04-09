# S2.5 — Hardcoded Color Migration: Rollback Reference

## Purpose
Documents every color value changed in Sprint 2.5 so any individual change can be reverted.

---

## text_form_field.dart

### CustomTextFormField (fillColor fallback)
| Line | Before | After | Notes |
|------|--------|-------|-------|
| ~124 | `Colors.grey.withValues(alpha: 0.1)` | **Kept as original** | `surfaceContainerHighest` resolved to white because theme sets `surface: Colors.white`, overriding seed-generated tints |

### SimpleTextFormField
| Line | Before | After | Field |
|------|--------|-------|-------|
| ~208 | `Color(0xFFE3E3E3)` | `Theme.of(context).colorScheme.outline` | enabledBorder |
| ~214 | `Colors.black` | `Theme.of(context).colorScheme.primary` | focusedBorder |
| ~220 | `Color(0xffF3F3F3)` | `Theme.of(context).colorScheme.outlineVariant` | default border |
| ~227 | `Colors.white.withValues(alpha: 0.1)` | **Kept as original** | Same surface override issue |

### GrayTextFormField
| Line | Before | After | Field |
|------|--------|-------|-------|
| ~288 | `Color(0xffb0b0b0)` | `Theme.of(context).colorScheme.outline` | enabledBorder |
| ~292 | `Color(0xFFFAFAFA)` | **Kept as original** | Same surface override issue |

> **Note:** Fill colors were not migrated to `colorScheme.surfaceContainerHighest` because the light theme explicitly sets `surface: Colors.white` in `_buildLightTheme()`, which causes all `surfaceContainer*` variants to derive from white instead of the seed color. Border colors were successfully migrated since `outline`/`outlineVariant`/`primary` are not affected by the surface override.

---

## button_form_field.dart

### CustomGradientButton
| Line | Before | After | Field |
|------|--------|-------|-------|
| ~62 | `Colors.white` | `Theme.of(context).colorScheme.onPrimary` | CircularProgressIndicator color |

### CustomButton
| Line | Before | After | Field |
|------|--------|-------|-------|
| ~143 | `Colors.black` | `Theme.of(context).colorScheme.onSurface` | Text color |

---

## upgrade_plan_popup.dart

**No changes made.** All `Colors.white` instances are intentional white-on-dark-gradient — not theme-dependent.

---

## Rollback instructions

To revert any single change, replace the `Theme.of(context).colorScheme.X` call with the original hardcoded value from the "Before" column above. The `const` keyword will need to be re-added where applicable since `Theme.of(context)` is not const-evaluable.
