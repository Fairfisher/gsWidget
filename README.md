# gsWidget — Widget Library

A curated collection of Flutter UI widgets. Each file in `snippets/` is a self-contained, DartPad-compatible widget you can copy and use immediately.

---

## Structure

```
snippets/
  glassmorphism-button.dart
  neumorphic-button.dart
  animated-bar-chart.dart
  ...
```

One file per widget. No dependencies, no setup.

---

## Using a widget

Open any `.dart` file, copy the code, paste it into your project or [DartPad](https://dartpad.dev). Every widget includes `main()` and runs standalone.

---

## Adding a widget

1. Create `snippets/<your-slug>.dart`
2. The file must contain `void main()` and be DartPad-compatible
3. Open a pull request

**Naming convention** — lowercase, hyphen-separated, descriptive:
`frosted-glass-card.dart`, `animated-search-bar.dart`

---

## Guidelines

- No third-party packages — Flutter SDK only
- Must run without modification in DartPad
- Include a `MaterialApp` wrapper and a dark or neutral background
- Keep it focused — one concept per widget

---

## Submit your own

Have a widget worth sharing? [Open an issue](../../issues/new?template=widget_submission.md&labels=submission) with your code and a short description. Approved submissions get added to the library.

---

MIT License
