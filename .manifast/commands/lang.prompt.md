---
name: lang
description: "Set the language for artifact generation and user interactions. Supported: en (English), pt-BR (Brazilian Portuguese)."
tools: [read, edit]
argument-hint: "Language code to set (e.g., 'en' or 'pt-BR'). Omit to see the current setting and choose interactively."
---

You are configuring the **language** used by manifast for artifact generation and all user-facing interactions.

> Follow the steps below. Do not ask unnecessary questions.

---

## Step 1 — Read current setting

Read `docs/manifast.yaml`. Extract the `language` field.

If the field is absent, treat the current language as `en` (English).

Show the current setting to the user:

```
Current language: {current language name} ({language code})
```

---

## Step 2 — Resolve the new language

**If the user passed an argument** (e.g. `/lang pt-BR`), use that value directly. Skip to Step 3.

**If no argument was passed**, present the menu:

```
Available languages:
  1. en     — English
  2. pt-BR  — Portuguese (Brazil)

Type the number or the language code:
```

Wait for the user's choice. Map numbers to codes:
- `1` → `en`
- `2` → `pt-BR`

If the user types an unrecognized value, say:
> Unsupported language "{value}". Supported values: `en`, `pt-BR`.
Then stop.

---

## Step 3 — Validate

If the chosen language code equals the current one, tell the user:

> Language is already set to {language name} ({code}). No changes made.

Then stop.

---

## Step 4 — Update manifast.yaml

Edit `docs/manifast.yaml`. Replace the value of the `language` field with the new code. If the field does not exist, add it as the first line before `items:`:

```yaml
language: {new code}
```

---

## Step 5 — Update .env if it exists

Check whether a `.env` file exists at the root of the repository.

If it exists, read it and replace the `MWI_LANG` line with:

```
MWI_LANG={new code}
```

If `MWI_LANG` is not present in `.env`, append it at the end.

If `.env` does not exist, skip this step silently.

---

## Step 6 — Confirm

Tell the user:

```
Language updated to {language name} ({new code}).

Artifacts and interactions will now be in {language name}.
Run /focus to apply this language to the active work item's .env.
```

---

## Supported languages

| Code   | Name                  |
|--------|-----------------------|
| en     | English               |
| pt-BR  | Portuguese (Brazil)   |
