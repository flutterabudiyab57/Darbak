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

  // shell
  static const shell = 'shell'; // /shell?tab=N

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
  static const additions = 'additions';
  static const bookDetails = 'bookDetails';

  // payment
  static const paymentMethods = 'paymentMethods';
  static const invoice = 'invoice';
  static const invoiceNotCompleted = 'invoiceNotCompleted';
  static const webPayment = 'webPayment';

  // location
  static const locationPicker = 'locationPicker'; // returns Map<String, dynamic>
  static const viewLocation = 'viewLocation';

  // profile / misc
  static const editProfile = 'editProfile';
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
