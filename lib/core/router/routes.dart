class Routes {
  // auth
  static const splash = 'splash';
  static const language = 'language';
  static const onBoarding = 'onBoarding';
  static const signin = 'signin';
  static const register = 'register';
  static const otp = 'otp';
  static const forgotPassword = 'forgotPassword';
  static const enterCode = 'enterCode';
  static const changePassword = 'changePassword';
  static const errorPage = 'errorPage';

  // shell — StatefulShellRoute branches, one stable path per tab.
  // Order matches the branch index used by the bottom nav (0..3).
  static const home = 'home'; //      /home     — SearchScreen  (tab 0)
  static const fleet = 'fleet'; //    /fleet    — AllCarsScreen (tab 1)
  static const bookings = 'bookings'; // /bookings — AllBookingScreen (tab 2)
  static const profile = 'profile'; // /profile  — MyProfile     (tab 3)

  /// The branch root paths indexed by tab number. `pathForShellTab(n)` is the
  /// single mapping used by every "jump to tab N" call site (splash, login,
  /// notifications, booking-confirmed, jumpToShellTab, …) now that the old
  /// `/shell?tab=N` query-param scheme is gone.
  static const List<String> shellBranchPaths = [
    '/home',
    '/fleet',
    '/bookings',
    '/profile',
  ];

  static String pathForShellTab(int tab) =>
      shellBranchPaths[(tab >= 0 && tab < shellBranchPaths.length) ? tab : 0];

  // cars / search
  static const allCars = 'allCars';
  static const carsInformation = 'carsInformation';
  static const filterCars = 'filterCars';
  static const searchAboutCar = 'searchAboutCar';
  static const imageCarPage = 'imageCarPage';
  static const classic = 'classic';

  // booking
  static const branchWithCar = 'branchWithCar';
  static const dailyPackage = 'dailyPackage';
  static const monthlyPackage = 'monthlyPackage';
  static const airportPackage = 'airportPackage';
  static const deliveryPackage = 'deliveryPackage';
  static const carsListPackage = 'carsListPackage'; // /package-cars
  static const carsMonthly = 'carsMonthly'; //        /monthly-cars
  static const additions = 'additions';
  static const bookDetails = 'bookDetails';
  static const bookingConfirmed = 'bookingConfirmed';

  // payment
  static const paymentMethods = 'paymentMethods';
  static const invoice = 'invoice';
  static const invoiceNotCompleted = 'invoiceNotCompleted';
  static const webPayment = 'webPayment';

  // location
  static const locationPicker = 'locationPicker'; // returns Map<String, dynamic>
  static const viewLocation = 'viewLocation';

  // profile / misc
  static const callUs = 'callUs';
  static const editProfile = 'editProfile';
  static const favourites = 'favourites';
  static const resetPassword = 'resetPassword';
  static const branches = 'branches';
  static const cashback = 'cashback';
  static const complaints = 'complaints';
  static const offers = 'offers';
  static const offerDetails = 'offerDetails';
  static const notifications = 'notifications';
  static const privacyPolicy = 'privacyPolicy';
  static const selectLanguage = 'selectLanguage';
}

// NOTE: route args are passed via GoRoute `extra` — NOT serializable.
// None of these routes can be reached from a deep link, push notification,
// or app-restart restoration. If/when deep linking is needed, refactor
// specific routes to use path params (e.g. /cars/:id) and fetch-by-id.
