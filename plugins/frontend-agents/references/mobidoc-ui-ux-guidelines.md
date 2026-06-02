<!-- AUTO-GENERATED from shared/references/mobidoc-ui-ux-guidelines.md. DO NOT EDIT. Run scripts/sync-shared.sh. -->
<!-- CANONICAL SOURCE. Edit here only. Run scripts/sync-shared.sh to propagate. -->
# Mobidoc UI/UX Beta Guidelines

These guidelines are a personal beta reference for Mobidoc frontend design and review. They are not an official team standard and must not include private patient data, internal screen captures, credentials, or unreleased business details in prompts, notes, commits, or generated documentation.

## Scope

Use this reference when reviewing or shaping Mobidoc frontend screens, especially Vue/Nuxt patient, hospital, or tablet flows. Treat it as a UX review lens, not a replacement for product requirements, accessibility checks, or code review.

## Product Principles

- Design for healthcare users who may not be comfortable with IT tools.
- Make the next action clear from navigation, screen state, and visible controls instead of explanatory prose.
- Prefer stable, predictable layouts over visually clever compositions.
- Keep clinical and operational information easy to scan, compare, and confirm.
- Use cautious language for medical workflows. UI copy should guide actions, not imply diagnosis or clinical authority.
- Avoid exposing implementation details, system jargon, or raw API terms to end users.

## Navigation-Centered UX

- Every screen should answer: where am I, what can I do next, and how do I return?
- Primary actions should be visually discoverable without reading long instructions.
- Back, cancel, close, and destructive actions should be distinct and consistent.
- Avoid hiding critical workflow choices inside low-visibility menus.
- Keep tab, drawer, modal, and stepper behavior consistent across patient, hospital, and tablet builds.

## Text And UX Writing

- Prefer short labels, explicit state names, and clear button verbs.
- Do not add visible teaching text for obvious controls.
- Use helper text only when it prevents a likely mistake or explains a real constraint.
- Error messages should identify the problem and the next recoverable action.
- Empty states should explain the current state and expose the next useful action when one exists.
- Confirmation text should name the object or action being confirmed.

## Layout Stability

- Fixed-format controls such as tabs, toolbar buttons, appointment slots, counters, and table cells need stable dimensions.
- Dynamic text must not resize controls in a way that shifts adjacent content.
- Long Korean labels, names, hospital names, appointment times, badges, and status text should wrap, truncate, or use responsive constraints deliberately.
- Avoid nested cards and decorative section cards for operational screens.
- Keep dense views calm: aligned columns, predictable spacing, restrained emphasis, and predictable hierarchy.

## Readability And Visibility

- Check contrast for text, icons, disabled states, badges, and status colors.
- Important status should not rely on color alone.
- Use font sizes appropriate to the surface: dashboard panels and tables need compact but readable type, not hero-scale headings.
- Keep touch targets large enough for tablet and patient-facing flows.
- Make loading, disabled, selected, active, error, and success states visually distinct.

## Review Checklist

- The main user and primary task of the screen are identifiable.
- The most likely next action is visible without reading instructions.
- Navigation and escape paths are clear.
- Button labels use action verbs and avoid ambiguous text.
- Empty, loading, error, disabled, selected, and success states are handled.
- Long labels and variable data do not overlap or cause layout shift.
- Text hierarchy matches the density and purpose of the surface.
- Status information has non-color cues.
- Patient-facing copy avoids medical overclaiming and internal jargon.
- The change is verified in the relevant build targets and viewport sizes.
