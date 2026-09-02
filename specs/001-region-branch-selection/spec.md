# Feature Specification: Region & Branch Selection Rewrite

**Feature Branch**: `001-region-branch-selection` (spec directory; no git branch created — no `before_specify` hook configured)

**Created**: 2026-09-02

**Status**: Draft

**Input**: User description: "Rewrite the region and branch selection logic in the Darbak booking flow."

## Why This Rewrite Exists

A preceding bug-fix pass closed six defects in this area. All six were symptoms of three structural
causes, not independent bugs:

1. **Entity identity is stored twice** — a display string alongside a model — and consumers
   re-resolve one from the other by matching names.
2. **Branch state is split across two holders** with different provider scopes.
3. **Branches arrive from three sources in three shapes** and are kept in separate parallel lists.

Patching symptoms has reached its limit. The structure must change. This specification describes the
behaviour the rewritten selection must exhibit — not how to build it.

The goal is to remove the dependency on the old logic entirely, not to preserve its behaviour. Where
old behaviour and these requirements conflict, these requirements win.

## Flows In Scope

| Flow | Region step | Branch source |
|------|-------------|---------------|
| Daily rent | Yes | Region-filtered branches |
| Monthly rent | Yes | Region-filtered branches |
| Delivery (home_delivery) | **No** | Delivery-capable branches, spanning all regions |
| Airport | **No** | Airport-capable branches, spanning all regions |
| Book from a specific car | **No** | The car's available-branch list, spanning all regions |

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Pick up from a complete, correct branch list (Priority: P1)

A renter opens the daily-rent booking screen, chooses the region they want to collect the car in,
and picks a branch from that region. Every branch that region actually has is offered — not just the
first page. Whatever they tap is what the booking is made against.

**Why this priority**: This is the minimum viable slice. Without a correct pickup selection there is
no booking at all, and this story alone carries the two structural fixes that matter most — identity
by identifier, and one complete list per filter.

**Independent Test**: Open daily rent, select the region with the largest branch count, confirm the
number of branches offered matches the total the server reports for that region, select one, and
confirm the booking submits against that exact branch in both app languages.

**Acceptance Scenarios**:

1. **Given** the daily-rent booking screen is open with nothing selected, **When** the renter selects
   a region, **Then** the branch selector becomes available and lists every branch in that region.
2. **Given** a region whose branch count exceeds one server page, **When** its branch list is shown,
   **Then** all branches are present, with completeness determined by the server's reported total.
3. **Given** a pickup branch has been selected, **When** the renter changes the pickup region,
   **Then** the previously selected pickup branch is cleared and must be chosen again.
4. **Given** a branch has been selected while the app is in Arabic, **When** the booking is submitted,
   **Then** the identifier sent is the identifier of the tapped branch; switching to English and
   repeating produces the same identifier.
5. **Given** the region list fails to load, **When** the renter opens the screen, **Then** they are
   told the list is unavailable and can retry without the app appearing to do nothing.

---

### User Story 2 - Return the car to a different location (Priority: P1)

A renter enables a separate dropoff location and chooses where to return the car — possibly in a
different city entirely from where they collected it. If they change their mind and turn the option
off, no dropoff is sent.

**Why this priority**: Selecting a dropoff branch is currently broken in at least one flow, and a
stale dropoff has already been submitted to the backend. Both are user-visible defects that this
rewrite exists to eliminate. It is P1 alongside pickup because a pickup-only rewrite would leave the
headline bug unfixed.

**Independent Test**: Enable dropoff, select a region different from the pickup region, select a
branch, confirm it is accepted and submitted; then disable dropoff and confirm no dropoff value
reaches the backend.

**Acceptance Scenarios**:

1. **Given** a pickup region and branch are selected, **When** the renter enables a separate dropoff
   location, **Then** they can select a dropoff region and a dropoff branch.
2. **Given** dropoff is enabled, **When** the renter selects a dropoff region different from the
   pickup region, **Then** the dropoff branch list shows that region's branches, not the pickup
   region's.
3. **Given** dropoff is enabled and no dropoff region has been chosen, **When** the dropoff branch
   list is shown, **Then** it shows the pickup region's branches.
4. **Given** a dropoff branch is selected, **When** the renter changes the dropoff region, **Then**
   the dropoff branch is cleared.
5. **Given** a dropoff branch is selected, **When** the renter disables the separate dropoff option,
   **Then** the dropoff region and branch are cleared and no dropoff value is submitted.
6. **Given** any in-scope flow, **When** the renter taps a dropoff branch, **Then** the selection
   registers and is visibly reflected — tapping never silently does nothing.

---

### User Story 3 - Only offered times the branch can actually serve (Priority: P2)

A renter picks a date and time and is only shown times the chosen branch can genuinely serve. They
find out at the moment of choosing, not after filling in the rest of the booking.

**Why this priority**: This converts a late, confusing rejection into immediate feedback. It depends
on a branch already being selected (US1), so it follows it, but it is independently demonstrable.

**Independent Test**: Select a branch with known working hours, open the time picker, and confirm
times outside those hours and times less than two hours away are not selectable, while times inside
them are.

**Acceptance Scenarios**:

1. **Given** a branch open 09:00–17:00 on the chosen date, **When** the renter opens the time picker,
   **Then** times outside 09:00–17:00 are not selectable.
2. **Given** the current time is 14:00, **When** the renter picks up today, **Then** times before
   16:00 are not selectable.
3. **Given** a branch whose working period closes after midnight (for example opens 21:00, closes
   03:00), **When** the renter opens the time picker, **Then** the hours after midnight are offered
   as part of that period.
4. **Given** a date the branch marks as closed, **When** the renter selects it, **Then** no times are
   offered for that date and the renter is told the branch is closed.
5. **Given** a branch whose working-hours data is missing, empty, or cannot be understood, **When**
   the renter opens the time picker, **Then** all times remain available (fail open, per Principle IV).
6. **Given** a pickup time is set, **When** the renter chooses a dropoff time, **Then** times at or
   before the pickup time are not selectable.
7. **Given** a time passed the client-side check, **When** the server rejects it, **Then** the
   server's message is shown and the server's decision stands.

---

### User Story 4 - Every booking starts clean (Priority: P2)

A renter who abandons or completes one booking and starts another sees an empty form. Nothing from
the previous attempt is carried over.

**Why this priority**: Leaked selection state is how wrong values reach the backend without anyone
tapping them. It is a correctness guarantee rather than a visible feature, so it ranks below the two
selection stories but above flow parity.

**Independent Test**: Complete a selection, leave the booking flow, re-enter it, and confirm every
location field is empty.

**Acceptance Scenarios**:

1. **Given** a completed selection from an earlier booking, **When** the renter opens a booking
   screen again, **Then** no region, branch, or dropoff value is pre-filled.
2. **Given** a completed selection, **When** the renter proceeds to the additions and payment
   screens, **Then** those screens can read the selection.
3. **Given** the renter is on the additions or payment screen, **When** those screens are used,
   **Then** they cannot alter the selection.
4. **Given** the renter is on the additions screen, **When** they navigate back to the booking
   screen, **Then** the selection is cleared.

---

### User Story 5 - The same behaviour in monthly, delivery, and airport flows (Priority: P3)

A renter using monthly rent gets exactly the selection behaviour described in US1 and US2. A renter
using home delivery or an airport pickup gets the same branch and dropoff behaviour, but their branch
list is service-filtered, spans all regions, and appears immediately — these two flows have no region
step.

**Why this priority**: These flows reuse the capability proven in US1/US2. They deliver value only
after the core selection is correct, and each is converted and device-verified in turn.

**Independent Test**: Repeat the US1 and US2 tests in the monthly-rent flow. In the delivery and
airport flows, confirm the service-filtered branch list appears directly with no region selector, and
that branch and dropoff selection behave as they do in US1 and US2.

**Acceptance Scenarios**:

1. **Given** the delivery flow, **When** the booking screen opens, **Then** the delivery-capable
   branches are listed directly, spanning all regions, with no region step.
2. **Given** the airport flow, **When** the booking screen opens, **Then** all airport branches
   across every region are listed directly, with no region step.
3. **Given** a branch that offers delivery, **When** it is seen in the delivery flow and again in the
   daily-rent flow, **Then** it is the same branch with the same identifier — not a duplicate or a
   different kind of entry.
4. **Given** no branches offer the requested service, **When** the delivery or airport flow opens,
   **Then** the renter is told there are none rather than shown an empty list with no explanation.
5. **Given** the monthly-rent flow, **When** the renter completes selection, **Then** behaviour
   matches daily rent in every respect covered by US1 and US2.

---

### User Story 6 - Book from a specific car (Priority: P3)

A renter who started from a particular car picks straight from the branches where that car is
available. There is no region step, because that list already spans regions.

**Why this priority**: This flow has a distinct shape — a partial branch record and no region step —
so it is converted last, once the general model is proven.

**Independent Test**: Open a car, start booking, and confirm the branch list appears immediately with
no region selector, and that a selection submits the correct branch identifier.

**Acceptance Scenarios**:

1. **Given** the renter is booking a specific car, **When** the booking screen opens, **Then** the
   branches where that car is available are listed directly with no region step.
2. **Given** the car's branch list carries only partial detail, **When** it is displayed, **Then**
   each branch shows its name and same-day availability without the missing fields causing an error
   or an empty row.
3. **Given** a branch from the car's list has no working-hours data, **When** the renter opens the
   time picker, **Then** all times remain available.
4. **Given** a branch selected from the car's list, **When** the booking is submitted, **Then** the
   identifier sent matches the identifier that same branch carries elsewhere in the app.

---

### User Story 7 - Names follow the app language (Priority: P3)

A renter switching between Arabic and English sees region and branch names in the language they
chose, without losing what they were doing.

**Why this priority**: Correctness of the submitted identifier across languages is already covered by
US1. This story covers the display refresh, which is valuable but not a correctness risk on its own.

**Independent Test**: Open the branch list in Arabic, switch to English, and confirm the names change
while the selected branch stays selected.

**Acceptance Scenarios**:

1. **Given** region and branch lists are displayed, **When** the renter switches language, **Then**
   the names shown update to the new language.
2. **Given** a branch is selected, **When** the renter switches language, **Then** the same branch
   remains selected and its displayed name updates.
3. **Given** the renter switches language, **When** they then submit the booking, **Then** the
   identifier sent is unchanged by the switch.

---

### Edge Cases

- **Working-hours data absent, null, or unparseable** — all times remain available; the renter is
  never blocked by a parsing problem (Principle IV).
- **A working period with a null opening or closing value** — that period contributes no times; other
  periods on the same day still apply.
- **A day explicitly marked closed** — no times offered for that date, with an explanation.
- **A working period closing after midnight** — treated as one continuous period, not an empty or
  inverted one.
- **An "open all days" schedule alongside per-day entries** — the renter sees one coherent set of
  available times, not contradictory ones.
- **Coordinates delivered as text rather than numbers** — parsed without error.
- **Same-day availability delivered as a numeric flag** — interpreted correctly.
- **A region with zero branches**, or zero branches offering the requested service — explained, not
  shown as a blank list.
- **A region whose branches span multiple server pages** — all shown.
- **A branch reachable through more than one filter** — one entity, one identity, no duplicate entry.
- **Dropoff disabled after a dropoff branch was chosen** — nothing stale is submitted.
- **Pickup region changed after a branch was chosen** — the branch is cleared, never silently kept.
- **Language switched mid-selection** — the selection survives; only the displayed names change.
- **The server rejects a time the client allowed** — the server's message is surfaced and wins.
- **Network failure while loading regions or branches** — the renter is told and can retry; other
  selections are preserved.
- **The renter taps a branch and nothing appears to happen** — must be impossible; every tap yields a
  selection or an explicit message.

## Requirements *(mandatory)*

### Functional Requirements

**Identity**

- **FR-001**: The system MUST identify every region and branch solely by its stable identifier. No
  user-visible name may be used to look up, match, or resolve an entity.
- **FR-002**: The identifier submitted to the backend MUST be the identifier of the entity the renter
  selected, and MUST be identical regardless of the app's active language.
- **FR-003**: A branch reached through different filters (region, delivery, airport, car-specific)
  MUST be treated as one entity with one identity, never as separate kinds of entity.

**List completeness**

- **FR-004**: When a branch list is presented for a given filter, the system MUST present every
  branch matching that filter, not a partial page.
- **FR-005**: Completeness MUST be determined from the total the server reports, never from a fixed
  or assumed page count.
- **FR-006**: The system MUST maintain one list per concept driven by an explicit filter, and MUST
  NOT maintain parallel lists per variant.

**Pickup selection**

- **FR-007**: Renters MUST be able to select a pickup region from the available regions.
- **FR-008**: Renters MUST be able to select a pickup branch from the branches belonging to the
  selected pickup region.
- **FR-009**: Changing the pickup region MUST clear any previously selected pickup branch.
- **FR-010**: In the flows that have a region step — daily rent and monthly rent only — a pickup
  branch MUST NOT be selectable before a pickup region has been chosen. This requirement does not
  apply to the delivery, airport, or car-specific flows, which have no region step; FR-007 through
  FR-009 are likewise scoped to the two flows that have one.

**Dropoff selection**

- **FR-011**: Renters MUST be able to enable or disable a separate dropoff location.
- **FR-012**: When dropoff is enabled, renters MUST be able to select a dropoff region that differs
  from the pickup region.
- **FR-013**: When dropoff is enabled and no dropoff region has been chosen, the pickup region MUST
  apply to the dropoff branch list.
- **FR-014**: Changing the dropoff region MUST clear any previously selected dropoff branch.
- **FR-015**: Disabling the separate dropoff option MUST clear the dropoff region and dropoff branch
  completely, and no dropoff value may be submitted thereafter.
- **FR-016**: Selecting a dropoff branch MUST succeed in every flow in scope.

**Selection lifetime**

- **FR-017**: Opening a booking screen MUST present an empty selection, with no value carried over
  from any earlier booking.
- **FR-018**: The completed selection MUST be readable by the additions and payment screens.
- **FR-019**: The additions and payment screens MUST NOT be able to modify the selection.
- **FR-020**: Navigating back from the additions screen to the booking screen MUST clear the
  selection.

**Time selection**

- **FR-021**: The system MUST prevent selection of a pickup time outside the chosen branch's working
  hours for the chosen date.
- **FR-022**: The system MUST prevent selection of a pickup time less than two hours from the current
  time.
- **FR-023**: The system MUST prevent selection of a dropoff time at or before the pickup time.
- **FR-024**: When a branch's working-hours data is absent, null, or unparseable, the system MUST
  treat all times as available and MUST NOT block the renter.
- **FR-025**: The system MUST treat a day marked closed as having no available times, and MUST tell
  the renter why.
- **FR-026**: The system MUST interpret a working period whose closing time falls after midnight as
  one continuous period.
- **FR-027**: Server-side time validation MUST remain the final authority; a client-side allow MUST
  NOT bypass it, and a server rejection MUST be surfaced to the renter.

**Flow coverage**

- **FR-028**: The daily-rent and monthly-rent flows MUST use region-then-branch selection. They are
  the only flows with a region step.
- **FR-029**: The delivery and airport flows MUST present their service-filtered branch list
  directly, with no region step, spanning all regions. They MUST use the same branch concept and the
  same identity rules as every other flow.
- **FR-030**: The book-from-a-specific-car flow MUST present the car's available branches directly,
  with no region step. It is one of three flows without a region step, alongside delivery and
  airport.
- **FR-031**: The book-from-a-specific-car flow MUST function correctly given partial branch data
  (identifier, name, image, and same-day availability only).

**Language**

- **FR-032**: Switching language MUST refresh the displayed region and branch names.
- **FR-033**: A selection in progress MUST survive a language switch, retaining the same entity by
  identifier with an updated display name.

**External contract**

- **FR-034**: The system MUST accept coordinate values delivered as text.
- **FR-035**: The system MUST accept same-day availability delivered as a numeric flag.
- **FR-036**: The system MUST read the backend's existing key spellings exactly as they are and MUST
  NOT normalise, rename, or "correct" them.
- **FR-037**: The system MUST reconcile the two different name keys used by the branch sources
  without treating the two shapes as different entities.

**Errors**

- **FR-038**: When a region or branch list cannot be loaded, the system MUST tell the renter and
  allow a retry, without discarding selections already made.
- **FR-039**: Every branch or region tap MUST produce a visible outcome — a selection or an explicit
  message. No tap may result in no feedback.

### Key Entities

- **Region**: A geographic area a renter picks before choosing a branch. Carries a stable identifier,
  a localized name, a city, a code, a parent reference, a boundary outline, and a centre point. Nine
  exist.
- **Branch**: A physical location a car is collected from or returned to. Carries a stable
  identifier, a localized name, its region as both a name and an identifier, an address, coordinates,
  a phone number, a location link, a working-hours schedule, a same-day-booking flag, and a delivery
  price.
- **Car-Available Branch**: The reduced form of a branch returned when browsing a specific car's
  availability. Carries only an identifier, a localized name, an image, and a same-day-booking flag.
  Its identifier matches the full branch's identifier — it is the same entity with less detail.
- **Working Schedule**: A branch's per-day opening information, with entries for each weekday plus an
  all-days entry and an open-all-days flag. Each day may carry a period label, a morning window, an
  afternoon window, and a closed marker. Windows may be null; closing times may cross midnight.
- **Branch Filter**: The explicit criteria that produce a branch list — by region, by delivery
  capability, by airport capability, or by a specific car. Different filters over one concept, not
  different concepts.
- **Location Selection**: The renter's in-progress choice — pickup region, pickup branch, whether a
  separate dropoff is enabled, dropoff region, dropoff branch. Scoped to one booking attempt.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A renter can select a dropoff branch successfully in all five in-scope flows — 100% of
  attempts register, zero silent no-ops.
- **SC-002**: The branch identifier received by the backend matches the branch the renter tapped in
  100% of submissions, in both Arabic and English.
- **SC-003**: For every region, the number of branches offered equals the total the server reports
  for that region — no branch is hidden from the renter.
- **SC-004**: Starting a booking after completing or abandoning a previous one shows zero pre-filled
  location values, 100% of the time.
- **SC-005**: Zero bookings are submitted with a dropoff branch after the separate-dropoff option was
  turned off.
- **SC-006**: A renter cannot reach submission with a time the chosen branch cannot serve; such times
  are non-selectable at the point of choosing.
- **SC-007**: Zero renters are blocked from choosing a time because working-hours data was missing or
  unreadable.
- **SC-008**: Switching language updates every visible region and branch name while the renter keeps
  their place and their selection.
- **SC-009**: Every tap on a region or branch produces visible feedback — zero taps result in no
  observable response.
- **SC-010**: The six defects closed by the preceding bug-fix pass do not recur in any in-scope flow
  after conversion.

### Delivery Gates

These are process and quality gates rather than user-facing outcomes. They are drawn from the project
constitution and the feature request.

- **DG-001**: `flutter analyze` stays at or below the 78-issue baseline; any increase is explained.
- **DG-002**: Each flow is verified on a real device before the next flow is converted
  (Principle V) — compiling and a clean analyze do not constitute completion.
- **DG-003**: Every phase leaves the app in a working state, with the new implementation built
  alongside the old.
- **DG-004**: Old code is deleted only in the final phase.

## Assumptions

Reasonable defaults chosen where the feature description did not state a rule. Each is a decision
that can be revisited during `/speckit-clarify` or planning.

- **Delivery and airport flows have no region step — verified on-device, not assumed.** Delivery
  shows its branch list immediately; airport shows all airport branches across every region. Only
  daily rent and monthly rent have a region step, making three of the five in-scope flows
  region-less. This replaces an earlier assumption to the contrary, which was wrong. See
  `Verified Inputs`.
- **Changing the dropoff region clears the dropoff branch**, mirroring the stated pickup rule, since
  the same reasoning applies — the branch may not belong to the new region.
- **A dropoff branch may be the same branch as the pickup branch.** No rule forbidding it was stated.
- **Unavailable times are shown as non-selectable rather than hidden**, so the renter can see the
  branch's hours and understand why a time is unavailable. The requirement is that they are prevented
  from choosing, which non-selectable satisfies.
- **A selection in progress survives a language switch.** Because identity is the identifier and
  identifiers are language-independent, only the display names need to change.
- **The two-hour lead applies to pickup only.** Dropoff is constrained solely to be after pickup, as
  described.
- **The region list needs no pagination handling** — nine regions is a single response.
- **Car-specific branches fail open on time selection.** They carry no working-hours data, and
  Principle IV requires that missing validation input permits the operation.
- **Guests and authenticated renters see identical region and branch behaviour.** Auth gating for
  booking itself is unchanged and outside this feature.
- **No visual redesign.** Existing screens keep their current appearance; only the selection
  behaviour behind them changes.

## Dependencies

- The regions, branches, car-available-branches, and time-validation endpoints remain available and
  behave as verified.
- Server-side localization via the language request header continues to be honoured; there are no
  per-language name fields to fall back on.
- The time-validation endpoint remains the final authority on availability.
- The areas feature keeps its existing implementation untouched and is not depended upon.

## Out of Scope

- **The areas feature** (geographic boundaries constraining map location selection). Its user flow is
  not currently understood, so it is deferred entirely and keeps its existing implementation.
- **Migrating navigation** away from the current persistent bottom-nav mechanism.
- **Date, package, and search logic** beyond the location fields.
- **Correcting the backend's misspelled keys.** These are a live contract — they are read as they
  are, never "fixed".
- **Visual design of any screen.** No screen is being redesigned.

## Verified Inputs *(non-negotiable reference)*

Established by codebase audit, live API testing, and on-device verification. Recorded here as
constraints on the requirements above — not to be re-derived or second-guessed during planning.

**Regions** — The regions endpoint returns a data/links/meta envelope. Nine regions exist. A region
has an identifier, name, city, code, parent reference, boundary polygon of lat/lng points, and a
centre point.

**Branches** — A page-size parameter *is* honoured by the server (verified: a requested size of 100
came back as a per-page of 100). Without it the server defaults to 15 per page, and there are 48
branches across 4 pages. Pagination metadata lives in the response's last-page field, which is the
only correct stopping condition. The previous implementation hard-coded a 3-page loop for unfiltered
requests and fetched only page 1 for region-filtered requests, so branches were hidden from renters.
Delivery-filtered and airport-filtered requests return the *same* branch shape, narrowed — those
branches also appear in the region-filtered list. These requests are **not region-scoped**: they
return the matching branches across all regions, and the delivery and airport flows therefore have no
region step. A branch carries: identifier, name, region name,
region identifier, address, latitude, longitude, phone, location link, working hours, same-day flag,
delivery price. **Latitude and longitude arrive as strings, not numbers**, and the longitude key is
`long`, not `lng`. The same-day flag arrives as integer 1/0.

**Car-specific branches** — The car-availability endpoint returns *partial* branches: identifier,
name, image, and same-day availability only. No working hours, no region identifier, no address, no
coordinates. The name key is `text` here and `name` on the branches endpoint. **The identifiers match
across both sources.** The list spans multiple regions, so this flow has no region step.

**Working hours** — Per-day entries for each weekday plus an all-days entry and a top-level
open-all-days flag. Each day may carry a period, a morning window, an afternoon window, and a lock.
**The API misspells "afternoon" as `afternone`.** Values may be null (for example an afternoon window
whose opening time is null). A lock value of `"1"` means the day is closed. Closing times can cross
midnight — for example opening at 21:00 and closing at 03:00.

**Validation** — The time-validation endpoint checks whether a branch is actually available for the
requested date and time and enforces rules such as pickup being at least two hours out and dropoff
being after pickup. It returns a message field. It stays in place and remains the final authority.

**Localization** — Names are localized server-side via the language header. There are no per-language
name fields. A language switch requires refetching.
