import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import 'languages/arabic.dart';
import 'languages/english.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  bool isDirectionRTL(BuildContext context) {
    return intl.Bidi.isRtlLanguage(
        Localizations.localeOf(context).languageCode);
  }

  static Map<String, Map<String, String>> _localizedValues = {
    'en': english(),
    'ar': arabic(),
  };

  String get loading => _localizedValues[locale.languageCode]!['loading']!;

  String get selectLocation =>
      _localizedValues[locale.languageCode]!['selectLocation']!;

  String get remove => _localizedValues[locale.languageCode]!['remove']!;

  String get dataUser => _localizedValues[locale.languageCode]!['dataUser']!;

  String get checkOut => _localizedValues[locale.languageCode]!['checkOut']!;
  String get retry => _localizedValues[locale.languageCode]!['retry']!;

  String get notificationsTitle =>
      _localizedValues[locale.languageCode]!['notificationsTitle']!;
  String get notificationsEmpty =>
      _localizedValues[locale.languageCode]!['notificationsEmpty']!;
  String get markAllAsRead =>
      _localizedValues[locale.languageCode]!['markAllAsRead']!;
  String get notificationsError =>
      _localizedValues[locale.languageCode]!['notificationsError']!;

  String get availableBalance =>
      _localizedValues[locale.languageCode]!['availableBalance'] ?? "";

  String get autoDeductBalance =>
      _localizedValues[locale.languageCode]!['autoDeductBalance'] ?? "";

  String get tackPhoto => _localizedValues[locale.languageCode]!['tackPhoto']!;

  String get gallery => _localizedValues[locale.languageCode]!['gallery']!;

  String get agreeTerms =>
      _localizedValues[locale.languageCode]!['agreeTerms']!;

  String get confirm => _localizedValues[locale.languageCode]!['confirm']!;

  String get someDataNotComplete =>
      _localizedValues[locale.languageCode]!['someDataNotComplete']!;

  String get abudiyab => _localizedValues[locale.languageCode]!['abudiyab']!;

  String get total2 => _localizedValues[locale.languageCode]!['total2']!;

  String get total3 => _localizedValues[locale.languageCode]!['total3']!;

  String get pleaseEnterPhoneNumber =>
      _localizedValues[locale.languageCode]!['pleaseEnterPhoneNumber']!;


  String get passwordNotMatching =>
      _localizedValues[locale.languageCode]!['passwordNotMatching']!;

  String get passwordTooShort =>
      _localizedValues[locale.languageCode]!['passwordTooShort']!;

  String get pleaseEnterPassword =>
      _localizedValues[locale.languageCode]!['pleaseEnterPassword']!;

  String get pleaseEnterValidCredit =>
      _localizedValues[locale.languageCode]!['pleaseEnterValidCredit']!;

  String get enterValidCVV =>
      _localizedValues[locale.languageCode]!['enterValidCVV']!;

  String get pleaseEnterEmail =>
      _localizedValues[locale.languageCode]!['pleaseEnterEmail']!;

  String get pleaseEnterName =>
      _localizedValues[locale.languageCode]!['pleaseEnterName']!;

  String get enterNameMiniChars =>
      _localizedValues[locale.languageCode]!['enterNameMiniChars']!;

  String get enterValidEmail =>
      _localizedValues[locale.languageCode]!['enterValidEmail']!;

  String get doneEditProfile =>
      _localizedValues[locale.languageCode]!['doneEditProfile']!;

  String get more => _localizedValues[locale.languageCode]!['more']!;

  String get continuePaymentProcess =>
      _localizedValues[locale.languageCode]!['continuePaymentProcess']!;

  String get price => _localizedValues[locale.languageCode]!['price']!;

  String get selectModel =>
      _localizedValues[locale.languageCode]!['selectModel']!;

  String get rentalDiscount =>
      _localizedValues[locale.languageCode]!['rentalDiscount']!;

  String get allowedKilos =>
      _localizedValues[locale.languageCode]!['allowedKilos']!;

  String get extraHours =>
      _localizedValues[locale.languageCode]!['extraHours']!;

  String get hour => _localizedValues[locale.languageCode]!['hour']!;

  String get ratioPoints =>
      _localizedValues[locale.languageCode]!['ratioPoints']!;

  String? get selectRegion =>
      _localizedValues[locale.languageCode]!['selectRegion'];

  String get dateInvalid =>
      _localizedValues[locale.languageCode]!['dateInvalid']!;

  String get selectRegionAndBranch =>
      _localizedValues[locale.languageCode]!['selectRegionAndBranch']!;

  String? get continueAsGuest =>
      _localizedValues[locale.languageCode]!['continueAsGuest'];

  String? get deliveryDate =>
      _localizedValues[locale.languageCode]!['deliveryDate'];

  String? get carNotAvailable =>
      _localizedValues[locale.languageCode]!['carNotAvailable'];

  String? get checkUsernameAndPassword =>
      _localizedValues[locale.languageCode]!['checkUsernameAndPassword'];

  String? get allDays => _localizedValues[locale.languageCode]!['allDays'];

  String? get next => _localizedValues[locale.languageCode]!['next'];

  String? get back => _localizedValues[locale.languageCode]!['back'];

  String? get goToHome => _localizedValues[locale.languageCode]!['goToHome'];

  String? get goHome => _localizedValues[locale.languageCode]!['goHome'];

  String get goToBookings =>
      _localizedValues[locale.languageCode]!['goToBookings']!;

  String get bookingNotAvailable =>
      _localizedValues[locale.languageCode]!['bookingNotAvailable']!;

  String get bookingSuccessMessage =>
      _localizedValues[locale.languageCode]!['bookingSuccessMessage']!;

  String get success => _localizedValues[locale.languageCode]!['success']!;
  String get cancelBooking =>
      _localizedValues[locale.languageCode]!['cancelBooking']!;
  String get pleaseEnterIdNumber =>
      _localizedValues[locale.languageCode]!['pleaseEnterIdNumber']!;
  String get idMustBe10Digits =>
      _localizedValues[locale.languageCode]!['idMustBe10Digits']!;
  String get pleaseEnterValidPhone =>
      _localizedValues[locale.languageCode]!['pleaseEnterValidPhone']!;
  String get pleaseEnterExpireYear =>
      _localizedValues[locale.languageCode]!['pleaseEnterExpireYear']!;
  String get pleaseEnterValidYear =>
      _localizedValues[locale.languageCode]!['pleaseEnterValidYear']!;
  String get cardIsExpired =>
      _localizedValues[locale.languageCode]!['cardIsExpired']!;
  String get month => _localizedValues[locale.languageCode]!['month']!;
  String get months => _localizedValues[locale.languageCode]!['months']!;
  String get paymentTypeLabel =>
      _localizedValues[locale.languageCode]!['paymentTypeLabel']!;
  String get deliveryAndPickup =>
      _localizedValues[locale.languageCode]!['deliveryAndPickup']!;
  String get pickUpFromBranch =>
      _localizedValues[locale.languageCode]!['pickUpFromBranch']!;
  String get pickupFromTheBranch =>
      _localizedValues[locale.languageCode]!['pickupFromTheBranch']!;
  String get airportsTitle =>
      _localizedValues[locale.languageCode]!['airportsTitle']!;
  String get orderCancelledSuccessfully =>
      _localizedValues[locale.languageCode]!['orderCancelledSuccessfully']!;
  String get orderDeletedSuccessfully =>
      _localizedValues[locale.languageCode]!['orderDeletedSuccessfully']!;
  String get totalAmountLabel =>
      _localizedValues[locale.languageCode]!['totalAmountLabel']!;
  String get dontDelete =>
      _localizedValues[locale.languageCode]!['dontDelete']!;
  String get cancelOrder =>
      _localizedValues[locale.languageCode]!['cancelOrder']!;
  String get dateLabel => _localizedValues[locale.languageCode]!['dateLabel']!;
  String get otpVerification =>
      _localizedValues[locale.languageCode]!['otpVerification']!;
  String get otpCode => _localizedValues[locale.languageCode]!['otpCode']!;
  String get enterSixDigitCodeSent =>
      _localizedValues[locale.languageCode]!['enterSixDigitCodeSent']!;
  String get verifyNow => _localizedValues[locale.languageCode]!['verifyNow']!;
  String get otpResentSuccessfully =>
      _localizedValues[locale.languageCode]!['otpResentSuccessfully']!;
  String get otpResendFailed =>
      _localizedValues[locale.languageCode]!['otpResendFailed']!;
  String get checkInternetError =>
      _localizedValues[locale.languageCode]!['checkInternetError']!;
  String get didntReceiveCode =>
      _localizedValues[locale.languageCode]!['didntReceiveCode']!;
  String get resend => _localizedValues[locale.languageCode]!['resend']!;
  String get cashback => _localizedValues[locale.languageCode]!['cashback']!;
  String get pleaseEnterYourPoints =>
      _localizedValues[locale.languageCode]!['pleaseEnterYourPoints']!;
  String get discountPointsApplied =>
      _localizedValues[locale.languageCode]!['discountPointsApplied']!;
  String get dontHaveAnyPoints =>
      _localizedValues[locale.languageCode]!['dontHaveAnyPoints']!;
  String get discountPointsDeleted =>
      _localizedValues[locale.languageCode]!['discountPointsDeleted']!;
  String get pointsBalance =>
      _localizedValues[locale.languageCode]!['pointsBalance']!;
  String get ourOffers =>
      _localizedValues[locale.languageCode]!['ourOffers']!;
  String get offerDetails =>
      _localizedValues[locale.languageCode]!['offerDetails']!;
  String get welcomeToDarbak =>
      _localizedValues[locale.languageCode]!['welcomeToDarbak']!;
  String get chooseYourLanguage =>
      _localizedValues[locale.languageCode]!['chooseYourLanguage']!;
  String get trackBalanceAndPayments =>
      _localizedValues[locale.languageCode]!['trackBalanceAndPayments']!;
  String get serverErrorCheckLogs =>
      _localizedValues[locale.languageCode]!['serverErrorCheckLogs']!;
  String get enterValidSixDigitOtp =>
      _localizedValues[locale.languageCode]!['enterValidSixDigitOtp']!;
  String get accountVerifiedSuccessfully =>
      _localizedValues[locale.languageCode]!['accountVerifiedSuccessfully']!;
  String get verificationFailedTryAgain =>
      _localizedValues[locale.languageCode]!['verificationFailedTryAgain']!;
  String get addYourPointsHint =>
      _localizedValues[locale.languageCode]!['addYourPointsHint']!;
  String get madfouPaymentLabel =>
      _localizedValues[locale.languageCode]!['madfouPaymentLabel']!;
  String get tamaraPaymentLabel =>
      _localizedValues[locale.languageCode]!['tamaraPaymentLabel']!;
  String get branchError =>
      _localizedValues[locale.languageCode]!['branchError']!;
  String get noCarsCurrently =>
      _localizedValues[locale.languageCode]!['noCarsCurrently']!;
  String get invalidUrl =>
      _localizedValues[locale.languageCode]!['invalidUrl']!;
  String get noInternetConnection =>
      _localizedValues[locale.languageCode]!['noInternetConnection']!;
  String get loadingData =>
      _localizedValues[locale.languageCode]!['loadingData']!;
  String get whatsappNotInstalled =>
      _localizedValues[locale.languageCode]!['whatsappNotInstalled']!;
  String get locationPermissionDenied =>
      _localizedValues[locale.languageCode]!['locationPermissionDenied']!;
  String get locationPermissionDeniedBody =>
      _localizedValues[locale.languageCode]!['locationPermissionDeniedBody']!;
  String get tryAgain => _localizedValues[locale.languageCode]!['tryAgain']!;
  String get permissionRequired =>
      _localizedValues[locale.languageCode]!['permissionRequired']!;
  String get permissionPermanentlyDeniedBody =>
      _localizedValues[locale.languageCode]!['permissionPermanentlyDeniedBody']!;
  String get openSettings =>
      _localizedValues[locale.languageCode]!['openSettings']!;
  String get errorFetchingCoupons =>
      _localizedValues[locale.languageCode]!['errorFetchingCoupons']!;
  String get couldNotLaunchUrl =>
      _localizedValues[locale.languageCode]!['couldNotLaunchUrl']!;
  String get invalidBranchSelected =>
      _localizedValues[locale.languageCode]!['invalidBranchSelected']!;
  String get whatsappGreeting =>
      _localizedValues[locale.languageCode]!['whatsappGreeting']!;
  String get whatsappHelpRequest =>
      _localizedValues[locale.languageCode]!['whatsappHelpRequest']!;
  String get phoneNumberTooShort =>
      _localizedValues[locale.languageCode]!['phoneNumberTooShort']!;
  String get sessionExpiredLoginAgain =>
      _localizedValues[locale.languageCode]!['sessionExpiredLoginAgain']!;
  String get unauthorizedAction =>
      _localizedValues[locale.languageCode]!['unauthorizedAction']!;
  String get serverErrorTryLater =>
      _localizedValues[locale.languageCode]!['serverErrorTryLater']!;
  String get checkInternetConnection =>
      _localizedValues[locale.languageCode]!['checkInternetConnection']!;
  String get somethingWentWrong =>
      _localizedValues[locale.languageCode]!['somethingWentWrong']!;
  String get complaintSentSuccessfully =>
      _localizedValues[locale.languageCode]!['complaintSentSuccessfully']!;
  String get complaintDescription =>
      _localizedValues[locale.languageCode]!['complaintDescription']!;
  String get pleaseEnterComplaint =>
      _localizedValues[locale.languageCode]!['pleaseEnterComplaint']!;

  String get niceToMeetYou =>
      _localizedValues[locale.languageCode]!['niceToMeetYou']!;

  String get openAccountSubtitle =>
      _localizedValues[locale.languageCode]!['openAccountSubtitle']!;

  String get createAccount =>
      _localizedValues[locale.languageCode]!['createAccount']!;

  String get saudiPhoneMustBe9Digits =>
      _localizedValues[locale.languageCode]!['saudiPhoneMustBe9Digits']!;
  String get saudiPhoneMustStartWith5 =>
      _localizedValues[locale.languageCode]!['saudiPhoneMustStartWith5']!;
  String get oldPasswordIncorrect =>
      _localizedValues[locale.languageCode]!['oldPasswordIncorrect']!;
  String get pleaseEnterExpireMonth =>
      _localizedValues[locale.languageCode]!['pleaseEnterExpireMonth']!;
  String get pleaseEnterMonthIn2Digits =>
      _localizedValues[locale.languageCode]!['pleaseEnterMonthIn2Digits']!;
  String get pleaseEnterValidMonth =>
      _localizedValues[locale.languageCode]!['pleaseEnterValidMonth']!;
  String get contactNumbers =>
      _localizedValues[locale.languageCode]!['contactNumbers']!;
  String get socialMedia =>
      _localizedValues[locale.languageCode]!['socialMedia']!;
  String get visitOurWebsite =>
      _localizedValues[locale.languageCode]!['visitOurWebsite']!;
  String get checkMobileNumber =>
      _localizedValues[locale.languageCode]!['checkMobileNumber']!;
  String get forgetPasswordDescription =>
      _localizedValues[locale.languageCode]!['forgetPasswordDescription']!;
  String get makeSureNewPassword =>
      _localizedValues[locale.languageCode]!['makeSureNewPassword']!;
  String get returnToLoginScreen =>
      _localizedValues[locale.languageCode]!['returnToLoginScreen']!;
  String get pleaseEnter4DigitCode =>
      _localizedValues[locale.languageCode]!['pleaseEnter4DigitCode']!;
  String get exploreOurBranches =>
      _localizedValues[locale.languageCode]!['exploreOurBranches']!;
  String get noBranchWithThisName =>
      _localizedValues[locale.languageCode]!['noBranchWithThisName']!;
  String get errorOccurredProcessing =>
      _localizedValues[locale.languageCode]!['errorOccurredProcessing']!;
  String get errorCancelingBooking =>
      _localizedValues[locale.languageCode]!['errorCancelingBooking']!;
  String get errorDeletingBooking =>
      _localizedValues[locale.languageCode]!['errorDeletingBooking']!;
  String get perDay => _localizedValues[locale.languageCode]!['perDay']!;
  String get searchYourFavoriteCar =>
      _localizedValues[locale.languageCode]!['searchYourFavoriteCar']!;
  String get noResultsFound =>
      _localizedValues[locale.languageCode]!['noResultsFound']!;
  String get vehicleClass =>
      _localizedValues[locale.languageCode]!['vehicleClass']!;
  String get searchForACar =>
      _localizedValues[locale.languageCode]!['searchForACar']!;
  String get ongoingBooking =>
      _localizedValues[locale.languageCode]!['ongoingBooking']!;
  String get previousBooking =>
      _localizedValues[locale.languageCode]!['previousBooking']!;
  String get bookingCostLabel =>
      _localizedValues[locale.languageCode]!['bookingCostLabel']!;
  String get bookingCostColon =>
      _localizedValues[locale.languageCode]!['bookingCostColon']!;
  String get bookingDateColon =>
      _localizedValues[locale.languageCode]!['bookingDateColon']!;
  String get dontCancel =>
      _localizedValues[locale.languageCode]!['dontCancel']!;
  String get cancelOrderAction =>
      _localizedValues[locale.languageCode]!['cancelOrderAction']!;
  String get continueOrder =>
      _localizedValues[locale.languageCode]!['continueOrder']!;
  String get bookingDays =>
      _localizedValues[locale.languageCode]!['bookingDays']!;
  String get daySuffix =>
      _localizedValues[locale.languageCode]!['daySuffix']!;
  String get paymentDetails =>
      _localizedValues[locale.languageCode]!['paymentDetails']!;
  String get couponDiscount =>
      _localizedValues[locale.languageCode]!['couponDiscount']!;
  String get pointsPayment =>
      _localizedValues[locale.languageCode]!['pointsPayment']!;
  String get pointsDiscount =>
      _localizedValues[locale.languageCode]!['pointsDiscount']!;
  String get locationNotAvailable =>
      _localizedValues[locale.languageCode]!['locationNotAvailable']!;
  String get pickupFromAirports =>
      _localizedValues[locale.languageCode]!['pickupFromAirports']!;
  String get chargedDailyPrice =>
      _localizedValues[locale.languageCode]!['chargedDailyPrice']!;
  String get chargedMonthlyPrice =>
      _localizedValues[locale.languageCode]!['chargedMonthlyPrice']!;
  String get selectAirport =>
      _localizedValues[locale.languageCode]!['selectAirport']!;
  String get chooseMonthlyPackage =>
      _localizedValues[locale.languageCode]!['chooseMonthlyPackage']!;
  String get monthlyPackages =>
      _localizedValues[locale.languageCode]!['monthlyPackages']!;
  String get selectDeliveryBranchFirst =>
      _localizedValues[locale.languageCode]!['selectDeliveryBranchFirst']!;
  String get selectRegionFirst =>
      _localizedValues[locale.languageCode]!['selectRegionFirst']!;
  String get customLocationLabel =>
      _localizedValues[locale.languageCode]!['customLocationLabel']!;
  String get selectPickupLocation =>
      _localizedValues[locale.languageCode]!['selectPickupLocation']!;
  String get selectDropoffLocation =>
      _localizedValues[locale.languageCode]!['selectDropoffLocation']!;
  String get selectDeliveryBranchMsg =>
      _localizedValues[locale.languageCode]!['selectDeliveryBranchMsg']!;
  String get errorSelectingBranch =>
      _localizedValues[locale.languageCode]!['errorSelectingBranch']!;
  String get errorDuringValidation =>
      _localizedValues[locale.languageCode]!['errorDuringValidation']!;
  String get choosePickupArea =>
      _localizedValues[locale.languageCode]!['choosePickupArea']!;
  String get priceCalculatedByDuration =>
      _localizedValues[locale.languageCode]!['priceCalculatedByDuration']!;
  String get selectCity =>
      _localizedValues[locale.languageCode]!['selectCity']!;
  String get selectDropoffRegion =>
      _localizedValues[locale.languageCode]!['selectDropoffRegion']!;
  String get whereToDeliver =>
      _localizedValues[locale.languageCode]!['whereToDeliver']!;
  String get whereToPickup =>
      _localizedValues[locale.languageCode]!['whereToPickup']!;
  String get exploreBestExclusiveOffers =>
      _localizedValues[locale.languageCode]!['exploreBestExclusiveOffers']!;
  String get carsInOffer =>
      _localizedValues[locale.languageCode]!['carsInOffer']!;
  String get offerAvailableAllCars =>
      _localizedValues[locale.languageCode]!['offerAvailableAllCars']!;
  String get exploreExclusiveOffers =>
      _localizedValues[locale.languageCode]!['exploreExclusiveOffers']!;
  String get stayTunedForOffers =>
      _localizedValues[locale.languageCode]!['stayTunedForOffers']!;
  String get noOfferDetailsYet =>
      _localizedValues[locale.languageCode]!['noOfferDetailsYet']!;
  String get discountCoupon =>
      _localizedValues[locale.languageCode]!['discountCoupon']!;
  String get viewAvailableCoupons =>
      _localizedValues[locale.languageCode]!['viewAvailableCoupons']!;
  String get madfouDescription =>
      _localizedValues[locale.languageCode]!['madfouDescription']!;
  String get tamaraDescription =>
      _localizedValues[locale.languageCode]!['tamaraDescription']!;
  String get checkCardDetails =>
      _localizedValues[locale.languageCode]!['checkCardDetails']!;
  String get checkCardDetailsShort =>
      _localizedValues[locale.languageCode]!['checkCardDetailsShort']!;
  String get invoiceLabel =>
      _localizedValues[locale.languageCode]!['invoiceLabel']!;
  String get paymentMethodUpdated =>
      _localizedValues[locale.languageCode]!['paymentMethodUpdated']!;
  String get cashbackCovered100Percent =>
      _localizedValues[locale.languageCode]!['cashbackCovered100Percent']!;
  String get payNow => _localizedValues[locale.languageCode]!['payNow']!;
  String get notEnoughPoints =>
      _localizedValues[locale.languageCode]!['notEnoughPoints']!;
  String get freeServices =>
      _localizedValues[locale.languageCode]!['freeServices']!;
  String get helpOnRoad =>
      _localizedValues[locale.languageCode]!['helpOnRoad']!;
  String get receiveFullReturnFull =>
      _localizedValues[locale.languageCode]!['receiveFullReturnFull']!;
  String get freeHoursEquals =>
      _localizedValues[locale.languageCode]!['freeHoursEquals']!;
  String get hourSuffix =>
      _localizedValues[locale.languageCode]!['hourSuffix']!;
  String get accidentAssistance =>
      _localizedValues[locale.languageCode]!['accidentAssistance']!;
  String get cardNumber =>
      _localizedValues[locale.languageCode]!['cardNumber']!;
  String get cardHolderName =>
      _localizedValues[locale.languageCode]!['cardHolderName']!;
  String get expireMonth =>
      _localizedValues[locale.languageCode]!['expireMonth']!;
  String get expireYear =>
      _localizedValues[locale.languageCode]!['expireYear']!;
  String get addPaymentCard =>
      _localizedValues[locale.languageCode]!['addPaymentCard']!;
  String get invoiceDetails =>
      _localizedValues[locale.languageCode]!['invoiceDetails']!;
  String get deliveryValue =>
      _localizedValues[locale.languageCode]!['deliveryValue']!;
  String get availableCountLabel =>
      _localizedValues[locale.languageCode]!['availableCountLabel']!;
  String get insurance =>
      _localizedValues[locale.languageCode]!['insurance']!;
  String get rewardAfterTrip =>
      _localizedValues[locale.languageCode]!['rewardAfterTrip']!;
  String get finishTripEnjoy =>
      _localizedValues[locale.languageCode]!['finishTripEnjoy']!;
  String get pleaseEnterAmount =>
      _localizedValues[locale.languageCode]!['pleaseEnterAmount']!;
  String get pleaseEnterValidAmount =>
      _localizedValues[locale.languageCode]!['pleaseEnterValidAmount']!;
  String get amountExceedsBalance =>
      _localizedValues[locale.languageCode]!['amountExceedsBalance']!;
  String get failedToLoadInvoice =>
      _localizedValues[locale.languageCode]!['failedToLoadInvoice']!;
  String get darbakBalance =>
      _localizedValues[locale.languageCode]!['darbakBalance']!;
  String get pendingCashbackPrefix =>
      _localizedValues[locale.languageCode]!['pendingCashbackPrefix']!;
  String get amountToBeUsed =>
      _localizedValues[locale.languageCode]!['amountToBeUsed']!;
  String get mustSelectBranchFirst =>
      _localizedValues[locale.languageCode]!['mustSelectBranchFirst']!;
  String get dropOffMustBeAfterPickup =>
      _localizedValues[locale.languageCode]!['dropOffMustBeAfterPickup']!;
  String get addFavoriteCar =>
      _localizedValues[locale.languageCode]!['addFavoriteCar']!;

  String? get minutes => _localizedValues[locale.languageCode]!['minutes'];

  String? get seconds => _localizedValues[locale.languageCode]!['seconds'];

  String? get reset => _localizedValues[locale.languageCode]!['reset'];

  String? get enterIdAndNumber =>
      _localizedValues[locale.languageCode]!['enterIdAndNumber'];

  String? get send => _localizedValues[locale.languageCode]!['send'];

  String? get agreeTermsAndConditions =>
      _localizedValues[locale.languageCode]!['agreeTermsAndConditions'];

  String? get enterCodeSent =>
      _localizedValues[locale.languageCode]!['enterCodeSent'];

  String? get skip => _localizedValues[locale.languageCode]!['skip'];

  String? get pickUpArea =>
      _localizedValues[locale.languageCode]!['pickUpArea'];

  String? get dropOffBranch =>
      _localizedValues[locale.languageCode]!['dropOffBranch'];

  String? get dropOffArea =>
      _localizedValues[locale.languageCode]!['dropOffArea'];

  String? get deliverAnotherBranch =>
      _localizedValues[locale.languageCode]!['deliverAnotherBranch'];
  String? get toTime => _localizedValues[locale.languageCode]!['toTime'];
  String? get time => _localizedValues[locale.languageCode]!['time'];

  String? get search => _localizedValues[locale.languageCode]!['search'];

  String? get sar => _localizedValues[locale.languageCode]!['sar'];

  String? get day => _localizedValues[locale.languageCode]!['day'];

  String? get carName => _localizedValues[locale.languageCode]!['carName'];

  String? get type => _localizedValues[locale.languageCode]!['type'];

  String? get reservation =>
      _localizedValues[locale.languageCode]!['reservation'];

  String? get delivery => _localizedValues[locale.languageCode]!['delivery'];
  String? get deliveryTitle => _localizedValues[locale.languageCode]!['deliveryTitle'];
  String? get deliverySubtitle => _localizedValues[locale.languageCode]!['deliverySubtitle'];
  String? get deliveryCta => _localizedValues[locale.languageCode]!['deliveryCta'];
  String? get New => _localizedValues[locale.languageCode]!['new'];

  String? get region => _localizedValues[locale.languageCode]!['region'];

  String? get workTime => _localizedValues[locale.languageCode]!['workTime'];

  String? get morning => _localizedValues[locale.languageCode]!['morning'];

  String? get afternoon => _localizedValues[locale.languageCode]!['afternoon'];

  String? get branches => _localizedValues[locale.languageCode]!['branches'];

  String? get visa => _localizedValues[locale.languageCode]!['visa'];

  String? get cash => _localizedValues[locale.languageCode]!['cash'];

  String? get points => _localizedValues[locale.languageCode]!['points'];

  String? get invoice => _localizedValues[locale.languageCode]!['invoice'];

  String? get choseBranch =>
      _localizedValues[locale.languageCode]!['choseBranch'];

  String? get total => _localizedValues[locale.languageCode]!['total'];

  String? get allCar => _localizedValues[locale.languageCode]!['allCar'];

  String? get filterCars =>
      _localizedValues[locale.languageCode]!['filterCars'];

  String? get pricewithtax =>
      _localizedValues[locale.languageCode]!['pricewithtax'];

  String? get grandTotal =>
      _localizedValues[locale.languageCode]!['grandTotal'];

  String? get additions => _localizedValues[locale.languageCode]!['additions'];

  String? get rent => _localizedValues[locale.languageCode]!['rent'];

  String? get tam => _localizedValues[locale.languageCode]!['tam'];

  String? get transfer => _localizedValues[locale.languageCode]!['transfer'];

  String? get memberDiscount =>
      _localizedValues[locale.languageCode]!['memberDiscount'];

  String? get promotionalDiscount =>
      _localizedValues[locale.languageCode]!['promotionalDiscount'];

  String? get carDiscount =>
      _localizedValues[locale.languageCode]!['carDiscount'];

  String? get CashbackDiscount =>
      _localizedValues[locale.languageCode]!['cashbackDiscount'];

  String? get visaDiscount =>
      _localizedValues[locale.languageCode]!['visaDiscount'];

  String? get taxValue => _localizedValues[locale.languageCode]!['taxValue'];

  String? get addCoupon => _localizedValues[locale.languageCode]!['addCoupon'];

  String? get goToPayment =>
      _localizedValues[locale.languageCode]!['goToPayment'];

  String? get brand => _localizedValues[locale.languageCode]!['brand'];

  String? get category => _localizedValues[locale.languageCode]!['category'];

  String? get noMethodSelected =>
      _localizedValues[locale.languageCode]!['noMethodSelected'];

  String? get choosePaymentMethod =>
      _localizedValues[locale.languageCode]!['ChoosePaymentMethod'];

  String? get paymentMethod =>
      _localizedValues[locale.languageCode]!['paymentMethod'];

  String? get wantToCancel =>
      _localizedValues[locale.languageCode]!['wantToCancel'];

  String? get ok => _localizedValues[locale.languageCode]!['ok'];
  String? get no => _localizedValues[locale.languageCode]!['no'];

  String? get privacyPolicy =>
      _localizedValues[locale.languageCode]!['privacyPolicy'];

  String? get alreadyHaveAccount =>
      _localizedValues[locale.languageCode]!['alreadyHaveAccount'];

  String? get uploadedSuccessfully =>
      _localizedValues[locale.languageCode]!['uploadedSuccessfully'];

  String? get uploadLicense =>
      _localizedValues[locale.languageCode]!['uploadLicense'];

  String? get dontHaveAccount =>
      _localizedValues[locale.languageCode]!['dontHaveAccount'];



  String? get from => _localizedValues[locale.languageCode]!['from'];

  String? get to => _localizedValues[locale.languageCode]!['to'];

  String? get forgetPassword =>
      _localizedValues[locale.languageCode]!['forgetPassword'];

  String? get changePassword =>
      _localizedValues[locale.languageCode]!['changePassword'];

  String? get oldPassword =>
      _localizedValues[locale.languageCode]!['oldPassword'];

  String? get newPassword =>
      _localizedValues[locale.languageCode]!['newPassword'];

  String? get passwordChanged =>
      _localizedValues[locale.languageCode]!['passwordChanged'];

  String? get resetPassword =>
      _localizedValues[locale.languageCode]!['resetPassword'];

  String? get goBack => _localizedValues[locale.languageCode]!['goBack'];

  String? get copyCode => _localizedValues[locale.languageCode]!['copyCode'];

  String? get newPass => _localizedValues[locale.languageCode]!['newPass'];

  String? get done => _localizedValues[locale.languageCode]!['done'];

  String? get editProfile =>
      _localizedValues[locale.languageCode]!['editProfile'];

  String? get error => _localizedValues[locale.languageCode]!['error'];

  String? get memberShip =>
      _localizedValues[locale.languageCode]!['memberShip'];

  String? get favorite => _localizedValues[locale.languageCode]!['favorite'];

  String? get fleet => _localizedValues[locale.languageCode]!['fleet'];

  String? get signIn => _localizedValues[locale.languageCode]!['signIn'];

  String? get selectBranch {
    return _localizedValues[locale.languageCode]!['selectBranch'];
  }

  ///******************************************
  String? get titleOnboarding1 {
    return _localizedValues[locale.languageCode]!['titleOnboarding1'];
  }

  String? get applePayTotal {
    return _localizedValues[locale.languageCode]!['applePayTotal'];
  }

  String? get openLocation {
    return _localizedValues[locale.languageCode]!['openLocation'];
  }

  String? get LocationOnMap {
    return _localizedValues[locale.languageCode]!['LocationOnMap'];
  }

  String? get car {
    return _localizedValues[locale.languageCode]!['car'];
  }

  String? get searchCar {
    return _localizedValues[locale.languageCode]!['searchCar'];
  }

  String? get delete {
    return _localizedValues[locale.languageCode]!['delete'];
  }

  String? get bodyOnboarding1 {
    return _localizedValues[locale.languageCode]!['bodyOnboarding1'];
  }

  String? get titleOnboarding2 {
    return _localizedValues[locale.languageCode]!['titleOnboarding2'];
  }

  String? get bodyOnboarding2 {
    return _localizedValues[locale.languageCode]!['bodyOnboarding2'];
  }

  String? get titleOnboarding3 {
    return _localizedValues[locale.languageCode]!['titleOnboarding3'];
  }

  String? get bodyOnboarding3 {
    return _localizedValues[locale.languageCode]!['bodyOnboarding3'];
  }

  String? get moredetails {
    return _localizedValues[locale.languageCode]!['moredetails'];
  }

  String? get follow {
    return _localizedValues[locale.languageCode]!['follow'];
  }

  String? get finish {
    return _localizedValues[locale.languageCode]!['finish'];
  }

  String? get loginToContinue {
    return _localizedValues[locale.languageCode]!['LoginToContinue'];
  }

  String? get netAmount {
    return _localizedValues[locale.languageCode]!['netAmount'];
  }

  String? get oldCustCode {
    return _localizedValues[locale.languageCode]!['oldCustCode'];
  }

  String? get lookLike {
    return _localizedValues[locale.languageCode]!['lookLike'];
  }

  String? get lookLike1 {
    return _localizedValues[locale.languageCode]!['lookLike1'];
  }

  String? get errorData {
    return _localizedValues[locale.languageCode]!['errorData'];
  }

  String? get areYouSurelogout {
    return _localizedValues[locale.languageCode]!['areYouSurelogout'];
  }

  String? get noCarsInBranch {
    return _localizedValues[locale.languageCode]!['noCarsInBranch'];
  }

  String? get noCarsBooking1 {
    return _localizedValues[locale.languageCode]!['noCarsBooking1'];
  }

  String? get noCarsBookings =>
      _localizedValues[locale.languageCode]!['noCarsBookings'];

  String? get bookingnumber =>
      _localizedValues[locale.languageCode]!['bookingnumber'];

  String? get applePay {
    return _localizedValues[locale.languageCode]!['applePay'];
  }

  String? get welcomeAtAbudiyab {
    return _localizedValues[locale.languageCode]!['welcomeAtAbudiyab'];
  }

  ///**************************************
  String? get confirmPassword {
    return _localizedValues[locale.languageCode]!['confirmPassword'];
  }

  String? get facebook {
    return _localizedValues[locale.languageCode]!['facebook'];
  }

  String? get google {
    return _localizedValues[locale.languageCode]!['google'];
  }

  String? get fullName {
    return _localizedValues[locale.languageCode]!['fullName'];
  }

  String? get password {
    return _localizedValues[locale.languageCode]!['password'];
  }

  String? get emailAddress {
    return _localizedValues[locale.languageCode]!['emailAddress'];
  }

  String? get myBookings {
    return _localizedValues[locale.languageCode]!['myBookings'];
  }

  String? get favourites {
    return _localizedValues[locale.languageCode]!['favourites'];
  }

  String? get home {
    return _localizedValues[locale.languageCode]!['home'];
  }

  String? get logout {
    return _localizedValues[locale.languageCode]!['logout'];
  }

  String? get submit {
    return _localizedValues[locale.languageCode]!['submit'];
  }

  String? get complaint {
    return _localizedValues[locale.languageCode]!['complaint'];
  }

  String? get bookNow {
    return _localizedValues[locale.languageCode]!['bookNow'];
  }

  String? get viewAll {
    return _localizedValues[locale.languageCode]!['viewAll'];
  }

  String? get carSelected {
    return _localizedValues[locale.languageCode]!['carSelected'];
  }

  String? get registerNow {
    return _localizedValues[locale.languageCode]!['registerNow'];
  }

  String? get payment {
    return _localizedValues[locale.languageCode]!['payment'];
  }

  String? get bookingConfirmed {
    return _localizedValues[locale.languageCode]!['bookingConfirmed'];
  }

  String? get cancel {
    return _localizedValues[locale.languageCode]!['cancel'];
  }

  String? get peopleRated {
    return _localizedValues[locale.languageCode]!['peopleRated'];
  }

  String? get transactionsrecord {
    return _localizedValues[locale.languageCode]!['transactionsrecord'];
  }

  String? get apply {
    return _localizedValues[locale.languageCode]!['apply'];
  }

  String? get selectDateAndTime {
    return _localizedValues[locale.languageCode]!['selectDateAndTime'];
  }

  String? get callUs {
    return _localizedValues[locale.languageCode]!['callUs'];
  }

  String? get about {
    return _localizedValues[locale.languageCode]!['about'];
  }

  String? get address {
    return _localizedValues[locale.languageCode]!['address'];
  }

  String? get location {
    return _localizedValues[locale.languageCode]!['location'];
  }

  String? get days {
    return _localizedValues[locale.languageCode]!['days'];
  }

  String? get changeLanguage {
    return _localizedValues[locale.languageCode]!['changeLanguage'];
  }

  String? get selectLanguage {
    return _localizedValues[locale.languageCode]!['selectLanguage'];
  }

  String? get wallet {
    return _localizedValues[locale.languageCode]!['wallet'];
  }

  String? get register {
    return _localizedValues[locale.languageCode]!['register'];
  }

  String? get enterName {
    return _localizedValues[locale.languageCode]!['enterName'];
  }

  String? get save {
    return _localizedValues[locale.languageCode]!['save'];
  }



  String? get dummyName1 {
    return _localizedValues[locale.languageCode]!['dummyName1'];
  }

  String? get dummyRating {
    return _localizedValues[locale.languageCode]!['dummyRating'];
  }

  String? get profile {
    return _localizedValues[locale.languageCode]!['profile'];
  }

  String? get eng {
    return _localizedValues[locale.languageCode]!['english'];
  }

  String? get arab {
    return _localizedValues[locale.languageCode]!['arabic'];
  }

  String? get dummyDate1 {
    return _localizedValues[locale.languageCode]!['dummyDate1'];
  }

  String? get enteramount {
    return _localizedValues[locale.languageCode]!['enteramount'];
  }

  String? get lorem {
    return _localizedValues[locale.languageCode]!['lorem'];
  }

  String? get sun {
    return _localizedValues[locale.languageCode]!['sun'];
  }

  String? get mon {
    return _localizedValues[locale.languageCode]!['mon'];
  }

  String? get tue {
    return _localizedValues[locale.languageCode]!['tue'];
  }

  String? get wed {
    return _localizedValues[locale.languageCode]!['wed'];
  }

  String? get fri {
    return _localizedValues[locale.languageCode]!['fri'];
  }

  String? get sat {
    return _localizedValues[locale.languageCode]!['sat'];
  }

  String? get searchLocation {
    return _localizedValues[locale.languageCode]!['searchLocation'];
  }

  String? get bookingDetails {
    return _localizedValues[locale.languageCode]!['bookingDetails'];
  }

  String get updateAvailable =>
      _localizedValues[locale.languageCode]!['updateAvailable']!;

  String get updateAvailableMessage =>
      _localizedValues[locale.languageCode]!['updateAvailableMessage']!;

  String get updateNow => _localizedValues[locale.languageCode]!['updateNow']!;

  String get receivingBranch =>
      _localizedValues[locale.languageCode]!['receivingBranch']!;

  String get validIqamaNumber =>
      _localizedValues[locale.languageCode]!['validIqamaNumber']!;

  String get validNationalId =>
      _localizedValues[locale.languageCode]!['validNationalId']!;

  String get validPassportNumber =>
      _localizedValues[locale.languageCode]!['validPassportNumber']!;

  String get k1Month =>
      _localizedValues[locale.languageCode]!['k1Month']!;

  String get k12Months =>
      _localizedValues[locale.languageCode]!['k12Months']!;

  String get k3Months =>
      _localizedValues[locale.languageCode]!['k3Months']!;

  String get k6Months =>
      _localizedValues[locale.languageCode]!['k6Months']!;

  String get k9Months =>
      _localizedValues[locale.languageCode]!['k9Months']!;

  String get accountHasBeenCreatedSuccessfully =>
      _localizedValues[locale.languageCode]!['accountHasBeenCreatedSuccessfully']!;

  String get airports =>
      _localizedValues[locale.languageCode]!['airports']!;

  String get automatic =>
      _localizedValues[locale.languageCode]!['automatic']!;

  String get bags =>
      _localizedValues[locale.languageCode]!['bags']!;

  String get branchs =>
      _localizedValues[locale.languageCode]!['branchs']!;

  String get carDetails =>
      _localizedValues[locale.languageCode]!['carDetails']!;

  String get chooseLoginMethod =>
      _localizedValues[locale.languageCode]!['chooseLoginMethod']!;

  String get close =>
      _localizedValues[locale.languageCode]!['close']!;

  String get email =>
      _localizedValues[locale.languageCode]!['email']!;

  String get emailAndIdNumberAreAlready =>
      _localizedValues[locale.languageCode]!['emailAndIdNumberAreAlready']!;

  String get emailAndPhoneAreAlreadyTaken =>
      _localizedValues[locale.languageCode]!['emailAndPhoneAreAlreadyTaken']!;

  String get emailIsAlreadyTaken =>
      _localizedValues[locale.languageCode]!['emailIsAlreadyTaken']!;

  String get emailPhoneAndIdNumberAre =>
      _localizedValues[locale.languageCode]!['emailPhoneAndIdNumberAre']!;

  String get enjoyWithUsInEveryDestination =>
      _localizedValues[locale.languageCode]!['enjoyWithUsInEveryDestination']!;

  String get enterIqamaNumber =>
      _localizedValues[locale.languageCode]!['enterIqamaNumber']!;

  String get enterNationalId =>
      _localizedValues[locale.languageCode]!['enterNationalId']!;

  String get enterPassportNumber =>
      _localizedValues[locale.languageCode]!['enterPassportNumber']!;

  String get forgetPassword2 =>
      _localizedValues[locale.languageCode]!['forgetPassword2']!;

  String get fuel =>
      _localizedValues[locale.languageCode]!['fuel']!;

  String get fullUserName =>
      _localizedValues[locale.languageCode]!['fullUserName']!;

  String get id =>
      _localizedValues[locale.languageCode]!['id']!;

  String get idMustStartWith1 =>
      _localizedValues[locale.languageCode]!['idMustStartWith1']!;

  String get idNumber =>
      _localizedValues[locale.languageCode]!['idNumber']!;

  String get idNumberIsAlreadyTaken =>
      _localizedValues[locale.languageCode]!['idNumberIsAlreadyTaken']!;

  String get identityType =>
      _localizedValues[locale.languageCode]!['identityType']!;

  String get invalidIdNumber =>
      _localizedValues[locale.languageCode]!['invalidIdNumber']!;

  String get invalidIqamaNumber =>
      _localizedValues[locale.languageCode]!['invalidIqamaNumber']!;

  String get invalidPhoneNumber =>
      _localizedValues[locale.languageCode]!['invalidPhoneNumber']!;

  String get iqama =>
      _localizedValues[locale.languageCode]!['iqama']!;

  String get iqamaMustStartWith2 =>
      _localizedValues[locale.languageCode]!['iqamaMustStartWith2']!;

  String get kmDay =>
      _localizedValues[locale.languageCode]!['kmDay']!;

  String get letsBookCar =>
      _localizedValues[locale.languageCode]!['letsBookCar']!;

  String get logInNowAndBookYour =>
      _localizedValues[locale.languageCode]!['logInNowAndBookYour']!;

  String get makeYourTripEasier =>
      _localizedValues[locale.languageCode]!['makeYourTripEasier']!;

  String get manual =>
      _localizedValues[locale.languageCode]!['manual']!;

  String get maximumSpeed =>
      _localizedValues[locale.languageCode]!['maximumSpeed']!;

  String get mustBe10DigitsValueLength =>
      _localizedValues[locale.languageCode]!['mustBe10DigitsValueLength']!;

  String get mustBe3To15Letters =>
      _localizedValues[locale.languageCode]!['mustBe3To15Letters']!;

  String get mustBeAtLeast6Characters =>
      _localizedValues[locale.languageCode]!['mustBeAtLeast6Characters']!;

  String get mustContainOnlyLettersAndNumbers =>
      _localizedValues[locale.languageCode]!['mustContainOnlyLettersAndNumbers']!;

  String get myAccount =>
      _localizedValues[locale.languageCode]!['myAccount']!;

  String get nationalId =>
      _localizedValues[locale.languageCode]!['nationalId']!;

  String get numberOfSeats =>
      _localizedValues[locale.languageCode]!['numberOfSeats']!;

  String get openYourAccountNowAndBook =>
      _localizedValues[locale.languageCode]!['openYourAccountNowAndBook']!;

  String get outOfStock =>
      _localizedValues[locale.languageCode]!['outOfStock']!;

  String get passport =>
      _localizedValues[locale.languageCode]!['passport']!;

  String get passwordsDoNotMatch =>
      _localizedValues[locale.languageCode]!['passwordsDoNotMatch']!;

  String get phone =>
      _localizedValues[locale.languageCode]!['phone']!;

  String get phoneAndIdNumberAreAlready =>
      _localizedValues[locale.languageCode]!['phoneAndIdNumberAreAlready']!;

  String get phoneIsAlreadyTaken =>
      _localizedValues[locale.languageCode]!['phoneIsAlreadyTaken']!;

  String get phoneNumber =>
      _localizedValues[locale.languageCode]!['phoneNumber']!;

  String get pleaseEnsureAllFieldsAreFilled =>
      _localizedValues[locale.languageCode]!['pleaseEnsureAllFieldsAreFilled']!;

  String get pleaseEnterNumbersOnly =>
      _localizedValues[locale.languageCode]!['pleaseEnterNumbersOnly']!;

  String get pleaseEnterThePassportNumber =>
      _localizedValues[locale.languageCode]!['pleaseEnterThePassportNumber']!;

  String get receiveFromAirport =>
      _localizedValues[locale.languageCode]!['receiveFromAirport']!;

  String get registerFailedPleaseTryAgain =>
      _localizedValues[locale.languageCode]!['registerFailedPleaseTryAgain']!;

  String get seats =>
      _localizedValues[locale.languageCode]!['seats']!;

  String get stockStatusIsNotAvailableEnjoy =>
      _localizedValues[locale.languageCode]!['stockStatusIsNotAvailableEnjoy']!;

  String get thisFieldIsRequired =>
      _localizedValues[locale.languageCode]!['thisFieldIsRequired']!;

  String get transmission =>
      _localizedValues[locale.languageCode]!['transmission']!;

  String get welcome =>
      _localizedValues[locale.languageCode]!['welcome']!;

  String get welcome2 =>
      _localizedValues[locale.languageCode]!['welcome2']!;

  String get yes =>
      _localizedValues[locale.languageCode]!['yes']!;
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => [
    'en',
    'ar',
  ].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}