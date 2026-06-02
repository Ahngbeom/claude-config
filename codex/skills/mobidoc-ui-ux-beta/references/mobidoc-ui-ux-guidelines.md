# Mobidoc UI/UX Beta Guidelines

This is a personal beta reference for Mobidoc frontend UI/UX work. It is not an official team guideline. Do not include private patient data, internal screen captures, credentials, or unreleased business details in prompts, notes, commits, or generated documentation.

## Principles

- Design for healthcare users who may not be comfortable with IT tools.
- Let navigation, screen state, and visible controls explain the workflow before adding text.
- Keep layouts stable, predictable, and easy to scan.
- Use cautious healthcare copy. Guide actions without implying diagnosis or clinical authority.
- Hide implementation details and raw system terms from end users.

## Navigation

- Make location, next action, and return path clear.
- Keep primary actions discoverable.
- Make cancel, close, back, and destructive actions distinct.
- Avoid burying critical choices in low-visibility menus.
- Keep tab, drawer, modal, and stepper behavior consistent across patient, hospital, and tablet builds.

## UX Writing

- Use short labels and clear button verbs.
- Add helper text only when it prevents likely mistakes or explains real constraints.
- Error messages should state the problem and recoverable next action.
- Empty states should explain the state and expose the next useful action when one exists.
- Confirmation text should name the object or action being confirmed.

## Layout Stability

- Give fixed-format controls stable dimensions.
- Plan for long Korean labels, names, hospital names, appointment times, badges, and status text.
- Dynamic text should wrap, truncate, or fit within explicit responsive constraints.
- Avoid nested cards and decorative section cards in operational screens.
- Use restrained spacing, aligned columns, and predictable hierarchy for dense views.

## Readability And States

- Check contrast for text, icons, badges, status colors, and disabled states.
- Do not rely on color alone for important status.
- Keep touch targets large enough for patient and tablet flows.
- Make loading, disabled, selected, active, error, and success states distinct.
- Match type scale to the surface. Tables, dashboards, and panels need compact readable headings.

## PR Checklist

- The target user and task are clear.
- The most likely next action is visible.
- Navigation and escape paths are clear.
- Button labels use action verbs.
- Empty, loading, error, disabled, selected, and success states are handled.
- Variable data does not overlap or cause layout shift.
- Text hierarchy matches the screen density.
- Status has non-color cues.
- Patient-facing copy avoids medical overclaiming and internal jargon.
- Relevant build targets and viewport sizes were checked.
