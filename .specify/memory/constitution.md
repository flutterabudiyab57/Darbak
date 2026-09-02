<!--
SYNC IMPACT REPORT
==================
Version change: [unfilled scaffold] → 1.0.0 (initial ratification)

Modified principles:
  [PRINCIPLE_1_NAME] → I. Identity Is The ID, Never The Name (NON-NEGOTIABLE)
  [PRINCIPLE_2_NAME] → II. Root-Navigator Screens Must Be Self-Contained (NON-NEGOTIABLE)
  [PRINCIPLE_3_NAME] → III. One Source Of Truth Per Concept
  [PRINCIPLE_4_NAME] → IV. Fail Open On Validation Data
  [PRINCIPLE_5_NAME] → V. Phased Delivery With Manual Verification (NON-NEGOTIABLE)

Added sections:
  Technology Constraints (stack, networking, local storage, navigation, caching)
  Development Workflow (agent/developer roles, analyze baseline, stop-and-diagnose rules)

Removed sections: none

Deferred TODOs: none — all placeholders resolved.
-->

# Darbak Constitution

## Core Principles

### I. Identity Is The ID, Never The Name (NON-NEGOTIABLE)

Never store a display string alongside a model and resolve one from the other. Never look up an
entity by matching its name. Entity names are localized server-side via Accept-Language and differ
across endpoints (the same branch arrives as "name" from /branches and as "text" from
/available/branches). Domain models override == and hashCode on id only.

Violating this has already caused wrong branch ids to be silently sent to the backend with no error
surfaced to the user.

### II. Root-Navigator Screens Must Be Self-Contained (NON-NEGOTIABLE)

`PersistentNavBarNavigator.pushNewScreen(..., withNavBar: false)` resolves internally to
`Navigator.of(context, rootNavigator: true)`. The pushed route is therefore placed OUTSIDE the
caller's provider subtree. Any screen opened this way MUST NOT read a locally-scoped cubit: it
receives its data as constructor parameters and returns its outcome via
`Navigator.pop(context, result)`.

This is not a style preference. Reading a scoped cubit from such a screen throws
`ProviderNotFoundException` inside the tap handler, which aborts the callback silently before
navigation runs, producing a "tapping does nothing" bug with no visible error in release builds.

### III. One Source Of Truth Per Concept

One list per concept, driven by an explicit filter object. Never maintain parallel lists per
variant. Delivery branches, airport branches and car-specific branches are the same entity under
different filters, not different kinds of entity. State is immutable, uses Equatable and copyWith,
and rebuilds are driven by state equality — never by manually emitting a state to force a rebuild.

### IV. Fail Open On Validation Data

If validation input (such as a branch's work_time) is missing, null, or unparseable, treat the
operation as PERMITTED. Never block a user action because of a parsing problem. Server-side
validation remains the final authority; client-side checks exist only to give faster feedback.

### V. Phased Delivery With Manual Verification (NON-NEGOTIABLE)

Build the new implementation alongside the old. Convert one screen at a time. Delete old code only
in the final phase. Every phase must leave the app in a working state. A phase is NOT complete when
it compiles or when analyze is clean — it is complete only when verified on a real device. Never
begin a phase before the previous one has been device-verified.

## Technology Constraints

**Stack**: Flutter, flutter_bloc (Cubit pattern), go_router, dio, flutter_screenutil, Firebase,
Equatable, get_it. Arabic-first RTL with English support.

**Networking**: All HTTP goes through the shared configured Dio instance so interceptors and auth
headers apply. Never use `package:http`. Never construct a bare `Dio()`. `package:http` is legacy
and exists only in `branchs_service.dart`, which is scheduled for deletion; when it is removed,
check whether `http` can be dropped from `pubspec.yaml` entirely.

**Local storage**: This project uses the Hive CE fork — `hive_ce` and `hive_ce_flutter`. Never
import `package:hive` or `package:hive_flutter`. Prefer storing raw JSON over generated
TypeAdapters, so model changes do not require migrations.

**Navigation**: `persistent_bottom_nav_bar` 6.2.1 is still in use alongside `go_router`.
Migrating away from it is explicitly out of scope. Principle II governs how to work safely within
it.

**Caching**: Any cache key for server-localized data MUST include the language code, so a language
switch is a natural cache miss requiring no manual invalidation. Cache failures MUST never surface
to the caller — always fall through to the network.

## Development Workflow

The agent implements; the developer reviews and approves. The agent MUST:

- Never commit without explicit approval.
- Run `flutter analyze` at the end of every task and report the issue count. The current baseline
  is 78 issues. Any increase MUST be explained.
- Report before changing anything when a task involves diagnosis.
- Stop and wait at the end of each task rather than continuing to the next.
- When a fix does not resolve the reported symptom, stop and diagnose rather than attempting
  another fix. Two failed fixes in a row means the root cause has not been found.

## Governance

This constitution supersedes other practices for this project. The NON-NEGOTIABLE principles (I,
II, V) may not be waived for convenience, deadline pressure, or because a violation "works today".
Principles I and II each describe a bug that already shipped and took weeks to diagnose.

Existing code that violates these principles is acknowledged technical debt and is scheduled for
removal — it is never a precedent for new code.

Project-specific coding conventions (AppTypography instead of raw TextStyle, theme-aware color
getters instead of raw Colors.*, screenutil extensions on all dimensions) live in CLAUDE.md and
remain in force.

**Amendment procedure**: Any change to a NON-NEGOTIABLE principle requires explicit written
justification and developer approval before taking effect. All other amendments increment the
version according to semantic versioning (MAJOR: principle removal or redefinition; MINOR: new
principle or material expansion; PATCH: clarification or wording). The `LAST_AMENDED_DATE` MUST
be updated on every amendment.

**Compliance**: All PRs must verify compliance with these principles. A PR that introduces a
violation of a NON-NEGOTIABLE principle MUST NOT be merged regardless of other review status.

**Version**: 1.0.0 | **Ratified**: 2026-09-02 | **Last Amended**: 2026-09-02
