# Darbak App: Functional Specification

**Date**: 2026-09-07 | **Scope**: User-facing features (not architecture, not booking flows or location selection)

---

## 1. HOME SCREEN (Search Screen)

**Entry point**: Splash screen → `/home` route (`SearchScreen`), shell branch 0.

**What user sees on arrival**:
- Floating "Offers" banner (if offers published by backend via `/check_for_offers`) with discount value and promo message, or empty if no offers.
- "Hero" panel (gradient background, brand styling) prompting user to select rental type.
- Region selector visible in context, but **displayed via booking-flow screens below**, not on the home tab itself.
- Bottom floating pill navigation bar with 4 tabs: Home (active), Fleet, Bookings, Profile.

**Actions available, in order they appear**:

1. **Tap offer banner** — routes to `/offers` screen (full offers list detail).
2. **"Daily Rent" button** — pushes `Routes.classic` (daily rent booking screen with region selection).
3. **"Monthly Rent" button** — pushes `Routes.monthlyPackage` (monthly booking flow).
4. **"Airport Delivery" button** — pushes `Routes.airportPackage` (airport pickup flow, no region step).
5. **"Delivery" card** (labeled `branches_card.dart` in code, reads oddly as "delivery promo") — pushes `Routes.deliveryPackage` (home delivery flow).
6. **"Book from a car" card** (shown if car-specific flows are enabled) — navigates into the booking-from-car flow.
7. **Scroll down** — reveals:
   - "Favorite Cars" section (if user is authenticated, shows previously favourited vehicles; guest sees empty or "login required").
   - "Monthly packages widget" — display of rental terms (1mo, 3mo, 6mo, 9mo, 12mo pricing).
   - Offers section (appears to be an additional offers teaser, pulling from `/check_for_offers` endpoint).
   - "View branches" card — pushes `Routes.branches` (separate branch-browsing screen, not part of booking).

8. **Pull to refresh** — not explicitly shown but scroll-driven; reloads regions and offers.

9. **Bottom nav bar taps**:
   - **Home** (current) — stays on home, scrolls to top if already here (re-tap behavior).
   - **Fleet** (icon: car) — navigates to `/fleet` shell branch (car search/browse screen).
   - **Bookings** (icon: document/calendar) — navigates to `/bookings` shell branch (order history).
   - **Profile** (icon: person) — navigates to `/profile` shell branch (user account, settings).

10. **Tap profile avatar** (top-right corner, user profile image) — pushes `/edit-profile` route.

11. **Top-left menu icon** (if present, to be confirmed) — context dependent; may show settings or language picker.

**What requires login**:
- Booking actions (tapping rental type buttons) → shows sign-in modal sheet (`SignInMode.gate`) if guest or unauthenticated.
- Favorites viewing — guest sees "no favorites" or login prompt.
- Booking history — redirects to bookings tab, shows "Not Authenticated" if guest.

**Guest mode behavior**:
- Can browse home screen, see offers, see car packages, but cannot initiate booking without signing in.
- Sign-in modal appears when tapping any "Book" button or when accessing profile/bookings tabs.
- After login via modal, booking action retries without navigation away.

**Empty state**: No offers published → offer banner area renders but empty or hidden. No favorites → favorites section shows empty or "log in to see favorited cars".

**Loading state**: 
- Skeleton loaders shown while fetching regions and offers.
- Regions/offers not yet fetched: cards may show placeholder text.

**Error state**:
- Network unavailable (offline) → hero panel and booking buttons still visible, but tapping "Book" shows snackbar/error toast.
- `searchCubit.validate()` failure on `/available/time` → caught in booking flows, not on home.

**API endpoints called**:
- `GET /regions` — populates region list in location module.
- `GET /check_for_offers` — fetches offer banner data.
- `GET /available/time` (POST) — called later in booking flows, not on home.

**Half-built / unreachable**:
- "Areas" feature (geographic constraints for delivery map) still present in code but: `AreasListView` lost its only caller in Phase 8 cleanup; the widget still contains a `Principle I` violation (name-based lookup) but is unreachable.
- Home hero-panel prefetch of branch cache (`_warmBranchCache`) is a silent best-effort; a failure is not user-visible.

---

## 2. AUTHENTICATION

**Entry points**:
- Splash screen → `/language` (language selection, first run) → `/onboarding` (3-page swipe intro, first run) → `/home`.
- Splash screen → `/signin` if user explicitly chooses "Sign In" button.
- Home screen → sign-in modal sheet if guest or unauthenticated user taps "Book Now".

**Methods available**:

1. **Email + Password**:
   - Form fields: email (validated as RFC-standard email), password (6+ chars, no special requirements visible).
   - Endpoint: `POST /login`.
   - On success: token stored in SharedPreferences (`token` key), user data stored (`userData` key), navigates to `/home`.
   - On failure: error message shown (backend-supplied), stays on sign-in screen.

2. **Phone + OTP** (verified to be an option):
   - Form fields: phone number (country picker defaults to Saudi Arabia +966, user can select other country).
   - Phone validated: length/format checks applied via `FormValidator._validatePhone()`.
   - Endpoint: `POST /login` (or separate endpoint not confirmed in this read).
   - On success: same token/data flow as email.
   - On failure: error message shown.

3. **ID Number** (unconfirmed, mentioned in code but exact flow not traced):
   - Form field: national ID.
   - Endpoint: unclear from this read.

4. **Social login** (if any):
   - Not found in this read; flagged as absent or incomplete.

**Registration**:
- Tap "Create Account" from sign-in screen → embedded `RegisterPage` (not via route `/register`, which is dead).
- Form: phone/email + password + confirm password, OTP verification step.
- `POST /register` (multipart) → phone + email + password + device info.
- `POST /register/verify` → OTP code (sent to phone or email).
- On success: returns to sign-in screen with credentials pre-filled if applicable.
- On failure: error message, retry form.

**Password reset**:
- Tap "Forgot Password?" from sign-in screen → embedded `ForgotPasswordScreen` (not via route `/forgot-password`, which is dead).
- Multi-step flow: phone entry → code verification → password reset.
- `POST /password/forget` → sends SMS/email code.
- `POST /password/code` → verifies code.
- `POST /password/reset` → sets new password.
- On success: returns to sign-in.
- On failure: error shown at current step, retry or abort.

**Post-login behavior**:
- Token stored locally (plain SharedPreferences, **not encrypted** — security debt noted in CLAUDE.md).
- `AuthStatusCubit` emits `true` (signed in state).
- Subsequent API requests inherit token in `Authorization: Bearer <token>` header.
- Profile tab (`/profile`) becomes unlocked; shows user info.
- Bookings tab (`/bookings`) becomes unlocked; shows order history.
- Booking flows skip sign-in modals; selections from `SearchCubit` persist across screens.

**Sign-in modes**:
- **Entry mode** (`SignInMode.entry`): Used for explicit `/signin` route. On success, navigates to `/home`.
- **Gate mode** (`SignInMode.gate`): Used by `requireAuth()` helper (modal sheet over current screen). On success, pops sheet and retries booking action, no navigation.

---

## 3. GUEST MODE

**Entry point**: Sign-in screen → "Continue As Guest" button.

**What is blocked**:
- **Booking**: All booking flows (`/classic`, `/monthly-package`, `/airport-package`, `/delivery-package`, `/branch-with-car`) require signing in via `requireAuth()` modal before proceeding past branch selection.
- **Profile tab** (`/profile`): Shows `LoginNoAuth()` widget — "Sign In" and "Register" prompts, no profile data visible.
- **Bookings tab** (`/bookings`): Shows `ErrorImage` with "Not Authenticated" message and "Log In" button.
- **API calls**: Datasources check `if (token != null)` before adding Bearer header. Guest requests omit Authorization entirely (no `"Bearer null"`).

**How blocks are presented**:
- Booking buttons (`requireAuth()`) → modal sheet with sign-in form overlays current screen.
- Profile/bookings tabs → full-screen placeholder UI with sign-in CTA.
- Network requests that require auth (e.g., `GET /profile`) fail with 401, caught and emitted as error state.

**Guest-specific behavior**:
- Can browse home screen, view car listings, see offers.
- `isGuest` flag set in SharedPreferences on guest entry; checked by splash screen on restart to go directly to `/home`.
- After guest logs in via `requireAuth()` modal: booking action retries, `AuthStatusCubit` emits `true`, tabs unlock.

**What survives mid-flow login**:
- Region/branch selections in `SearchCubit` survive guest sign-in (selections held in cubit fields; not cleared on login).
- Date/time/rent-type selections survive.
- Booking flow screen state preserved (e.g., if guest was on "branch with car" and signs in via modal, the screen is still there with selections intact).

---

## 4. CAR SEARCH AND BROWSE

**Entry point**: Home tab → tap "Fleet" nav button → `/fleet` shell branch (`AllCarsScreen`).

**On arrival**:
- Car list displayed (paginated, `carsCubit` pagination).
- Default sorting: unclear from this read; likely by price or rating.
- Search bar and filter button visible at top.

**Available actions**:

1. **Search by car name/model**:
   - Text field at top of screen.
   - Endpoint: `GET /cars/filter?search=<term>` (or equivalent in-app filtering).
   - Returns paginated list.
   - Search is applied on text input debounce or button tap.

2. **Filter by**:
   - Tap filter button → `FiltersCars` screen (`/filter-cars`).
   - **By brand** (manufacturer): `GET /manufactories` populates dropdown.
   - **By price range**: slider picker (min/max).
   - **By rental type**: daily / monthly / etc. (appears to be a booking-level choice, unclear if car-level filter).
   - **By transmission**: automatic/manual (if exposed).
   - **By seats**: number picker (if exposed).
   - Apply filters → returns to car list with filtered results via `GET /cars/filter?brand=X&price_max=Y&...`.
   - Clear filters → resets to default list.

3. **Sort by**:
   - Options: price (low-to-high, high-to-low), rating, newest.
   - Selector visible on main screen or via filter menu (exact UX unclear from this read).
   - Applied locally or via query param to API call.

4. **Tap car card** → routes to `/car` (car detail screen, `CarsInformation`).

5. **Scroll pagination**:
   - Endless scroll: reaching end of list loads next page.
   - `CarsCubit` pagination triggered automatically.

6. **Infinite scroll behavior**: Loading indicator shown at bottom while fetching.

**Empty state**: No results for search/filters → "No cars found" message, retry or clear filters.

**Loading state**: Skeleton loaders shown for each car card while fetching.

**Error state**: Network error → "Check your connection" snackbar, retry button.

**Endpoints**:
- `GET /cars/filter` (with query params: `search`, `brand`, `price_max`, `price_min`, `perPage`, `page`, etc.).
- `GET /manufactories` (populates brand filter dropdown).

---

## 5. CAR DETAILS

**Entry point**: Car list → tap car card → `/car` route (`CarsInformation`).

**What is shown**:

1. **Header**: Car name (brand + model + year).
2. **Image carousel**: Main photo + thumbnails. Tap to expand to full-screen gallery (`/car-images`).
3. **Basic info row**: Transmission, seats, A/C, other specs (shown as icons + labels).
4. **Availability**: "Book today" badge if `bookToday: true`; otherwise, unavailable or "Order in advance" label.
5. **Pricing table**:
   - Rental duration options: 1-month, 3-month, 6-month, 9-month, 12-month.
   - For each: original price (struck through if discount) + discounted price (if applicable).
   - Prices pulled from car object (e.g., `price1Month`, `priceAfter1Month`).
6. **Favorite button** (heart icon, top-right): Toggles favorite status.
   - Endpoint: `POST /favorite/{carId}` (toggle; response indicates success).
   - Visual feedback: icon fills/empties.
7. **Description** (if available): Car features, brand story, rental terms.
8. **Rental flow entry**: Tap "Book Now" (or per-duration "Select") → routes to booking flow based on selected duration (daily/monthly/etc.).

**Actions**:

1. **Tap favorite button** → `POST /favorite/{carId}` → updates local state, toggles icon.
2. **Tap duration button** (e.g., "1 Month") → builds `BookingDraft` and routes to next booking screen (additions, or if not all fields set, to branch selection).
3. **Swipe photos** → carousel advances.
4. **Tap photo** → `/car-images` full-screen gallery.
5. **Scroll down** → reveals more details, rental terms, reviews (if present).
6. **Tap back** — returns to car list.

**Requires login**:
- Favorite: toggles without login (local state only? or fails silently?).
- Book: `requireAuth()` modal if guest or unauthenticated.

**Guest mode**: Can view all details; booking shows modal; favorite may be visual-only or unsaved.

**Loading state**: Skeleton loaders for image, pricing table while fetching car details.

**Error state**: If car not found → 404 or error screen; back button returns to list.

**Endpoints**: None directly called from this screen (car data passed as route parameter, pricing already in object).

**Half-built**: Unclear whether all fields (transmission, seats, A/C) are always populated; some cars may lack specs.

---

## 6. FAVOURITES

**Entry point**: Profile tab → tap "Favorites" card → `/favourites` route (`Favourites` screen).

**What is shown**:
- List of user's previously favourited cars.
- If no favorites: "You have no favorite cars" message + "Browse cars" CTA.
- Each car shown as a card (image + name + price + favorite button).

**Actions**:

1. **Tap car card** → routes to `/car` (car detail, same as from main car list).
2. **Tap favorite (heart) icon on card** → `POST /favorite/{carId}` (toggle off).
   - Card removed from list or visual state updated immediately (optimistic).
   - If request fails: reverts and shows error toast.
3. **Tap "Browse cars" CTA** (if list empty) → navigates to `/fleet` (car search).
4. **Scroll** → paginated list of favorites (if > 10 or configured perPage limit).

**Requires login**: Yes. Guest shows "Not Authenticated" or redirects to sign-in.

**Guest mode**: Cannot view or modify favorites (not accessible).

**Empty state**: "You have no favorite cars yet" + browse CTA.

**Loading state**: Skeleton loaders for favorite cards while fetching list.

**Error state**: Network error → "Failed to load favorites" + retry button.

**Endpoints**: 
- `GET /profile` (re-used to read the `favorites` field — **shared endpoint** with profile data, parsed differently).
- `POST /favorite/{carId}` (toggle).

---

## 7. OFFERS

**Entry point #1**: Home screen → tap offer banner (if offers available) → `/offers` route.
**Entry point #2**: Home screen → scroll to "Offers" teaser section → tap "View all" → `/offers`.
**Entry point #3**: Notifications → tap offer notification → `/offers` (via `routeFromNotification`).

**What user sees**:

1. **On `/offers` screen** (`OffersScreen`):
   - Header: "Offers" title.
   - List of available offers (cards, each showing: offer image, title, description, discount percentage or amount, "View Details" button).
   - If no offers: "No offers available" message.

2. **On `/offer-details` screen** (`OfferDetailsScreen`):
   - Offer title, full image, detailed description, discount terms, expiry date (if applicable), T&Cs.
   - "Apply to Booking" button or "See Applicable Cars" (unclear from this read).

**How offers work**:

- Offers are **published by backend** via `/offers` endpoint; not all offers may be applicable to all users or cars.
- Discount may be a **fixed amount** (e.g., "50 SAR off") or **percentage** (e.g., "10% off rental").
- Offers appear to be **applied manually** via coupon code in payment flow, not automatically.
- At `/payment-methods` screen: coupon input field + "Apply" button → `POST /order/coupon` with code.
- On success: discount reflected in invoice total (`/orders/step2` call).

**How discount affects price**:
- Original price shown (struck through if discount applied).
- Final price = original - discount.
- Applied at order level, not per-car (applied to entire booking total).

**What the app shows**:
- Offer teaser on home (via `/check_for_offers` endpoint, different from full `/offers`).
- Full offers list and details via `/offers` and `/offers/{id}`.
- Two separate endpoints for "offers" concept; backend distinction unclear.

**Actions**:

1. **View offer details** → tap offer card → `/offer-details/{id}`.
2. **Go back** → returns to offers list or home.
3. **During booking (payment screen)**:
   - Tap "Promo Code" / "Coupon" field.
   - Modal sheet opens (coupon picker, `CouponBottomSheet`).
   - Tap coupon code to apply.
   - Endpoint: `POST /order/coupon` with coupon code.
   - On success: discount added to invoice, totals recalculated.

**Requires login**: Yes. Guest cannot apply coupons (booking blocked anyway).

**Guest mode**: Can view offers on home, but cannot apply to booking.

**Empty state**: "No offers available" on `/offers`.

**Loading state**: Skeleton loaders for offer cards.

**Error state**: Network error → "Failed to load offers" + retry.

**Endpoints**:
- `GET /check_for_offers` (home teaser; returns `message` + `discountValue`).
- `GET /offers` (full list).
- `GET /offers/{id}` (single offer detail).
- `POST /order/coupon` (apply to booking).
- `POST /order/delete-coupon` (remove from booking).

---

## 8. PAYMENT

**Entry point**: Branch/car selection → additions screen → `/payment-methods` (embedded in additions screen as child widget, not via route).

**Payment methods available**:

| Method | Display Name | Code | Status | Notes |
|--------|---|---|---|---|
| Visa/Card | "Visa" | `visaActive` | Enabled by config | 3-D-Secure redirect to `/web-payment` for verification |
| Cash | "Cash on Delivery" | `cashActive` | Enabled by config | Paid at pickup; no online processing |
| Loyalty Points | "Points" | `pointsActive` | Enabled by config | Deducts from user's loyalty balance (fetched from oracle backend) |
| Madfou | "Madfou" (Saudi BNPL) | `madfouActive` | Enabled by config | Buy-now-pay-later service |
| Tamara | "Tamara" (Saudi BNPL) | `tamaraActive` | Enabled by config | Buy-now-pay-later service (alternative to Madfou) |
| Cashback | "Use Cashback" | checkbox | Enabled | Applies user's account balance (from `/cashback/balance`) to order |

**Where choice is made**:
- `/payment-methods` screen: radio buttons or toggle list showing all available methods.
- Visa/card and BNPL methods show as clickable options; tap to select.
- Cash shown as default or included option.
- Points shown as separate checkbox (can combine with other method? unclear).
- Cashback shown as separate checkbox widget (can combine with primary method? unclear).

**Flow after selection**:

1. **Visa/Card selected**:
   - `POST /orders/step3` with card data.
   - If 3-D-Secure required: response contains redirect URL.
   - Routes to `/web-payment` (WebView) to handle redirect.
   - After user completes 3-D-Secure: returns to app, `POST /orders/step3` verification.
   - On success: routes to booking-confirmed screen.
   - On failure: error shown, returns to payment method selection.

2. **Cash selected**:
   - `POST /orders/step3` with `method: "cash"`.
   - No redirect needed.
   - On success: routes to booking-confirmed screen (user pays at pickup).

3. **Loyalty Points selected**:
   - `POST /order/points` with amount to deduct.
   - Points balance fetched from oracle backend (`{oracleApi}/customerSync/{idNumber}`).
   - Deducted from user's account.
   - May require full balance or allow partial; unclear from this read.

4. **Madfou/Tamara selected**:
   - `POST /orders/step3` with `method: "madfou"` or `"tamara"`.
   - Likely redirects to BNPL provider's payment flow (unclear from code read).
   - On success: routes to booking-confirmed.

5. **Cashback applied**:
   - `POST /cashback/apply-to-order` with amount.
   - Applied to current order total.
   - Can combine with primary payment method (paying remainder via Visa, cash, etc.; exact combination logic unclear).

**Payment success**:
- `POST /orders/step3` returns success.
- Routes to `/booking-confirmed` (bottom-sheet modal showing booking reference, car details, dates, total paid).
- User can tap "View Booking" → `/bookings` or "Continue" → `/home`.

**Payment failure**:
- Error message shown (backend-supplied).
- User remains on payment screen; can retry method selection or cancel.

**Requires login**: Yes. Guest cannot reach payment (booking blocked at branch selection via `requireAuth()`).

**Coupon / Promo code**:
- Applied at payment screen via modal sheet picker.
- `GET /order/coupons` (fetch available codes).
- `POST /order/coupon` (apply).
- On success: invoice recalculated, discount shown.

**Endpoints**:
- `POST /orders/step2` (invoice calculation).
- `POST /orders/step3` (payment processing).
- `POST /order/coupon` (apply coupon).
- `POST /order/delete-coupon` (remove coupon).
- `POST /order/points` (apply loyalty points).
- `POST /cashback/apply-to-order` (apply cashback).
- `GET {oracleApi}/customerSync/{idNumber}` (fetch loyalty balance).

**Half-built / unclear**:
- Exact rules for combining payment methods (points + cash? cashback + visa?) not determined from this read.
- Tamara/Madfou integration details (redirect flow, response handling) not found; flagged `TODO` in code.

---

## 9. PROFILE

**Entry point**: Profile tab (`/profile` shell branch, `MyProfile` screen).

**Authentication requirement**: Yes. Guest users see "Sign In / Register" placeholder instead of profile content.

**On arrival (if authenticated)**:
- User's avatar (profile image) shown at top.
- Menu of options (tiles, each with icon + label + tap to navigate).

**Sections / Options available**:

1. **Edit Profile** (`/edit-profile`):
   - **Editable fields**:
     - First name
     - Last name
     - Email
     - Phone
     - Address
     - Avatar (image upload)
     - Licence image (upload or camera capture)
   - **Validation**:
     - Email: RFC format.
     - Phone: valid number for country.
     - Name fields: required, no special chars (likely).
   - **Upload**: Multipart `POST /profile` (body fields + avatar file + licence file).
   - **On success**: "Profile updated" toast, returns to profile.
   - **On failure**: error message, stays on edit form.

2. **Wallet (Cashback)** (`/cashback`):
   - Shows current cashback balance (from `GET /cashback/balance`).
   - Transaction history (paginated, from `GET /cashback/transactions`).
   - "Use in Booking" button (applies cashback during payment).
   - Each transaction shows: date, amount, description (booking ref? refund?), status.

3. **Select Language**:
   - Tap → language picker dialog (in-place, not full-screen route).
   - Options: العربية (Arabic), English.
   - Persist to SharedPreferences, trigger full-app locale rebuild (all screens re-render in new language).

4. **Change Password** (`/reset-password`):
   - Form: current password, new password, confirm password.
   - Validation: new password != current, 6+ chars.
   - Endpoint: `PUT /profile` (with `password` field; reuses profile-update URL, confusing naming in code).
   - **On success**: "Password changed" toast, returns to profile.
   - **On failure**: error message (e.g., "Current password incorrect").

5. **Favorites** (`/favourites`):
   - List of user's favourited cars (see section 6 above for details).

6. **View Branches** (`/branches`):
   - Browse all rental branches (name, address, phone, map location).
   - Tap branch → `/view-location` (not a live route; reached via `PersistentNavBarNavigator.pushNewScreen` instead).
   - Shows branch details + map.

7. **Complaints** (`/complaints`):
   - Form to submit complaint about rental experience.
   - Fields: complaint type dropdown, description text, photos (optional?).
   - Endpoint: `POST /complaints`.
   - On success: "Complaint submitted" toast, form clears.

8. **Privacy Policy** (`/privacy-policy`):
   - Full legal text (toggles between Arabic/English based on app locale).
   - Sourced from `SettingsCubit` (fetches from `/settings`), falls back to hardcoded text if fetch fails.
   - Read-only, no actions.

9. **Terms & Conditions**:
   - Same source as privacy policy; shown separately or together (unclear from this read).

10. **Account Deletion**:
    - Tap → confirm dialog ("Are you sure? This cannot be undone.").
    - `POST /deleteAccount` endpoint.
    - On success: logs out, token cleared, returns to splash screen.
    - On failure: error message, stays on profile.

11. **Logout** (or similar):
    - Clears token from SharedPreferences.
    - Clears `userData`, `userPassword` prefs.
    - Routes to splash screen.
    - Confirms `AuthStatusCubit` emits `false`.

**Empty state**: No profile data fetched yet → skeleton loaders.

**Loading state**: While fetching profile → skeleton loaders for each field.

**Error state**: Fetch failure → "Failed to load profile" + retry button; options still accessible but may show stale data.

**Endpoints**:
- `GET /profile` (fetch user data).
- `PUT /profile` (update profile fields + password change).
- `POST /deleteAccount` (account deletion).
- `GET /settings` (privacy/terms text; via `SettingsCubit`).
- `GET /cashback/balance`, `GET /cashback/transactions` (cashback data).

**Half-built / unclear**:
- Whether documents (licence, ID) are mandatory or optional on first setup.
- Whether profile image is shown as avatar in other screens (e.g., home tab top-right).
- Exact password validation rules (length, special chars, etc.).

---

## 10. NOTIFICATIONS

**Status**: Code present, wiring incomplete. Firebase Messaging infra exists but tap-to-navigate not wired.

**What exists**:

1. **Push Notification Service** (`lib/core/helpers/notifications/push_notification_service.dart`):
   - Firebase Cloud Messaging (FCM) initialized on app boot.
   - `flutter_local_notifications` wired for foreground display (OS banner while app is active).
   - Android channel: `high_importance_channel` (high priority, will interrupt user).
   - iOS: Not functional (GoogleService-Info.plist absent; see CLAUDE.md).
   - Device token fetched via `getDeviceToken()` (guarded try/catch, never throws; handles devices without Google Play Services).
   - **NOT wired**: Token-to-backend (token not sent on login/logout).
   - **NOT wired**: Tap-to-navigate (FCM `onMessageOpenedApp` / `getInitialMessage` not subscribed).

2. **In-app Notifications List** (`/notifications` route, `NotificationsScreen`):
   - Paginated list of user's notifications.
   - Endpoints (marked `TODO(api): confirm` — never validated against real backend):
     - `GET /notifications` (fetch list, 15 per page).
     - `POST /notifications/read/{id}` (mark one as read).
     - `POST /notifications/read-all` (mark all as read).
   - Model shape guessed, not confirmed; payload structure may differ from code assumptions.
   - Notification types: `cashback`, `booking`, `offer`, `update`, `unknown`.
   - **Optimistic marking**: UI updates before server confirmation; reverts on failure.

3. **Notification Routing** (`lib/core/router/notification_router.dart`):
   - `routeFromNotification(context, type:, data:)` — THE single source of truth for notification type → screen route.
   - Mapping:
     - `cashback` → `/cashback`.
     - `booking` → `/bookings`.
     - `offer` → `/offer-details` or `/offers` (based on `data`).
     - `update` / `unknown` → `/home`.
   - Used by: in-app notifications list (tapping a notification).
   - **NOT yet used by**: FCM callbacks (phase C of FCM integration, not wired).

**What is broken / incomplete**:

- **iOS push not working**: No APNs configuration, plist missing.
- **Background tap handling**: Pushing a notification to Android, going to system tray, tapping it → just opens app (no navigation). The destination mapping exists but is never called by FCM.
- **Foreground notification text**: Unclear what text is displayed; code creates a local notification for any received message, but exact formatting not traced.
- **Backend integration**: Endpoint shape unconfirmed; code may not match real server response.

**Guest mode**: Guest can receive push notifications (if backend sends them), but tapping the notification only opens the app (since navigation not wired); in-app list not accessible without login.

**Endpoints**:
- `GET /notifications` (list, marked `TODO(api)`).
- `POST /notifications/read/{id}` (mark one read, marked `TODO(api)`).
- `POST /notifications/read-all` (mark all read, marked `TODO(api)`).

---

## 11. ORDERS / BOOKINGS HISTORY

**Entry point**: Bookings tab (`/bookings` shell branch, `AllBookingScreen`).

**Authentication requirement**: Yes. Guest sees "Not Authenticated" message + "Log In" button; no booking data shown.

**On arrival (if authenticated)**:
- Three sub-tabs: "Running", "Previous", "Not Completed".
- Default tab shown: unclear (likely "Running" or most recent).

**Sub-tabs**:

### 11a. Running Bookings (`running_now.dart`)
- **What shown**: Active, ongoing rentals (pickup already happened, dropoff in future).
- **Each booking card displays**: 
  - Car name/model + image.
  - Pickup date/time, branch name.
  - Dropoff date/time, branch name.
  - Total rental duration (days).
  - Total price paid.
  - Status badge: "Active" or "Running".
  - Action buttons: "View Details", potentially "Extend" (unclear), "Help/Contact".

- **Actions**:
  - **Tap card or "View Details"** → `/book-details` (booking detail screen).
  - **Tap "Extend"** (if present) → unclear from this read; may open a dialog to extend rental (not fully traced).
  - **Tap "Help" / contact** (if present) → may open complaint form or contact support (unclear).

- **What requires login**: Shown only to authenticated users; guest sees error message.

### 11b. Previous Bookings (`previousOrders.dart`)
- **What shown**: Completed, past rentals (dropoff already happened).
- **Each booking card displays**: Same fields as running (car, dates, price, status: "Completed").
- **Actions**:
  - **Tap card or "View Details"** → `/book-details`.
  - **Tap "Book Again"** (if present) → likely pre-fills a new booking with same car/dates or just navigates to car detail (unclear).
  - **Tap "Leave Review"** (if present) → may open review/rating form (not traced).

### 11c. Not Completed (`notCompletedOrder.dart`)
- **What shown**: Bookings that were initiated but not finalized (e.g., left at payment screen, payment failed, or booking in draft state).
- **Each card displays**: Car name, selection dates/branch, price so far, status: "Incomplete" or "Abandoned".
- **Actions**:
  - **Tap "Resume"** → returns to the booking flow at the last step (additions or payment, depending on how far the user got). State restored from `OrderId` or draft.
  - **Tap "Delete"** → `POST /orders/delete-order` (remove abandoned booking). Confirmation dialog shown first.
  - **Tap "View Details"** → `/book-details` (view partial booking info).

### General Actions:

- **Tap a booking card** → `/book-details` (booking detail screen):
  - Full details: car specs, pickup branch, dropoff branch, dates, time, duration, extras ordered (if any).
  - Invoice/pricing breakdown (base rental, extras, taxes, discounts, total).
  - Status (Active, Completed, Not Completed).
  - Buttons: "Cancel Booking" (if active), "Download Invoice", "Contact Support", back.

- **Tap "Cancel Booking"** (if active):
  - Confirmation dialog: "Are you sure? Cancellation fees may apply."
  - `PUT /order/cancel` endpoint.
  - On success: status changes to "Cancelled", booking moved to "Previous" tab (or removed).
  - On failure: error message, booking remains active.

- **Pagination**: Each tab shows ~10-15 bookings initially; scroll to load more (endless scroll).

- **Sorting**: Bookings likely sorted by date (most recent first), no user-visible sort option.

**Empty state**: No bookings in tab → "You have no [running/previous/incomplete] bookings" + CTA ("Browse cars" or "Start a booking").

**Loading state**: Skeleton loaders for booking cards while fetching `GET /orders/get-orders`.

**Error state**: Network error → "Failed to load bookings" + retry button; cached data shown if available.

**Endpoints**:
- `GET /orders/get-orders` (fetch all bookings, filtered by status on client).
- `PUT /order/cancel` (cancel active booking).
- `POST /orders/delete-order` (delete incomplete booking).

**Half-built / unclear**:
- Whether "Extend" booking is functional or just UI.
- Whether "Resume" incomplete booking actually restores state or just links to a new booking.
- Whether review/rating submission is wired.
- Exact cancellation fee logic (shown where? calculated when?).

---

## 12. ANYTHING NOT LISTED

### 12a. **Settings** (via Profile screen or inline dialog)
- Accessed via language picker (in-place dialog) or settings gear icon (if present on home).
- **Theme toggle**: Light/Dark mode selector (visible as icon in app bars).
  - `ThemeCubit` controls app-wide theme.
  - Persisted to SharedPreferences (likely), auto-applied on app restart.
- **Language selector**: Arabic / English (see section 9).
- **Version check**: `/settings/version` endpoint called on app boot (`ShellScaffold._checkVersion()`).
  - If newer version available: `UpdateDialog` shown ("Update Available" modal with app store link).
  - User can dismiss or tap "Update" to open store.

### 12b. **Map / Location Picker** (Delivery flow only)
- Used in delivery rental: user picks a delivery location on a map constrained by service area.
- Route: `/location-picker` (`LocationPickerFull`).
- Shows: Google Map with branch polygon boundary, user can drag marker within boundary.
- Constraints: point-in-polygon check (marker must stay inside region's polygon).
- **Not covered in this spec** (flagged out-of-scope; areas feature separate).

### 12c. **Time Picker** (All booking flows)
- Used to select pickup/dropoff times.
- Custom widget (not Flutter's built-in).
- Constraints applied: times outside branch working hours disabled (not hidden).
- Constraint also: pickup time must be ≥2 hours from now (FR-022).
- Dropoff time must be after pickup (obvious).
- Final validation via `POST /available/time` before submission.
- **Not covered in detail** (booking flow out of scope).

### 12d. **Additions / Extras** (After branch selection, before payment)
- User selects rental add-ons (e.g., GPS, child seat, extra driver, insurance).
- Route: `/additions`.
- `AdditionsCubit` fetches available add-ons via `POST /orders/step1`.
- Endpoint returns list of available extras + their prices.
- User toggles each extra (checkbox or toggle).
- Running total updated as user selects/deselects.
- Cashback balance shown as separate widget; user can toggle "Use Cashback" checkbox.
- "Proceed to Payment" button → routes to `/payment-methods` (or embedded payment view).
- **Not fully covered** (booking flow out of scope; section 8 covers payment methods accessible from here).

### 12e. **Account Linking** (if any)
- Not found in this read.
- Unclear whether user can link multiple accounts, social profiles, etc.

### 12f. **Offline Support**
- Home screen and car list accessible without internet (cached data).
- Booking flows, payment, and API calls fail gracefully with offline error message + retry button.
- No true offline booking (all booking actions require server).

### 12g. **Deep Linking / App Shortcuts** (if any)
- Routes built with go_router, but **`extra` is not serializable** (per CLAUDE.md, codebase-inventory).
- No deep-link support for routes with parameters (e.g., `/car/123` unreachable; `/car` with `extra: carId` is not restorable).
- App restarts → splash screen → home (no restoration of navigation stack).
- Tab paths (`/home`, `/fleet`, `/bookings`, `/profile`) are navigable by plain URL string.

### 12h. **Loyalty Program / Points System**
- User's loyalty points balance fetched from **separate oracle backend** (`{oracleApi}/customerSync/{idNumber}`).
- Used at payment screen: user can apply points to reduce booking total.
- Endpoint called with national ID; returns `{ "points": <balance> }`.
- **NOT integrated into login/signup** (backend integration separate).
- Shown as widget on payment screen if enabled by config (`pointsActive`).

### 12i. **Analytics / Logging**
- Firebase Analytics likely wired (firebase_core, firebase_messaging in deps).
- Event logging not visible in this read (not traced).

### 12j. **Accessibility**
- No specific accessibility features traced (no alt text, no semantic labels noted).
- Skeletonizer used for loading states (provides bone animations).
- Text-scale clamping applied (0.8–1.2× system scale).

### 12k. **Known Incomplete / Dead Codepaths**

Per codebase-inventory section 5:

- **`RentType.automated`**: Parallel "contracts" booking flow. Never set in code; entire `BookingAutomationCubit` + `/contracts/*` endpoints appear unreachable by UI.
- **`/categories` endpoint**: Fetched via `CategoryRemotDataSource` but no cubit consuming it found; data fetched into nothing.
- **Bare `Dio()` instances**: 22 call sites bypass shared interceptor (no auth, no baseUrl, no timeouts). Code debt; all new code should use `sl<Dio>()`.
- **`package:http` still in use**: 10 files still import legacy `package:http` despite migration to Dio elsewhere; not removed in Phase 8 cleanup (10 other importers remain, so package not dropped).
- **`AreasListView` orphaned**: Lost its only caller in Phase 8; contains a live Principle I violation (name-based lookup) but unreachable.
- **`AllBranchRepository` + cache orphaned**: `BranchRepository.getBranches()` has zero remaining callers; `branches_box` Hive storage read/written only by this dead code.
- **Factory cubits behaving as singletons**: `AdditionsCubit`, `ProfileCubit`, `AllBookingCubit`, `InvoiceCubit` registered `registerFactory` but provided once at app root; singleton-like behavior, state leaks across booking flows known for additions.

---

## Summary of Accuracy Notes

**Confirmed by code reading**:
- Auth methods (email, phone, OTP, password reset).
- Payment methods (Visa, cash, points, Madfou, Tamara, cashback).
- Profile editable fields + endpoints.
- Notifications API (endpoints marked `TODO(api)` so shape unconfirmed).
- Bookings list structure (running, previous, incomplete tabs).

**Unclear from code alone**:
- Whether "Extend booking" is functional or stub UI.
- Whether "Resume incomplete booking" restores state or just re-routes.
- Exact combination logic for multiple payment methods (points + cash? cashback + Visa?).
- Social login (if supported).
- Deep-link behavior on cold app start.
- Exact password/email validation rules.
- Whether notification payload shapes match code assumptions (`TODO(api)` in constants).

**Inconsistencies / Contradictions**:
- Two "/offers" endpoints (`/check_for_offers` vs. `/offers`) serve the same concept; backend distinction unclear.
- Profile URL `/profile` used for both GET (fetch) and PUT-shaped (update, multipart); PUT path reused for password change too.
- `mainApi` constant `productionApi_darakson` actually used; `productionApi` defined but unused (different domain, confusing).

---

**Report generated**: 2026-09-07  
**Scope notes**: Booking flows (region selection, branch selection, date/time picking), delivery map constraints, and location module details deliberately excluded per user request. See `specs/001-region-branch-selection/` for those.
