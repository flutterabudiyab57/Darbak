// this is our main endpoints
// https://abudiyab-soft.com/api
// https://darakson.abudiyabksa.com/
const String productionApi = "https://api.daraksonksa.com/api";

// const String productionApi = "https://abudiyab-soft.com/api";

const String devEnvApi = "https://sa.abudiyab.com.sa/api";
const String stagApi = "https://stage-darakson.abudiyabksa.com/api";
const String testApi = "https://api-darakson.abudiyabksa.com/api";
const String mainApi = stagApi;
const String oracleApi = "http://oracle.abudiyab-soft.com/api";
////////////////// AUTH
// Endpoint for login request`
// with adding to queryParameters/Headers that {"Accept": "application/json"}
const String loginApi = '/login';
const String register = "/register";
const String complaints = mainApi + '/complaints';
////////////////////////////////////////
const String category = "/categories";
const String offers = "/check_for_offers";
const String allCars = "/cars/filter";
const String searchAboutCars = mainApi + "/cars";
const String allCarsOffers = "/filters";
const String memberShipCars = "/cars_membership/filter";
const String carsByBranch = allCars + "?from_app=1&branch_id=";
const String getAllBranchBranch = mainApi + "?branches";
const String carsByPages = allCars + "?page=";
const String carsByPages2 = allCars + "&page=";
const String custClass = "&cust_class=";
// Endpoint for manufactories request
const String manufactories = mainApi + "/manufactories";
const String newManufactories = mainApi + "/web/manufactories";
const String changePasswordPath = mainApi + "/profile";
const String DeleteProfile = mainApi + "/deleteAccount";
const String passwordForget = mainApi + "/password/forget";
const String codeForget = mainApi + "/password/code";
const String resetPasswordPath = mainApi + "/password/reset";
////// Offers
const String getOffers = mainApi + "/offers";
const String checkVersionUpdate = '$mainApi/settings/version';
const String settings = '$mainApi/settings';

const String getOrders = mainApi + "/orders/get-orders";
const String orderStepOnePath = mainApi + "/orders/step1";
const String invoicePath = mainApi + "/orders/step2";
const String paymentPath = mainApi + "/orders/step3";
const String checkSteps = mainApi + "/orders/check";
///////////////////////////////////////////////////////////

const String dateCheckPoint = mainApi + "/available/time";
const String favourite = mainApi + "/favorite/";
const String regions = mainApi + "/regions";
const String areas = mainApi + "/areas";
const String sliderData = mainApi + "/sliders";
const String checkOrderPath = mainApi + '/orders/check';
const String couponPath = mainApi + '/order/coupon';
const String deleteCouponPath = mainApi + '/order/delete-coupon';
const String allCouponsPath = mainApi + '/order/coupons';
const String pointsPath = mainApi + '/order/points';
const String pointsDeletePath = mainApi + '/order/delete-points';
const String cancelOrder = mainApi + '/order/cancel';
const String deleteOrder = mainApi + '/orders/delete-order';
const String editOrder = mainApi + '/orders/';
const String allMemberShip = mainApi + "/memberships";
const String cashbackbalance = mainApi + '/cashback/balance';
const String cashbacktransactions = mainApi + '/cashback/transactions';
const String applycashback = mainApi + '/cashback/apply-to-order';

// ////////////////// OLD CUSTOMER ///////////////////
// const String enterInfoOldCustomer = mainApi + "/old/user/forget";
// const String enterCodeOldCustomer = mainApi + "/old/user/code";
// const String enterEmailAndPassOldCustomer = mainApi + "/old/user/reset";
////////////////// AUTOMATION//////////////
// const String carAutomatedPath = mainApi + "/automated_cars?area_id=";
const String step1Automation = mainApi + "/contracts/step1";
const String invoiceAutomationPath = mainApi + "/contracts/step2";
const String paymentAutomationPath = mainApi + "/contracts/step3";
const String bookingAutomationPath = mainApi + "/contracts";
const String uploadImageAutomationPath = mainApi + "/uploadImage";
const String checkQrAutomationPath = mainApi + "/qr/check";
//  const String sendCodeAutomationPath = mainApi + "/sendcode/";
//  const String verifyCodeAutomationPath = mainApi + "/verificationCode";
const String cancelBookingAutomationPath = mainApi + "/cancel/contracts";
// const String areaLocationsPath = mainApi + "/locationArea?contract_id=";
