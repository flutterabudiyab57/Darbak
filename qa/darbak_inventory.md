# Darbak App — QA Feature Inventory

> **Resume point:** see [qa/darbak_qa_progress.md](darbak_qa_progress.md)

> **Purpose:** Single source of truth for QA test-case generation.
> **Scope:** `lib/` only. No build artifacts, generated files, or native folders.
> **Last updated:** 2026-08-16
> **Methodology:** Static analysis; no `flutter` commands run.

---

## Routes

All routes are defined in `lib/core/router/app_router.dart` and named in `lib/core/router/routes.dart`.

**Router config:** `GoRouter`, `initialLocation: '/'`. No top-level redirect guard. Auth gating is splash-driven (checks token in SharedPreferences, then calls `context.go('/home')` or `context.go('/language')`). `extra:` params are not serializable — **no route is reachable by deep link or URL restoration**.

| Path | Route name (Routes.*) | Screen widget | extra / Args type | Guarded? | Transition | Source |
|---|---|---|---|---|---|---|
| `/` | `splash` | `SplashScreenOld` | none | public | default | `app_router.dart` |
| `/language` | `language` | `SelectLanguage` | `bool?` (isFirstLaunch) | public | FadeTransition | `app_router.dart` |
| `/onboarding` | `onBoarding` | `OnBoarding` | none | public | FadeTransition | `app_router.dart` |
| `/signin` | `signin` | `SignInScreen` | `AuthScreenArgs?` (isLogin, cubit, pushAddition) | public | default | `app_router.dart` |
| `/register` | `register` | `RegisterPage` | `AuthScreenArgs?` | public | default | `app_router.dart` |
| `/otp` | `otp` | `OtpVerifyScreen` | `OtpArgs` (userId, phone) — **required** | public | default | `app_router.dart` |
| `/forgot-password` | `forgotPassword` | `ForgotPasswordScreen.entry()` | none | public | default | `app_router.dart` |
| `/enter-code` | `enterCode` | `EnterCodeScrean` | none | public | default | `app_router.dart` |
| `/change-password` | `changePassword` | `ChangePasswordScreen` | none | public | default | `app_router.dart` |
| `/error` | `errorPage` | `ErrorPage` | none | public | default | `app_router.dart` |
| **StatefulShellRoute** (4-tab bottom nav, `ShellScaffold`) | — | — | — | authenticated | — | `app_router.dart` |
| `/home` (branch 0) | `home` | `SearchScreen.entry()` | none | authenticated | — | `app_router.dart` |
| `/fleet` (branch 1) | `fleet` | `AllCarsScreen.entry(fromFilter:false)` | none | authenticated | — | `app_router.dart` |
| `/bookings` (branch 2) | `bookings` | `AllBookingScreen` | none | authenticated | — | `app_router.dart` |
| `/profile` (branch 3) | `profile` | `MyProfile` | none | authenticated | — | `app_router.dart` |
| `/cars` | `allCars` | `AllCarsScreen.entry(...)` | `AllCarsArgs?` (filterModel, fromFilter, model) | authenticated | default | `app_router.dart` |
| `/car` | `carsInformation` | `CarsInformation` | `CarsInformationArgs` (datum, filterModel, stockStatus) — **required** | authenticated | default | `app_router.dart` |
| `/filter-cars` | `filterCars` | `FiltersCars.entry()` | none | authenticated | default | `app_router.dart` |
| `/search-cars` | `searchAboutCar` | `SearchCarScreen` | none | authenticated | FadeTransition | `app_router.dart` |
| `/car-images` | `imageCarPage` | `ImageCarPage` | `List<Photo>` | authenticated | default | `app_router.dart` |
| `/classic` | `classic` | `Clasic.entry()` | none | authenticated | default | `app_router.dart` |
| `/branch-with-car` | `branchWithCar` | `BranchWithCarScreen` | `DataCars` | authenticated | default | `app_router.dart` |
| `/daily-package` | `dailyPackage` | `DailyPackages` | none | authenticated | default | `app_router.dart` |
| `/monthly-package` | `monthlyPackage` | `MonthlyPackageScreen.entry()` | none | authenticated | default | `app_router.dart` |
| `/airport-package` | `airportPackage` | `AirportPackageScreen.entry()` | none | authenticated | default | `app_router.dart` |
| `/delivery-package` | `deliveryPackage` | `DeliveryPackageScreen.entry()` | none | authenticated | default | `app_router.dart` |
| `/package-cars` | `carsListPackage` | `CarsListPackage.entry(filterModel:...)` | `FilterModel?` | authenticated | default | `app_router.dart` |
| `/monthly-cars` | `carsMonthly` | `CarsMonthlyScreen.entry(filterModel:...)` | `FilterModel?` | authenticated | default | `app_router.dart` |
| `/additions` | `additions` | `AdditionsScreen` | `AdditionsArgs?` (datum, checkOrderStepModel, bookDetails, fromNotCompleted, fromAddAdditions) | authenticated | default | `app_router.dart` |
| `/book-details` | `bookDetails` | `BookDetails` | `BookDetailsArgs` (bookingData, dataCars, checkOrderStepModel, isNotCompleted) — **required** | authenticated | default | `app_router.dart` |
| `/booking-confirmed` | `bookingConfirmed` | `BookingConfirmedBottomSheet` | `BookingConfirmedArgs?` (orderId, carName, total) | authenticated | `BottomSheetPage` | `app_router.dart` |
| `/payment-methods` | `paymentMethods` | `PaymentMethodsScreen` | `PaymentMethodsArgs` (newBooking, stepOneOrderModel, carModel, isAutomated, datum, isNotCompleted, orderId, cardModel) — **required** | authenticated | default | `app_router.dart` |
| `/invoice` | `invoice` | `InvoiceUI` | `InvoiceArgs?` (carModel, invoiceModel, isApplePay, isNotCompletedOrder, hideAddition, allBookingData, totalApplePay, orderID, paymentType, checkOrderStepModel) | authenticated | default | `app_router.dart` |
| `/web-payment` | `webPayment` | `WebPayment` | `String?` (URL) | authenticated | default | `app_router.dart` |
| `/invoice-not-completed` | `invoiceNotCompleted` | `InvoiceNotCompletedUI` | `InvoiceArgs?` (same minus invoiceModel) | authenticated | default | `app_router.dart` |
| `/location-picker` | `locationPicker` | `LocationPickerFull` | `LocationPickerArgs?` (initialLocation, searchRadius, bounds, centerOverride) | authenticated | default | `app_router.dart` |
| `/view-location` | `viewLocation` | `ViewLocation` | `ViewLocationArgs` (url, title, lat, long) | authenticated | CupertinoPage | `app_router.dart` |
| `/call-us` | `callUs` | `CallUs` | none | authenticated | default | `app_router.dart` |
| `/edit-profile` | `editProfile` | `EditProfile` | none | authenticated | default | `app_router.dart` |
| `/favourites` | `favourites` | `Favourites` | none | authenticated | default | `app_router.dart` |
| `/reset-password` | `resetPassword` | `ResetPasswordScrean` | none | authenticated | default | `app_router.dart` |
| `/branches` | `branches` | `BranchesScreen.entry()` | none | authenticated | CupertinoPage | `app_router.dart` |
| `/cashback` | `cashback` | `CashbackScreen` | none | authenticated | default | `app_router.dart` |
| `/complaints` | `complaints` | `ComplaintScreen.entry()` | none | authenticated | default | `app_router.dart` |
| `/offers` | `offers` | `OffersScreen` | `bool?` (fromNotification) | authenticated | default | `app_router.dart` |
| `/offer-details` | `offerDetails` | `OfferDetailsScreen` | `int` offerId | authenticated | default | `app_router.dart` |
| `/privacy-policy` | `privacyPolicy` | `PrivacyPolicyScreen` | none | authenticated | default | `app_router.dart` |
| `/notifications` | `notifications` | `NotificationsScreen.entry()` | none | authenticated | default | `app_router.dart` |
| `/select-language` | `selectLanguage` | `SelectLanguage` | `bool?` | authenticated | default | `app_router.dart` |

**Total routes: 48** (1 root + 10 public pre-auth + 4 shell branches + 33 authenticated top-level)

---

## Feature Modules

### Module: Auth

**Folder:** `lib/modules/auth/`

#### Screens

| Screen class | File | Route |
|---|---|---|
| `SplashScreenOld` | `lib/modules/auth/splash_screen.dart` | `/` |
| `OnBoarding` | `lib/modules/auth/on_boarding/on_boarding.dart` | `/onboarding` |
| `SelectLanguage` | `lib/modules/home/selectLanguage/selectLanguage.dart` | `/language`, `/select-language` |
| `SignInScreen` | `lib/modules/auth/signin/presentation/pages/signin_screen.dart` | `/signin` |
| `RegisterPage` | `lib/modules/auth/register/presentaion/pages/register_page.dart` | `/register` |
| `OtpVerifyScreen` | `lib/modules/auth/register/presentaion/pages/otp_register.dart` | `/otp` |
| `ForgotPasswordScreen` | `lib/modules/auth/forgotPassword/presentaion/widgets/forgotPassword.dart` | `/forgot-password` |
| `EnterCodeScrean` | `lib/modules/auth/forgotPassword/presentaion/page/enter_code.dart` | `/enter-code` |
| `ChangePasswordScreen` | `lib/modules/auth/forgotPassword/presentaion/page/change_password.dart` | `/change-password` |
| `ErrorPage` | `lib/modules/auth/forgotPassword/presentaion/page/errorPage.dart` | `/error` |
| `SuccessBottomSheet` | `lib/modules/auth/forgotPassword/presentaion/page/successPage.dart` | (no route — shown via `showModalBottomSheet`) |

**`ErrorPage`** (`errorPage.dart`): Full-page `Scaffold` shown at route `/error` when the password-reset flow encounters a server error. Renders `assets/images/error1.svg` + `locale.passwordChanged` text (key shared with `SuccessBottomSheet` — may be a copy/paste mistake; the text says "Password changed" on both success and error screens) + an `ADGradientButton` labelled `locale.goToHome` that calls `context.go('/signin')`. No retry mechanism.

**`SuccessBottomSheet`** (`successPage.dart`): Bottom sheet (41% screen height, animated on keyboard) shown after a successful password reset — called from `ChangePasswordScreen` via `showModalBottomSheet`. Renders `assets/icons/Ok_hand.png` + `locale.passwordChanged` + `locale.returnToLoginScreen` + a sign-in button that calls `Navigator.popUntil(isFirst)` then re-opens `SignInScreen` as a new modal bottom sheet. Uses `BackdropFilter(blur)` as the sheet background.

#### Cubits / Blocs

**`AuthStatusCubit`** (`lib/modules/auth/blocs/auth_status_cubit.dart`)
- State type: raw `bool?` (null = resolving, false = signed out, true = signed in)
- Methods: `markSignedIn()` → emits `true`; `markSignedOut()` → emits `false`
- Initialized in `service_locator.dart`, reads token from SharedPreferences on construction

**`OnBoardingCubit`** (`lib/modules/auth/blocs/auth_bloc/onboarding_cubt_cubit.dart`)
- State: `bool` (toggles `isLogin` tab between sign-in / register)
- Methods: `onChangeScreen()` → emits `!state`

**`SignInBloc`** (`lib/modules/auth/signin/presentation/bloc/signin_bloc.dart`)
- **States:** `SignInInitial`, `SignInLoading`, `SignInSuccess`, `SignInFailure(error: String)`, `ShowPassword`, `RegisterRequiresVerification(userId: String, phone: String)`
- **Event:** `SignIn(email, password)`
- **Methods:** `_onSignInEvent` → POST `/login`, saves token + password to SharedPreferences, calls `authStatus.markSignedIn()`
- On `requires_verification` in response → navigates to `/otp`

**`RegisterCubit`** (`lib/modules/auth/register/presentaion/bloc/register_cubit.dart`)
- **States:** `RegisterInitial`, `RegisterLoading`, `RegisterSuccess`, `RegisterError(massage: String)`, `ShowPassword`, `ImageProfileLodingState`, `ImageProfileScussesState`, `ImageProfileErrorState(error: String)`, `RegisterRequiresVerification(userId: String, phone: String)`
- **Methods:**
  - `getImage(String type)` — picks image via camera or gallery (`image_picker`)
  - `userRegister({name, email, phone, password, passworConfirm, idNumber, licenceFace, country_key})` → POST multipart `/register`; on `requires_verification` → navigates to `/otp`

**`ForgetPasswordCubit`** (`lib/modules/auth/forgotPassword/presentaion/bloc/forget_password_cubit.dart`)
- **States:** `ForgetPasswordInitial`, `ForgetPasswordLoading`, `ForgetPasswordLoaded`, `ForgetPassWordError(String)`, `CodeLoading`, `CodeLoaded`, `CodeError(String)`, `ChangePasswordLoading`, `ChangePasswordLoaded`, `ChangePassWordError(String)`
- **Methods:**
  - `sendPone({required String phone})` → POST `/password/forget`, body: `{phone}`
  - `sendCode({required String code})` → POST `/password/code`, body: `{token, code}`
  - `passwordchange({required String password, required String confirmPassword})` → POST `/password/reset`, body: `{token, password, password_confirmation}`

#### API Endpoints (Auth module)

| Method | Path | Cubit/Datasource | Source |
|---|---|---|---|
| POST | `/login` | `SignInBloc` → `SignInRemoteDataSourceImpl` | `lib/modules/auth/signin/` |
| POST | `/register` (multipart) | `RegisterCubit` → `RegisterRemoteDatasource` | `lib/modules/auth/register/` |
| POST | `/register/verify` | `RegisterCubit` → `RegisterRemoteDatasource` | `lib/modules/auth/register/` |
| POST | `/password/forget` | `ForgetPasswordCubit` → `ForgetPasswordDataSourse` | `lib/modules/auth/forgotPassword/` |
| POST | `/password/code` | `ForgetPasswordCubit` → `ForgetPasswordDataSourse` | `lib/modules/auth/forgotPassword/` |
| POST | `/password/reset` | `ForgetPasswordCubit` → `ForgetPasswordDataSourse` | `lib/modules/auth/forgotPassword/` |

#### User-facing flows
1. **Sign in** → enter identifier (email/phone/ID) + password → `POST /login` → shell (`/home`)
2. **Register** → fill form + upload license photo → `POST /register` → if `requires_verification` → OTP screen → `POST /register/verify` → shell
3. **Forgot password** → enter phone → `POST /password/forget` → enter code → `POST /password/code` → new password → `POST /password/reset` → on success: `SuccessBottomSheet` (navigates to sign-in); on failure: `ErrorPage` (`/error`, routes to `/signin`)
4. **Onboarding** → 3-page swipe → tap finish/skip → `/home`

---

### Module: Home / Search

**Folder:** `lib/modules/home/search_screen/`

#### Screens

| Screen class | File | Route |
|---|---|---|
| `SearchScreen` | `lib/modules/home/search_screen/presentaion/search_Screen.dart` | `/home` |

#### Cubit

**`SearchCubit`** (`lib/modules/home/search_screen/blocs/search_bloc/search_cubit.dart`)
- **States:** `SearchInitial`, `SearchLoading`, `SearchSuccess(List<BranchModel>)`, `GetAreaSuccess(List<AreasModel>)`, `SearchFailed(error)`, `SearchUpdatedState`, `SearchCheckLoading`, `SearchValidate(message)`, `SearchInvalid(message)`, `RegionsSuccess(regions?)`, `OffersLoding`, `OffersLoded(List<OffersModel>)`, `OffersErorr(message)`
- **Methods:**
  - `getRegions()` → GET `/regions`
  - `getAreas({pageNumber, regionId?})` → GET `/areas`
  - `getBranches({pageNumber, regionId?})` → GET `/branches?perPage=60`
  - `getDeliveryBranches()` → GET delivery-specific branches
  - `getAirPortBranches()` → GET airport-specific branches
  - `getAllBranches({pageNumber, regionId?})` → GET `/branches?perPage=60`
  - `selectBranch(String)`, `clearAllDataSearched()`, `resetBranches()`
  - `updateDates(receiveDate, driveDate)` — date picker integration
  - `validate()` / `validateDelivery()` → emits `SearchValidate` or `SearchInvalid`
  - `getOffers()` → GET `/check_for_offers`
  - `setDriveBranchLocation(LatLng)` — delivery GPS capture

#### API Endpoints

| Method | Path | Notes |
|---|---|---|
| GET | `/regions` | — |
| GET | `/areas?page=N&region_id=?` | — |
| GET | `/branches?perPage=60` | used by `AllBranchCubit` too |
| GET | `/check_for_offers` | search screen offer banner |

#### User-facing flow
- Select region → select receive branch/area → pick dates (receive + return) → validate → navigate to car list or package selection

---

### Module: Home / Cars (Fleet)

**Folder:** `lib/modules/home/cars/`

#### Screens

| Screen class | File | Route |
|---|---|---|
| `AllCarsScreen` | `lib/modules/home/cars/presentaion/all_cars_screen.dart` | `/fleet`, `/cars` |
| `CarsInformation` | `lib/modules/home/cars/presentaion/page/cars_info.dart` | `/car` |
| `FiltersCars` | `lib/modules/home/cars/presentaion/page/filter_cars.dart` | `/filter-cars` |
| `SearchCarScreen` | `lib/modules/home/cars/presentaion/search_cars/search_about_car.dart` | `/search-cars` |
| `ImageCarPage` | `lib/modules/home/cars/presentaion/page/image_car_page.dart` | `/car-images` |

#### Cubits

**`AllCarsCubit`** (`lib/modules/home/cars/presentaion/bloc/all_cars_cubit/all_cars_cubit.dart`)
- **States:** `AllCarsInitial`, `AllCarsLoding`, `AllCarsLoded`, `AllCarsLodError(String)`, `CarsSearchResult(data: List<DataCars>)`, `CarsImageLoadError(String)`
- **Methods:**
  - `getAllCars(int pageNumber, {int? branchId})` → GET `/cars/filter?page=N`
  - `getCarsByFilter(int pageNumber, {int? branchId})` → GET `/cars/filter?{filters}&page=N`
  - `searchCars(String searchTerm)` → GET `https://abudiyab-soft.com/cars/api?trem=...` (**legacy hardcoded URL**)
  - Paginates up to page 4

**`CarsCubit`** (`lib/modules/home/cars/presentaion/bloc/cubit/cars_cubit.dart`)
- **States:** `CarsInitial`, `CarsLoding`, `CarsLoded`, `CarsLodError(String)`, `CarsImageLoadError(String)`
- **Methods:** `getAllCars(int pageNumber, {int? branchId, String? castClass, String? languageCode})`, `getCarsByFilter(int pageNumber, {int? branchId})`, `emitPhotoError(e)`

**`FilterCubit`** (`lib/modules/home/cars/presentaion/bloc/filter_cubit/filter_cubit.dart`)
- **States:** `FilterInitial`, `FilterLoading`, `FilterSuccess(mauData, catData)`, `FilterFailed(String)`
- **Fields:** `brands`, `categories`, `modelYear` (all `List<String>`), `minPrice=0`, `maxPrice=3230`
- **Methods:** `getData()`, `brandsAddingHandler(String id)`, `categoriesAddingHandler(String id)`, `clearFilters()`, `modelAddingHandler(String model, context)`

**`FavouriteCubit`** (`lib/modules/home/blocs/favourite_cubit/favourite_cubit.dart`)
- **States:** `FavouriteInitial`, `FavouriteSuccess`, `FavouriteError`
- **Methods:** `addToFavourites(String carID)` → POST `/favorite/<carID>`

#### API Endpoints

| Method | Path | Cubit | Notes |
|---|---|---|---|
| GET | `/cars/filter?page=N` | `AllCarsCubit`, `CarsCubit` | paginated |
| GET | `/cars/filter?{brands}&{cats}&minimum=&maximum=&page=N` | `AllCarsCubit`, `CarsCubit` | filtered |
| GET | `https://abudiyab-soft.com/cars/api?trem=...` | `AllCarsCubit.searchCars` | **legacy URL, hardcoded** |
| GET | `/categories` | `FilterCubit` | for filter screen |
| GET | `/web/manufactories` | `FilterCubit` | for filter screen |
| POST | `/favorite/<carID>` | `FavouriteCubit` | toggle favourite |

#### User-facing flows
- Browse car list → paginate → tap car → car detail (`/car`)
- Filter cars → select brands/categories/price → apply → filtered list
- Search by keyword → `SearchCarScreen` → results (`CarsSearchResult`)
- View all images → `ImageCarPage`
- Add/remove favourite

---

### Module: Home / Packages

**Folder:** `lib/modules/home/booking_packages/`

#### Screens

| Screen class | File | Route |
|---|---|---|
| `DailyPackages` | `lib/modules/home/booking_packages/ui/daily_package_screen.dart` | `/daily-package` |
| `MonthlyPackageScreen` | `lib/modules/home/booking_packages/ui/monthly_package_screen.dart` | `/monthly-package` |
| `AirportPackageScreen` | `lib/modules/home/booking_packages/ui/airboart_package_screen.dart` | `/airport-package` |
| `DeliveryPackageScreen` | `lib/modules/home/booking_packages/ui/delivery_package_screen.dart` | `/delivery-package` |
| `CarsListPackage` | `lib/modules/home/booking_packages/cars_list_package.dart` | `/package-cars` |
| `CarsMonthlyScreen` | `lib/modules/home/booking_packages/cars_monthly_screan.dart` | `/monthly-cars` |

#### API Endpoints

| Method | Path | Notes |
|---|---|---|
| GET | `/cars/filter` | `CarsListPackage` |
| GET | `/cars_membership/filter` | monthly membership cars |
| GET | `/memberships` | membership data |

---

### Module: Home / Booking Flow

**Folder:** `lib/modules/home/` (across multiple sub-folders)

#### Screens

| Screen class | File | Route |
|---|---|---|
| `BranchWithCarScreen` | `lib/modules/home/booking_from_cars/presentaion/view/branchs_with_car_screan.dart` | `/branch-with-car` |
| `AdditionsScreen` | `lib/modules/home/additions/presentaion/pages/additions_screen.dart` | `/additions` |
| `BookDetails` | `lib/modules/home/all_bookings/presentaion/page/bookDetailes.dart` | `/book-details` |
| `PaymentMethodsScreen` | `lib/modules/home/payment/paymentMethods.dart` | `/payment-methods` |
| `InvoiceUI` | `lib/modules/home/payment/invoice.dart` | `/invoice` |
| `InvoiceNotCompletedUI` | `lib/modules/home/payment/invouce_notCompleted.dart` | `/invoice-not-completed` |
| `WebPayment` | `lib/modules/home/payment/widget/web_payment.dart` | `/web-payment` |
| `BookingConfirmedBottomSheet` | `lib/modules/home/booking_confirmed/bookingConfirmed.dart` | `/booking-confirmed` |

#### Cubits

**`BookingFromCarsCubit`** (`lib/modules/home/booking_from_cars/presentaion/bloc/booking_cars_cubit.dart`)
- **States:** `BookingFromCarsInitial`, `BookingFromCarsLoading`, `BookingFromCarsLoaded(branchModel)`, `BookingFromCarsError(error)`
- **Methods:** `getBranchesWithCar({required int carId})` → GET `/cars/filter?branch_id=<id>`

**`AdditionsCubit`** (`lib/modules/home/additions/presentaion/blocs/addition_cubit/additions_cubit.dart`)
- **States:** `AdditionsInitial`, `AdditionsInit`, `AdditionsLoading`, `AdditionsSuccess(features?)`, `AdditionsFailed(error)`, `AdditionsNotCompletedLoading`, `AdditionsNotCompletedSuccess(features2?)`, `CheckOrderStateLoading`, `CheckOrderStateSuccess(stepModel)`, `CheckOrderStateLoaded`, `CheckOrderStateError(error)`, `CheckAdditionLoading`, `CheckAdditionSuccess`, `CheckAdditionSelectedLoading`, `CheckAdditionSelectedSuccess`
- **Methods:**
  - `getCarFeatures(context, carId, filterModel?)` → POST `/orders/step1`
  - `checkOrderStep({orderId})` → POST `/orders/check`
  - `addAddition(context, Feature?)` / `removeAddition(context, Feature?)` — local state
  - `addAdditionNotCompleted` / `removeAdditionNotCompleted` — for resume-not-completed flow
  - `clearAdditions()`, `initialCheckedList()`, `checkAdditionSelected()`, `checkId(int id)`

**`BookingCubit`** (`lib/modules/home/blocs/booking_cubit/booking_cubit.dart`)
- **States:** `BookingInitial`, `PaymentMethodChanged(method: PaymentMethod?)`, `CouponLoading`, `CouponValid(CouponModel)`, `CouponInvalid(message: String?)`, `DeleteCoupon(CouponModel)`, `DeleteCouponInvalid(message: String?)`, `PaymentMethodsUpdatedByCoupon({visaActive, cashActive, pointsActive, madfouActive, tamaraActive, appleActive, mispayActive})`, `PaymentMethodsRestoredAfterDeleteCoupon`
- **Fields:** `selectedPaymentMethods`, `orderID`, `additions`, `days`, `couponCode`, `receiveLocationId`
- **Methods:** `setPaymentMethods(method)`, `resetPaymentMethod()`, `applyCoupon(code)` → `checkCouponCode()` → POST `/order/coupon`; `deleteCouponCode()` → POST `/order/delete-coupon`; `reset()`

**`InvoiceCubit`** (`lib/modules/home/payment/blocs/invoice_cubit.dart`)
- **States:** `InvoiceInitial`, `InvoiceLoading`, `InvoiceSuccess(InvoiceModel)`, `AutomatedInvoiceSuccess(AutomatedInvoiceModel)`, `InvoiceFailed(error: String)`, `PaymentSuccess(PaymentStepModel)`
- **Methods:**
  - `getInvoice(context)` → POST `/orders/step2`, body: `{order_id, features:[int], payment_type}`
  - `getInvoiceNotCompletedOrder(context, orderId)` → POST `/orders/step2`
  - `activePaymentStep(CreditCardModel? cardModel)` → POST `/orders/step3`
  - `checkOrder()` → POST `/orders/check` → returns `bool`

#### API Endpoints (Booking Flow)

| Method | Path | Cubit/Datasource | Notes |
|---|---|---|---|
| POST | `/orders/step1` | `AdditionsCubit` → `OrderAdditionsRemoteDatasource` | body: car_id, branches, dates |
| POST | `/orders/step2` | `InvoiceCubit` → `InvoiceRemoteDatasource` | body: order_id, features, payment_type |
| POST | `/orders/step3` | `InvoiceCubit` → `PaymentRemoteDatasource` | body: card model |
| POST | `/orders/check` | `AdditionsCubit`, `InvoiceCubit` | check order state |
| POST | `/order/coupon` | `BookingCubit` → `CouponRemoteDatasource` | body: order_id, coupon |
| POST | `/order/delete-coupon` | `BookingCubit` → `CouponRemoteDatasource` | body: order_id |
| POST | `/contracts/step1` | `AdditionsCubit` → `OrderAdditionsRemoteDatasource` | automated booking |
| POST | `/contracts/step2` | `InvoiceCubit` → `InvoiceRemoteDatasource` | automated booking |
| POST | `/contracts/step3` | `InvoiceCubit` → `PaymentRemoteDatasource` | automated booking |
| GET | `/available/time` | date check | — |

#### Payment methods supported
`PaymentMethod` enum values used in UI: `visa`, `cash`, `points`, `madfou`, `tamara`, `apple`, `mispay`

#### User-facing booking flow (new booking)
1. Search screen → validate → car list (`/fleet` or `/cars`)
2. Car detail (`/car`) → select branch (`/branch-with-car`)
3. Additions screen (`/additions`) → select optional extras → POST `/orders/step1`
4. Book details (`/book-details`) → review
5. Payment methods (`/payment-methods`) → choose method; apply coupon (optional)
6. Invoice (`/invoice`) → POST `/orders/step2` + POST `/orders/step3`
7. Web payment (`/web-payment`) if redirect required
8. Booking confirmed (`/booking-confirmed`) → bottom sheet with orderId, carName, total

---

### Module: Home / My Bookings

**Folder:** `lib/modules/home/all_bookings/`

#### Screens

| Screen class | File | Route |
|---|---|---|
| `AllBookingScreen` | `lib/modules/home/all_bookings/presentaion/page/all_booking_screen.dart` | `/bookings` |
| `BookDetails` | `lib/modules/home/all_bookings/presentaion/page/bookDetailes.dart` | `/book-details` |

#### Cubits

**`AllBookingCubit`** (`lib/modules/home/all_bookings/presentaion/bloc/allbooking_cubit.dart`)
- **States:** `AllBookingInition`, `AllBookingLoading`, `AllBookingLoaded(booking: Booking)`, `AllBookingError(error: String)`, `CancelLoading`, `CancelSuccess`, `CancelError(error: String)`, `DeleteOrderLoading`, `DeleteOrderSuccess`, `DeleteOrderError(error: String)`
- **Methods:**
  - `getAllBooking({required String state})` → POST `/orders/get-orders`; **filters client-side to `order_via == 'Darakson App'`**
  - `cancelBooking({required int orderId})` → POST `/order/cancel`
  - `deleteBooking({required int orderId})` → POST `/orders/delete-order`

**`BookingAutomationCubit`** (`lib/modules/home/all_bookings/presentaion/bloc/booking_automation_cubit/booking_automation_cubit.dart`)
- **States:** `BookingAutomationInition`, `BookingAutomationLoading`, `BookingAutomationLoaded(bookingAutomationModel)`, `BookingAutomationError(error)`, `CancelBookingAutomationLoading`, `CancelBookingAutomationSuccess`, `CancelBookingAutomationError(error)`
- **Methods:** `getBookingAutomation()` → GET `/contracts`; `cancelBooking({required int orderId})` → POST `/cancel/contracts`

#### API Endpoints

| Method | Path | Cubit | Notes |
|---|---|---|---|
| POST | `/orders/get-orders` | `AllBookingCubit` | body: `{status}`; client-filters by `order_via` |
| POST | `/order/cancel` | `AllBookingCubit` | body: `{order_id}` |
| POST | `/orders/delete-order` | `AllBookingCubit` | body: `{order_id}` |
| GET | `/contracts` | `BookingAutomationCubit` | automated bookings |
| POST | `/cancel/contracts` | `BookingAutomationCubit` | body: `{order_id}` |

---

### Module: Home / Profile

**Folder:** `lib/modules/home/profile/`

#### Screens

| Screen class | File | Route |
|---|---|---|
| `MyProfile` | `lib/modules/home/profile/page/profile.dart` | `/profile` |
| `EditProfile` | `lib/modules/home/profile/page/edit_profile/presentaion/page/edit_profile.dart` | `/edit-profile` |
| `Favourites` | `lib/modules/home/profile/page/favourites/favourites.dart` | `/favourites` |
| `ResetPasswordScrean` | `lib/modules/home/profile/page/reset_password/presentaion/page/reset_password.dart` | `/reset-password` |
| `PrivacyPolicyScreen` | `lib/modules/home/profile/privacy_policy/privacy_policy.dart` | `/privacy-policy` |
| `CallUs` | `lib/modules/home/profile/` (exact file uncertain) | `/call-us` |

#### Cubits

**`ProfileCubit`** (`lib/modules/home/profile/blocs/profile_cubit/profile_cubit.dart`)
- **States:** `ProfileInitial`, `ProfileLoading`, `ProfileLoaded(profile)`, `ProfileSuccess(profileModel)`, `ProfileFailed(error?)`, `DeleteProfileLoading`, `DeleteProfileSuccess(deleteProfileModel)`, `DeleteProfileFailed(error?)`, `ProfileLogout`
- **Methods:**
  - `getProfile()` → GET (endpoint not confirmed — uses `settings` or `/profile`)
  - `deleteProfile()` → DELETE `/deleteAccount`
  - `logOut()` → calls `sharedPreferencesHelper.clearSession()` → removes `token`, `USER_DATA`, `USER_PASSWORD` only (language preserved) → sets global `userToken = ""` → emits `ProfileLogout`

**`EditProfileCubit`** (`lib/modules/home/profile/page/edit_profile/presentaion/bloc/edit_profile_cubit.dart`)
- **States:** `EditProfileInitial`, `EditProfileLoading`, `EditProfileLoaded`, `EditProfileError(String)`, `ImageProfileLodingState`, `ImageProfileScussesState`, `ImageProfileErrorState(error)`, `ImageLicenceLoadingState`, `ImageLicenceLSuccessState`, `ImageLicenceLErrorState(error)`
- **Methods:**
  - `getImage(BuildContext context)` — shows image source picker (camera/gallery)
  - `getImageLicence(BuildContext context)` — picks licence image
  - `editProfile({image, name, email, phone, profileModel, licenceFace})` → POST multipart `/profile`

**`FavouritesCubit`** (`lib/modules/home/profile/page/favourites/blocs/favourites_cubit/favourites_cubit.dart`)
- **States:** `FavouritesInitial`, `FavouritesLoading`, `FavouritesSuccess(List<DataCars>)`, `FavouritesFailed(String)`
- **Methods:** `getFavourites()` → GET (endpoint not confirmed; likely `/favorites` or `/favorite/list`)

**`RsetePasswordCubit`** (`lib/modules/home/profile/page/reset_password/presentaion/bloc/rsete_password_cubit.dart`)
- **States:** `RsetePasswordInitial`, `RsetePasswordLoading`, `RsetePasswordLoaded`, `RsetePassWordError(String)`
- **Methods:** `rsetePassword({oldPassWord, newPassWord, confirmPassWord})` → PUT `/profile`, body: `{old_password, password, password_confirmation}`

#### API Endpoints

| Method | Path | Cubit/Datasource | Notes |
|---|---|---|---|
| GET | `/profile` (or `/settings`) | `ProfileCubit` | fetch user profile |
| POST | `/profile` (multipart) | `EditProfileCubit` → `EditProfileDataSource` | fields: name, email, phone; files: avatar, licenceFace |
| PUT | `/profile` | `RsetePasswordCubit` → `ResetPasswordDataSource` | body: old_password, password, password_confirmation |
| DELETE | `/deleteAccount` | `ProfileCubit` | — |

---

### Module: Home / Branches

**Folder:** `lib/modules/home/all_branching/`

#### Screens

| Screen class | File | Route |
|---|---|---|
| `BranchesScreen` | `lib/modules/home/all_branching/page/branches_screen.dart` | `/branches` |
| `ViewLocation` | `lib/modules/home/all_branching/page/view_location.dart` | `/view-location` |
| `LocationPickerFull` | (likely `lib/modules/home/all_branching/` or `lib/core/helpers/Maps/`) | `/location-picker` |

#### Cubit

**`AllBranchCubit`** (`lib/modules/home/all_branching/bloc/all_branching_cubit.dart`)
- **States:** `AllBranchInitial`, `AllBranchLoading`, `AllBranchLoaded(branchModel: List<BranchModel>)`, `AllBranchError(error: String)`
- Error messages (hardcoded Arabic):
  - `'لا توجد فروع متاحة'` (no available branches)
  - `'لا يوجد اتصال بالإنترنت. يرجى التحقق من الاتصال والمحاولة مرة أخرى'` (no internet)
  - `'لا توجد بيانات محفوظة. يرجى الاتصال بالإنترنت'` (no cached data)
  - `'حدث خطأ أثناء تحميل الفروع: ...'` (generic load error with interpolated message)
- **Methods:** `getAllBranch({bool forceRefresh=false})` → GET `/branches?perPage=60`; `refreshBranches()`, `clearBranchesCache()`, `getCacheInfo()`
- **Caching:** Hive (`branches_box`), 5-min TTL via `CacheHelper.isCacheValid(key)`

#### API Endpoints

| Method | Path | Notes |
|---|---|---|
| GET | `/branches?perPage=60` | 60 items per page; cached in Hive |

---

### Module: Home / Cashback

**Folder:** `lib/modules/home/cash_back/`

#### Screens

| Screen class | File | Route |
|---|---|---|
| `CashbackScreen` | `lib/modules/home/cash_back/screen/CashBackScreen.dart` | `/cashback` |

#### Cubit

**`CashbackCubit`** (`lib/modules/home/cash_back/bloc/cashback__cubit.dart`)
- **States:** `CashbackInitial`, `CashbackLoading`, `CashbackDataState(cashbackBalance, transactions, isLoadingBalance, isLoadingTransactions, + optional: balanceError, transactionsError, isApplyingCashback, applyCashbackError, applyCashbackResponse)`, `CashbackError(message)`
- **Methods:**
  - `initialize()` — calls both balance + transactions
  - `getCashbackBalance()` → GET `/cashback/balance`
  - `getCashbackTransactions({eventType?, recordState?, direction='desc'})` → GET `/cashback/transactions`
  - `refreshCashbackBalance()`, `refreshCashbackTransactions(...)`, `refreshAll()`
  - `applyCashbackToOrder({orderId, amount})` → POST `/cashback/apply-to-order`

#### API Endpoints

| Method | Path | Notes |
|---|---|---|
| GET | `/cashback/balance` | — |
| GET | `/cashback/transactions?eventType?&recordState?&direction=desc` | — |
| POST | `/cashback/apply-to-order` | body: `{order_id, amount}` |

---

### Module: Home / Offers

**Folder:** `lib/modules/home/offers/`

#### Screens

| Screen class | File | Route |
|---|---|---|
| `OffersScreen` | `lib/modules/home/offers/offers_tap_screen.dart` | `/offers` |
| `OfferDetailsScreen` | `lib/modules/home/offers/offer_details_screen.dart` | `/offer-details` |

#### API Endpoints

| Method | Path | Notes |
|---|---|---|
| GET | `/offers` | list of offers |
| GET | `/check_for_offers` | search-screen offer banner |

---

### Module: Home / Complaints

**Folder:** `lib/modules/home/complaints/`

#### Screens

| Screen class | File | Route |
|---|---|---|
| `ComplaintScreen` | `lib/modules/home/complaints/screen/complaint_screen.dart` | `/complaints` |

#### Cubit

**`ComplaintCubit`** (`lib/modules/home/complaints/cubit/complaint_cubit.dart`)
- **States:** `ComplaintInitial`, `ComplaintLoading`, `ComplaintSuccess`, `ComplaintError(String)`
- **Methods:** `submitComplaint({name, phone, idNumber, description})` → POST `/complaints`
- **Error parsing** (in screen widget, not cubit):
  - `'302'` in message → `locale.sessionExpiredLoginAgain`
  - `'401'`/`'403'` → `locale.unauthorizedAction`
  - `'500'` → `locale.serverErrorTryLater`
  - `'SocketException'`/`'network'` → `locale.checkInternetConnection`
  - fallback → `locale.somethingWentWrong`

#### API Endpoints

| Method | Path | Notes |
|---|---|---|
| POST | `/complaints` | body: `{name, phone, id_number, description}` |

---

### Module: Home / Home Screen (Classic)

**Folder:** `lib/modules/home/home_screen/`

| Screen class | File | Route |
|---|---|---|
| `Clasic` | `lib/modules/home/home_screen/clasic.dart` | `/classic` |

(No dedicated cubit found; likely uses `SearchCubit` or `AllBranchCubit`.)

---

### Module: Notifications

**Folder:** `lib/modules/notifications/`

#### Screens

| Screen class | File | Route |
|---|---|---|
| `NotificationsScreen` | `lib/modules/notifications/presentaion/page/notifications_screen.dart` | `/notifications` |

#### Cubit

**`NotificationsCubit`** (`lib/modules/notifications/presentaion/bloc/notifications_cubit.dart`)
- **States:** `NotificationsInitial`, `NotificationsLoading`, `NotificationsNoInternet`, `NotificationsError(message)`, `NotificationsLoaded(items, hasMore, isLoadingMore, loadMoreFailed)`, `NotificationsEmpty`
- **Methods:**
  - `getNotifications()` → GET `/notifications?page=1&per_page=15` (resets list)
  - `loadMore()` → GET `/notifications?page=N&per_page=15` (appends)
  - `markOneAsRead(int id)` → POST `/notifications/read/<id>` (optimistic, reverts on failure)
  - `markAllAsRead()` → POST `/notifications/read-all` (optimistic, reverts on failure)
- **Connectivity:** Uses `safeApiCall` wrapper — only module that pre-checks connectivity before calling Dio. Catches `NoInternetConnectionException` → emits `NotificationsNoInternet`.

#### API Endpoints

| Method | Path | Notes |
|---|---|---|
| GET | `/notifications?page=N&per_page=15` | **TODO in source: confirm path + method** |
| POST | `/notifications/read/<id>` | **TODO in source: confirm path** |
| POST | `/notifications/read-all` | **TODO in source: confirm path** |

---

### Module: Shell / Navigation

**Folder:** `lib/modules/shell/`

#### Components

| Class | File | Role |
|---|---|---|
| `ShellScaffold` | `lib/modules/shell/app_shell.dart` | `StatefulShellRoute` builder; hosts bottom nav |
| `ShellBottomNavBar` | `lib/modules/shell/bottom_nav_bar.dart` | `CurvedNavigationBar` — tab switching |
| `TabScrollRegistry` | `lib/modules/shell/tab_scroll_registry.dart` | Maps tab index → `ScrollController`; re-tap scrolls to top |
| `UpdateDialog` | `lib/modules/shell/update_dialog.dart` | Version check prompt |

- **Tab order:** 0 = `/home`, 1 = `/fleet`, 2 = `/bookings`, 3 = `/profile`
- **Re-tap same tab** → `scrollToTop(index)` (except tab 2 which is not registered)
- **Version check:** `ShellScaffold.initState` calls `_checkVersion` → GET `/settings/version`; shows `UpdateDialog` if update required
- **Profile fetch:** `ShellScaffold.initState` calls `ProfileCubit.getProfile()`

---

### Module: Shared Widgets

**Folder:** `lib/modules/widgets/`

| Widget | File | Used by |
|---|---|---|
| `CustomAppBar` | `lib/modules/widgets/components/appbar.dart` | All screens with app bar |
| `ADGradientButton` | `lib/modules/widgets/components/ad_gradient_btn.dart` | CTA buttons |
| `ad_prim_text_form` | `lib/modules/widgets/` | Form fields |
| `DynamicPhoneField_WithCountry` | `lib/modules/widgets/` | Phone fields with country picker |
| `showResponsive_Flushbar` | `lib/modules/widgets/` | Snackbar/toast |
| `NetworkErrorWidget` | `lib/core/helpers/helper/Network_error_widget.dart` | No-internet states |

---

## Forms & Validation Rules

> Source files: `lib/core/helpers/validation/form_validator.dart`, `lib/core/helpers/validation/validation.dart`

### Validation error messages (locale key → English value)

| Locale key | English value | Arabic (approximate) |
|---|---|---|
| `pleaseEnterName` | "Enter full name" | (in arabic.dart) |
| `enterNameMiniChars` | "name min 4 characters" | — |
| `pleaseEnterEmail` | "Please enter email" | — |
| `enterValidEmail` | "Enter Valid Email" | — |
| `pleaseEnterPhoneNumber` | "Please Enter Phone Number" | — |
| `pleaseEnterValidPhone` | (Saudi phone regex error) | — |
| `saudiPhoneMustBe9Digits` | (phone must be 9 digits) | — |
| `saudiPhoneMustStartWith5` | (must start with 5) | — |
| `invalidPhoneNumber` | (phone out of range 7–15 digits) | — |
| `phoneNumberTooShort` | (phone < 7 chars) | — |
| `pleaseEnterPassword` | "Please Enter Password" | — |
| `passwordTooShort` | "Password must be at least 8 characters or numbers" | — |
| `passwordNotMatching` | "Password Are Not Matching" | — |
| `passwordsDoNotMatch` | (confirm password mismatch) | — |
| `oldPasswordIncorrect` | "Old Password Incorrect" | — |
| `pleaseEnterIdNumber` | (ID field empty) | — |
| `idMustBe10Digits` | (national ID must be 10 digits) | — |
| `idMustStartWith1` | (national ID must start with 1) | — |
| `iqamaMustStartWith2` | (Iqama must start with 2) | — |
| `pleaseEnterNumbersOnly` | (numeric-only field error) | — |
| `pleaseEnterThePassportNumber` | (passport empty) | — |
| `mustBe3To15Letters` | (passport 3–15 alphanumeric chars) | — |
| `pleaseEnterValidCredit` | "Please Enter Valid Credit" | — |
| `enterValidCVV` | "Please Enter Valid CVV" | — |
| `pleaseEnterExpireMonth` | (month empty) | — |
| `pleaseEnterMonthIn2Digits` | (month not 2 digits) | — |
| `pleaseEnterValidMonth` | (month 1–12 range) | — |
| `pleaseEnterExpireYear` | (year empty) | — |
| `pleaseEnterValidYear` | (year invalid) | — |
| `cardIsExpired` | (card expired) | — |
| `thisFieldIsRequired` | "This field is required" | — |

### Per-screen form inventory

| Screen | Field | Validator method | Validation rule | Error (locale key) |
|---|---|---|---|---|
| `SignInScreen` | Login type selector | — | toggle: email/phone/ID | — |
| `SignInScreen` | Identifier (email mode) | `FormValidator.emailValidate` | not empty; regex `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$` | `pleaseEnterEmail`, `enterValidEmail` |
| `SignInScreen` | Identifier (phone mode) | inline `_validatePhone` | not empty; numeric only; length 9–15 | `thisFieldIsRequired`, `pleaseEnterNumbersOnly`, `invalidPhoneNumber` |
| `SignInScreen` | Identifier (ID mode) | `FormValidator.numValidate` | 10 digits; numeric; starts with '1' | `pleaseEnterIdNumber`, `idMustBe10Digits`, `pleaseEnterNumbersOnly`, `idMustStartWith1` |
| `SignInScreen` | Password | (no client validator — server validates) | — | — |
| `RegisterPage` | Full Name | `FormValidator.nameValidate` | not empty; length ≥ 4 | `pleaseEnterName`, `enterNameMiniChars` |
| `RegisterPage` | Email | `FormValidator.emailValidate` | not empty; regex | `pleaseEnterEmail`, `enterValidEmail` |
| `RegisterPage` | Phone | `DynamicPhoneFieldWithCountry` | country-aware; if KSA (+966): 9 digits, starts '5'; else 7–15 digits | `pleaseEnterPhoneNumber`, `saudiPhoneMustBe9Digits`, `saudiPhoneMustStartWith5`, `invalidPhoneNumber` |
| `RegisterPage` | Password | inline strength widget (`enableDynamicValidation: true`) | min 8 chars | `passwordTooShort` |
| `RegisterPage` | Confirm Password | `matchWithController` widget param | matches password field | `passwordsDoNotMatch` |
| `RegisterPage` | National ID | `FormValidator.numValidate` | 10 digits; starts '1' | `pleaseEnterIdNumber`, `idMustBe10Digits`, `idMustStartWith1` |
| `RegisterPage` | Iqama | `FormValidator.numVisitValidate` | 10 digits; starts '2' | `pleaseEnterIdNumber`, `idMustBe10Digits`, `iqamaMustStartWith2` |
| `RegisterPage` | Passport | inline `_specialCharValidate` | not empty; regex `^(?!^0+$)[a-zA-Z0-9]{3,15}$` | `pleaseEnterThePassportNumber`, `mustBe3To15Letters` |
| `RegisterPage` | License photo | `cubit.imagePathFace.isNotEmpty` check | file required | (flushbar error, no locale key confirmed) |
| `RegisterPage` | Terms checkbox | checked required | — | — |
| `OtpVerifyScreen` | OTP code | (exact validator not confirmed) | 4 or 6 digits | (uncertain) |
| `ForgotPasswordScreen` | Phone | (validator not confirmed) | Saudi phone format | `pleaseEnterValidPhone` or `pleaseEnterPhoneNumber` |
| `EnterCodeScrean` | Code | (validator not confirmed) | numeric, N digits | (uncertain) |
| `ChangePasswordScreen` | New password | `FormValidator.passwordValidate` | min 8 chars | `pleaseEnterPassword`, `passwordTooShort` |
| `ChangePasswordScreen` | Confirm password | `FormValidator.passwordConfirmValidate` | matches new password | `passwordNotMatching` |
| `ResetPasswordScrean` | Old password | `Validate.validateOldPassword` | not empty; ≥ 8 chars; matches saved password | `pleaseEnterPassword`, `passwordTooShort`, `oldPasswordIncorrect` |
| `ResetPasswordScrean` | New password | `FormValidator.passwordValidate` | min 8 chars | `pleaseEnterPassword`, `passwordTooShort` |
| `ResetPasswordScrean` | Confirm password | `FormValidator.passwordConfirmValidate` | matches new password | `passwordNotMatching` |
| `EditProfile` | Name | `FormValidator.nameValidate` | ≥ 4 chars | `pleaseEnterName`, `enterNameMiniChars` |
| `EditProfile` | Email | `FormValidator.emailValidate` | regex | `pleaseEnterEmail`, `enterValidEmail` |
| `EditProfile` | Phone | `DynamicPhoneFieldWithCountry` | country-aware | same as RegisterPage phone |
| `ComplaintScreen` | Name | `FormValidator.nameValidate` | ≥ 4 chars | `pleaseEnterName`, `enterNameMiniChars` |
| `ComplaintScreen` | Phone | inline `_validatePhone` | not empty; ≥ 7 chars | `pleaseEnterPhoneNumber`, `phoneNumberTooShort` |
| `ComplaintScreen` | ID Number | `FormValidator.numValidate` (inferred) | 10 digits; starts '1' | `pleaseEnterIdNumber`, `idMustBe10Digits`, `idMustStartWith1` |
| `ComplaintScreen` | Description | (validator not confirmed) | not empty | (uncertain) |
| Payment card | Card number | `FormValidator.creditValidate` | regex `^\d{13,19}$`; Luhn algorithm | `pleaseEnterValidCredit` |
| Payment card | Card holder name | (validator not confirmed) | — | — |
| Payment card | CVV | `FormValidator.cvvValidate` | regex `^\d{3,4}$` | `enterValidCVV` |
| Payment card | Expire month | `FormValidator.monthValidate` | 2 digits; 1–12 | `pleaseEnterExpireMonth`, `pleaseEnterMonthIn2Digits`, `pleaseEnterValidMonth` |
| Payment card | Expire year | `FormValidator.yearValidate` | parseable; not expired | `pleaseEnterExpireYear`, `pleaseEnterValidYear`, `cardIsExpired` |

---

## Cross-Cutting

### Authentication & Session

**Token storage** (`lib/core/helpers/SharedPreference/pereferences.dart`):
- Key: `PreferencesConstants.token = "token"`
- Saved after login via `signInLocalDataSource.saveToken(response['token'])`
- Read by Dio interceptor: `SharedPreferencesHelper.getToken()`
- Also stored: `PreferencesConstants.userPassword = "USER_PASSWORD"` (saved on login; used by `validateOldPassword` to compare locally)

**Session expiry / 401:**
- The Dio interceptor `onError` handler is **empty** — no automatic logout, no redirect on 401.
- `Failure.fromDioError` maps HTTP 401 → string `"Not Authenticated"` which propagates to the cubit as an error state string.
- No global 401 handler; each cubit independently surfaces the error message via its `*Error(String)` state.

**Logout:**
- `ProfileCubit.logOut()` → `sharedPreferencesHelper.clearSession()` → removes `token`, `USER_DATA`, `USER_PASSWORD` (language `LANG` and `isLanguageSelected` are **preserved**) → sets global `userToken = ""` → emits `ProfileLogout`.
- UI should redirect to `/signin` or `/language` on `ProfileLogout`.

**Source:** `lib/core/helpers/interceptors/app_interceptor.dart`, `lib/modules/home/profile/blocs/profile_cubit/profile_cubit.dart`

### Offline / Connectivity Handling

**`safeApiCall` wrapper** (`lib/core/helpers/exception/exceptions.dart`):
- Pre-checks `Connectivity().checkConnectivity()` before every call.
- On no connection: throws `NoInternetConnectionException`.
- On `DioException`: throws `Failure.fromDioError(DioException)`.
- **Only `NotificationsRemoteDataSource` uses this wrapper.** All other datasources call Dio directly without a connectivity pre-check.

**`Failure.fromDioError` HTTP status mapping:**

| Status / Type | Error string |
|---|---|
| `connectionTimeout` | "Connection timeout with server" |
| `receiveTimeout` | "Receive timeout in connection with server" |
| `sendTimeout` | "Send timeout in connection with server" |
| `cancel` | "Request to API server was cancelled" |
| `unknown` | "Connection failed due to internet connection" |
| 500 | "Server Error" |
| 401 | "Not Authenticated" |
| 422 | "Data is not valid" |
| 404 | "Data Not Found" |
| 429 | "Too many requests" |
| 403 | "Your Request Is Not Allowed" |
| other | `DioException.message` |

**`NetworkErrorWidget`** (`lib/core/helpers/helper/Network_error_widget.dart`):
- Displays no-internet icon + bilingual description + retry button (`locale.retry`).
- Default description AR: `"تأكد من اتصالك بالإنترنت ثم حاول مرة أخرى"`
- Default description EN: `"Check your internet connection and try again"`
- Used in: notifications screen (confirmed); other screens (uncertain).

**`AllBranchCubit` error messages** (hardcoded Arabic — **not** via `AppLocalizations`):
- `'لا توجد فروع متاحة'`
- `'لا يوجد اتصال بالإنترنت. يرجى التحقق من الاتصال والمحاولة مرة أخرى'`
- `'لا توجد بيانات محفوظة. يرجى الاتصال بالإنترنت'`
- `'حدث خطأ أثناء تحميل الفروع: <message>'`

### Permissions

| Permission | Package | Requested where | Behavior on denial |
|---|---|---|---|
| Location | `geolocator` | `lib/core/helpers/Maps/map_select_location.dart` | Fallback to Riyadh `LatLng(24.7136, 46.6753)` |
| Location | `geolocator` | `lib/modules/home/booking_packages/widgets/delivery_rent_body.dart` | SnackBar `locale.locationPermissionDenied` |
| Location (permanently denied) | `geolocator` | Both above | SnackBar `locale.permissionPermanentlyDeniedBody`; falls through |
| Push notifications | `firebase_messaging` | `lib/core/helpers/notifications/push_notification_service.dart` — called from `main.dart` init | Not handled explicitly; FCM skips token on failure |
| Camera / Photo library | `image_picker` (native) | `RegisterCubit.getImage`, `EditProfileCubit.getImage/getImageLicence` | Plugin handles natively; no explicit `permission_handler` |

### Localization

**Supported locales:** `en`, `ar`

**Structure:**
- `lib/language/languages/english.dart` → `Map<String,String>` returned by `english()`
- `lib/language/languages/arabic.dart` → `Map<String,String>` returned by `arabic()`
- `lib/language/locale.dart` → `AppLocalizations` class with one getter per key
- `AppLocalizationsDelegate` in same file; `shouldReload: false` (static maps)

**Locale switching:**
- `SelectLanguage` screen writes chosen locale to SharedPreferences key `"LANG"` (`PreferencesConstants.lang`)
- Dio interceptor `onRequest` adds `Accept-Language: <langCode>` header
- **`LanguageCubit`** (`lib/modules/home/selectLanguage/languageCubit.dart`) `extends Cubit<Locale>` — the runtime mechanism. Reads saved locale from SharedPreferences on construction; exposes `selectEngLanguage()` / `selectArabicLanguage()`; registered as `registerLazySingleton` and provided globally in `bloc_providers.dart`. The `BlocBuilder<LanguageCubit>` wrapper rebuilds the entire `MaterialApp.router` on change. Note: `lib/language/languageCubit.dart` is a **blank ghost file** — it is not the real cubit.

**RTL:**
- `intl.Bidi` used; Arabic locale triggers RTL layout
- `flutter_screenutil` design size: 390 × 844

**Hardcoded strings exception:**
- `lib/core/constants/privacy_policy.dart` holds `PrivacyAr` / `PrivacyEn` as `const String` blocks (~700 lines each); deliberately not in the localization map

### Theming

- `ThemeCubit` (light / dark) in `lib/core/theme.dart`; provided in `bloc_providers.dart` inline (not via GetIt)
- Color tokens in `lib/core/constants/assets/app_colors.dart`; dynamic functions: `*Color(BuildContext)` picks by brightness
- Typography: `AppTypography` in `lib/core/style/style.dart`; custom font `ThmanyahSans` (weights 300/400/500/700/900)
- Text scale clamped 0.8–1.2 in `bloc_providers.dart`
- Text-scale-aware sizing: `.hs(context)` / `.ws(context)` / `.sps(context)` in `lib/core/helpers/text_scale_sizing.dart`
- `AnimatedThemeToggleButton` in `CustomAppBar`

### Push Notifications (FCM)

**File:** `lib/core/helpers/notifications/push_notification_service.dart`

- Firebase initialized in `main.dart` → `PushNotificationService.init()` runs at boot
- Background handler: top-level `firebaseMessagingBackgroundHandler` with `@pragma('vm:entry-point')`
- Android channel: `high_importance_channel` (`Importance.high`)
- Foreground messages shown via `flutter_local_notifications`
- Device token: `_safeDeviceToken()` (try/catch → `null` on failure — never crashes)
- **Pending:** token NOT sent to backend on login. iOS plist absent. Tap-to-navigate (Phase C) not wired.

**Notification routing** (`lib/core/router/notification_router.dart`):
- `routeFromNotification(context, type:, data:)` is the central dispatcher
- `cashback` → cashback screen; `booking` → `/bookings`; `offer` → offer-details/offers; `update`/`unknown` → `/home`

### Caching

- **Hive** (`lib/core/helpers/cache/cache_helper.dart`): boxes `branches_box`, `cars_box`, `cache_meta_box`; TTL 5 minutes (`cacheValidDuration`); key pattern `${key}_time` for metadata
- Only `AllBranchCubit` actively uses Hive cache (branches list)
- **SharedPreferences:** auth token, language, user password

### Version checking

- `ShellScaffold.initState` → GET `/settings/version` → `UpdateDialog` if update available
- `UpdateDialog` source: `lib/modules/shell/update_dialog.dart`
- Locale keys: `updateAvailable`, `updateAvailableMessage`, `updateNow`

---

## Open questions [BACKEND]

These items require a backend or product answer before they can be acted on.

1. [BACKEND] **Notification API paths:** `api_path.dart` marks all three notification endpoints with `// TODO(api): confirm path + method`: `notificationsList = mainApi + '/notifications'`, `notificationsMarkAllRead = mainApi + '/notifications/read-all'`, `notificationsMarkOneRead = mainApi + '/notifications/read'` (datasource appends `/{id}`). Are these the real backend paths, or placeholders?

2. [BACKEND] **Replacement endpoint for legacy car search:** `AllCarsCubit.searchCars` calls `https://abudiyab-soft.com/cars/api?trem=...` on an external domain using a bare `Dio()` (bypassing auth headers). What is the production replacement endpoint on `api.daraksonksa.com`?

3. [BACKEND] **`order_via` value for Darbak orders:** `AllBookingCubit.getAllBooking` filters client-side to `order_via == 'Darakson App'`. The current brand is "Darbak" — this may be the root cause of silently empty bookings lists. What string does the backend actually return for orders placed through the app?

4. [BACKEND] **Automated booking flow trigger:** The `/contracts/*` endpoints (`step1/2/3`) exist alongside the regular `/orders/*` flow. When is the automated flow triggered vs the regular flow? What screen, flag, or API response field determines which path is taken?

---

## Resolved questions

3. **`ProfileCubit.getProfile()` endpoint:** `GET mainApi + '/profile'` via `http` package (not Dio), Bearer token from SharedPreferences; source: `ProfileService` (`lib/modules/home/profile/data/datasources/remote/profile_sevice.dart:14`).

4. **`FavouritesCubit.getFavourites()` endpoint:** Same `GET /profile` as `getProfile()`; favourites parsed from `data['data']['favorite']`; source: `FavouritesService` (same line 14 pattern).

5. **OTP digit count (`OtpVerifyScreen`):** 6 digits (`OtpTextField(numberOfFields: 6)`); validated `if (otpCode.trim().length < 6)` → `locale.enterValidSixDigitOtp`; resend available via `POST /register/resend-otp`.

6. **`EnterCodeScrean` vs `OtpVerifyScreen`:** `EnterCodeScrean` (forgot-password) = 4 custom `TextField` boxes in a bottom-sheet modal, validated `< 4` → `locale.pleaseEnter4DigitCode`. `OtpVerifyScreen` (register) = 6 digits full-page scaffold via `flutter_otp_text_field`, validated `< 6`. Two completely distinct screens.

7. **`ForgotPasswordScreen` phone validator:** No explicit `validator:` param; validation fully delegated to `DynamicPhoneFieldWithCountry` widget's internal logic; text passed directly to `ForgetPasswordCubit.sendPone()` with no additional client-side check.

8. **Complaint screen — ID Number and Description validators:** ID Number uses `FormValidator.numValidate` (10 digits, starts '1'); Description is empty-check only (`value!.isEmpty ? locale.pleaseEnterComplaint : null`).

9. **Payment card holder name validator:** `FormValidator.nameValidate` — non-empty (`pleaseEnterName`) and ≥ 4 chars (`enterNameMiniChars`).

12. **`Clasic.entry()` at `/classic`:** Branch-pickup rental form; renders `DailyRentBody()`; on `SearchValidate` calls `CarsCubit.getAllCars()` filtered by branch + customer class; navigates to `/package-cars`. Provides `AllBranchCubit` + `CarsCubit` in its `entry()`.

13. **Logout clearing language:** Was a bug (`clear(String)` wiped everything). **Fixed in Batch A** — `clearSession()` removes only `token`, `USER_DATA`, `USER_PASSWORD`; language preserved.

14. **401 handling:** No automatic redirect currently. **Decision made:** Batch B (B3) adds a global handler in `AppInterceptors.onError`; auth-endpoint paths excluded to prevent redirect on wrong-password 401.

15. **`CallUs` screen content:** `lib/modules/widgets/call_us.dart` — three sections: contact numbers (WhatsApp + phone via `url_launcher`), social media icons (Instagram, Facebook, Twitter, TikTok, Snapchat), and website link. All URLs from `SettingsCubit`/`SettingsRepository` with hardcoded fallbacks.

16. **`AllCarsCubit` vs `CarsCubit`:** `AllCarsScreen` (`/fleet`, `/cars`) → `AllCarsCubit`. All four package screens + `Clasic` → `CarsCubit`. Only `AllCarsCubit` has `searchCars()` (with the legacy URL).

17. **`LanguageCubit` location:** Real class at `lib/modules/home/selectLanguage/languageCubit.dart`; `extends Cubit<Locale>`; registered as `registerLazySingleton`; provided globally in `bloc_providers.dart`. The blank ghost at `lib/language/languageCubit.dart` has been deleted.

18. **`ProfileCubit.logOut()` navigation target:** After logout confirmation, UI calls `shell.goBranch(0, initialLocation: true)` — navigates to tab 0 (`/home`), not to `/signin`. `AuthStatusCubit.markSignedOut()` runs but no GoRouter redirect guard fires.

19. **`BookingConfirmedBottomSheet` dismiss behaviour:** Swipe-to-dismiss completely disabled (`WillPopScope(onWillPop: () async => false)`, `barrierDismissible: false`). Only exits via "Go to Bookings" (`context.go('/bookings')`) or "Go to Home" (`context.go('/home')`).

20. **Package screens comparison:** All four share the same top-level structure but differ: Monthly routes to `/monthly-cars` (others → `/package-cars`); Delivery uses case-insensitive branch matching, GPS coordinates in `FilterModel`, and shows an error dialog on no-match (others print silently); `initState` calls differ per screen.

---

## Known Defects

1. SCHEDULED (Batch C): **Plaintext password in SharedPreferences** (`lib/core/helpers/SharedPreference/pereferences.dart`, key `PreferencesConstants.userPassword`): The user's raw password is saved to SharedPreferences on login and compared client-side in `Validate.validateOldPassword` (reset-password flow). Plaintext credential storage is a security defect; it should be removed and the reset-password flow should verify the old password server-side only.

2. SCHEDULED (Batch B): **Auth token in SharedPreferences instead of secure storage** (`lib/core/helpers/SharedPreference/pereferences.dart`, key `PreferencesConstants.token`): The Bearer token is stored in SharedPreferences, which is not encrypted on Android (readable by rooted devices or ADB backup). It should be stored in `flutter_secure_storage`.

3. PARTIALLY ADDRESSED (Batch A): **Legacy domain in `AllCarsCubit.searchCars`** (`lib/modules/home/cars/presentaion/bloc/all_cars_cubit/all_cars_cubit.dart`): URL extracted to the constant `legacyCarSearchUrl` in `api_path.dart`. The underlying Dio/auth bypass is still open: the method constructs a bare `Dio()` instead of `sl<Dio>()`, so this request bypasses `baseUrl`, the `Accept-Language` header, and **the `Authorization: Bearer <token>` header**. Fix is blocked pending a replacement endpoint from backend.

4. BLOCKED [BACKEND]: **Client-side `order_via` filter in `AllBookingCubit.getAllBooking`** (`lib/modules/home/all_bookings/presentaion/bloc/allbooking_cubit.dart`): Results from `POST /orders/get-orders` are filtered client-side to `order_via == 'Darakson App'`. The app's brand is "Darbak"; the filter string still reads `'Darakson App'`, which means orders created under the current branding may be silently hidden from users. Cannot fix until backend confirms the correct `order_via` value.

5. FIXED (Batch A): ~~**`ProfileCubit.logOut()` wipes language preference.**~~ `clear(String)` deleted; `clearSession()` now removes only `token`, `USER_DATA`, `USER_PASSWORD`. Language (`LANG`) is preserved across logout.

6. SCHEDULED (Batch B): **Global mutable auth state in `langCode.dart`** (`lib/core/constants/langCode.dart`): The file declares three top-level mutable globals: `String langCode = ''`, `String? userToken = ""`, `String? phoneStorage`. None is thread-safe. `userToken` is zeroed in `profile_cubit.dart:54` on logout but never read — all real token reads go through `SharedPreferencesHelper.getToken()`. `phoneStorage` is written in two places (`forgotPassword.dart:212`, `change_password.dart:96`) but never read — dead write-only state. `langCode` is never written outside its declaration (always `''`). These globals survive logout and are reachable from any file. `userToken` and `phoneStorage` will be removed in Batch B (B2); `langCode` will be verified before touching.

7. SCHEDULED (Batch C): **`paymentMethods.dart` actively uses the prohibited navigation package** (`lib/modules/home/payment/paymentMethods.dart`, lines 526, 543, 573, 589, 619, 635): The import of `persistent_bottom_nav_bar` is **not dead** — `PersistentNavBarNavigator.pushNewScreen(context, withNavBar: false, screen: ...)` is called 6 times, covering every non-visa payment path that proceeds to an invoice screen. It pushes `InvoiceUI` or `InvoiceNotCompletedUI` as widget instances directly, bypassing go_router entirely. The routes `/invoice` and `/invoice-not-completed` exist in the router but are never reached from this screen. Fix: replace all 6 call sites with `context.pushNamed(Routes.invoice, extra: InvoiceArgs(...))` and `context.pushNamed(Routes.invoiceNotCompleted, extra: InvoiceArgs(...))`, verifying the `InvoiceArgs` fields match what each call site currently passes.

8. SCHEDULED (Batch C): **`NetworkErrorWidget` hardcodes UI strings as constructor defaults** (`lib/core/helpers/helper/Network_error_widget.dart`, lines 13–15): The constructor defaults `buttonText = 'إعادة المحاولة'` (Arabic), `descriptionAr = 'تأكد من اتصالك بالإنترنت...'`, `descriptionEn = 'Check your internet connection...'` are hardcoded strings that violate the `AppLocalizations` rule. The retry button label is already drawn from `locale.retry` in the `build` method, but the description parameters bypass localization. Call sites that rely on the defaults (rather than passing their own strings) will display these hardcoded values.

9. FIXED (Step 0): ~~**Two dead files with no imports anywhere in the codebase.**~~ Both files deleted and confirmed absent: `lib/language/languageCubit.dart` (was blank — 2 newlines) and `lib/core/helpers/helper/FigmaToFlutter.dart` (was empty — 0 bytes). Full-repo grep confirmed zero imports before deletion. `flutter analyze` after deletion: still 73 issues, no new errors.

10. SCHEDULED (Batch C): **Only one datasource uses the `safeApiCall` connectivity pre-check** (`lib/core/helpers/exception/exceptions.dart`): `NotificationsRemoteDataSource` is the only datasource that wraps Dio calls in `safeApiCall`, which pre-checks `Connectivity().checkConnectivity()` before each call and throws `NoInternetConnectionException` on no connection. All other datasources (Auth, Cars, Booking, Profile, Branches, Cashback, Offers, Complaints, Payment, Coupon, Invoice, Favourites) call Dio directly with no connectivity pre-check. This means offline behaviour is inconsistent across screens: notifications shows a dedicated no-internet state (`NotificationsNoInternet`), while all other screens receive whatever error the Dio exception propagates — typically an opaque `DioException` string from `Failure.fromDioError`, not a distinct no-internet state. Batch C plan (C3) calls for rolling out `safeApiCall` to all datasource methods and auditing which cubits need a corresponding no-internet state.

---

## Filename Conventions Warning

The project **does not enforce a single naming convention**. A scan of `lib/` reveals 42 Dart files that deviate from snake_case:

- **camelCase filenames:** `langCode.dart`, `forgotPassword/` (entire folder — 8 files), `bookDetailes.dart`, `featuresModel.dart`, `dateTimeWidget.dart`, `BranchRepository.dart`, `CashBackScreen.dart`, `paymentMethods.dart`, `languageCubit.dart` (×2), `selectLanguage.dart`, `errorPage.dart`, `successPage.dart`, and others.
- **PascalCase filenames:** `BranchRepository.dart`, `Network_error_widget.dart` (mixed underscore + capital), `FigmaToFlutter.dart`, `DynamicPhoneField_WithCountry.dart`.
- **Capitalised folders:** `Maps/`, `SharedPreference/`, `Delivery_widgets/`.

**Consequence for QA and tooling:** Grep patterns that assume snake_case filenames will silently miss a substantial portion of the codebase. Any automated scan (inventory tools, linters, import-convention checkers) must be validated against a full directory listing, not a naming-pattern filter. The 42 non-snake_case files were identified by listing `lib/**/*.dart` and filtering out matches to the pattern `^[a-z][a-z0-9_]*\.dart$`.
