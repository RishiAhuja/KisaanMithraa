// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
            ? locale.languageCode
            : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Kisan Mitra`
  String get appTitle {
    return Intl.message(
      'Kisan Mitra',
      name: 'appTitle',
      desc: 'The title of the app',
      args: [],
    );
  }

  /// `Welcome back,`
  String get welcome {
    return Intl.message('Welcome back,', name: 'welcome', desc: '', args: []);
  }

  /// `Create Cooperative`
  String get createCooperative {
    return Intl.message(
      'Create Cooperative',
      name: 'createCooperative',
      desc: '',
      args: [],
    );
  }

  /// `Personal Information`
  String get personalInfo {
    return Intl.message(
      'Personal Information',
      name: 'personalInfo',
      desc: '',
      args: [],
    );
  }

  /// `Farm Details`
  String get farmDetails {
    return Intl.message(
      'Farm Details',
      name: 'farmDetails',
      desc: '',
      args: [],
    );
  }

  /// `Ask Mitra`
  String get askMitra {
    return Intl.message('Ask Mitra', name: 'askMitra', desc: '', args: []);
  }

  /// `Soil Type`
  String get soilType {
    return Intl.message('Soil Type', name: 'soilType', desc: '', args: []);
  }

  /// `Location`
  String get location {
    return Intl.message('Location', name: 'location', desc: '', args: []);
  }

  /// `Crops`
  String get crops {
    return Intl.message('Crops', name: 'crops', desc: '', args: []);
  }

  /// `Phone`
  String get phone {
    return Intl.message('Phone', name: 'phone', desc: '', args: []);
  }

  /// `Member since`
  String get memberSince {
    return Intl.message(
      'Member since',
      name: 'memberSince',
      desc: '',
      args: [],
    );
  }

  /// `Location not set`
  String get locationNotSet {
    return Intl.message(
      'Location not set',
      name: 'locationNotSet',
      desc: '',
      args: [],
    );
  }

  /// `No crops specified`
  String get noCrops {
    return Intl.message(
      'No crops specified',
      name: 'noCrops',
      desc: '',
      args: [],
    );
  }

  /// `Not specified`
  String get notSpecified {
    return Intl.message(
      'Not specified',
      name: 'notSpecified',
      desc: '',
      args: [],
    );
  }

  /// `Ask me anything about farming`
  String get askAnything {
    return Intl.message(
      'Ask me anything about farming',
      name: 'askAnything',
      desc: '',
      args: [],
    );
  }

  /// `Start Speaking`
  String get startSpeaking {
    return Intl.message(
      'Start Speaking',
      name: 'startSpeaking',
      desc: '',
      args: [],
    );
  }

  /// `Initializing...`
  String get initializing {
    return Intl.message(
      'Initializing...',
      name: 'initializing',
      desc: '',
      args: [],
    );
  }

  /// `Best crops for this season`
  String get bestCrops {
    return Intl.message(
      'Best crops for this season',
      name: 'bestCrops',
      desc: '',
      args: [],
    );
  }

  /// `What are the best crops to plant this season?`
  String get bestCropsQuestion {
    return Intl.message(
      'What are the best crops to plant this season?',
      name: 'bestCropsQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Pest control tips`
  String get pestControl {
    return Intl.message(
      'Pest control tips',
      name: 'pestControl',
      desc: '',
      args: [],
    );
  }

  /// `How can I deal with common pests?`
  String get pestControlQuestion {
    return Intl.message(
      'How can I deal with common pests?',
      name: 'pestControlQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Water conservation`
  String get waterConservation {
    return Intl.message(
      'Water conservation',
      name: 'waterConservation',
      desc: '',
      args: [],
    );
  }

  /// `How can I conserve water?`
  String get waterConservationQuestion {
    return Intl.message(
      'How can I conserve water?',
      name: 'waterConservationQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Organic farming`
  String get organicFarming {
    return Intl.message(
      'Organic farming',
      name: 'organicFarming',
      desc: '',
      args: [],
    );
  }

  /// `Tips for organic farming?`
  String get organicFarmingQuestion {
    return Intl.message(
      'Tips for organic farming?',
      name: 'organicFarmingQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Ask anything about farming...`
  String get askFarmingQuestion {
    return Intl.message(
      'Ask anything about farming...',
      name: 'askFarmingQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Speech recognition is initializing. Please wait...`
  String get speechInitializing {
    return Intl.message(
      'Speech recognition is initializing. Please wait...',
      name: 'speechInitializing',
      desc: '',
      args: [],
    );
  }

  /// `Recognized: "`
  String get recognized {
    return Intl.message(
      'Recognized: "',
      name: 'recognized',
      desc: '',
      args: [],
    );
  }

  /// `Speech recognition error: `
  String get speechError {
    return Intl.message(
      'Speech recognition error: ',
      name: 'speechError',
      desc: '',
      args: [],
    );
  }

  /// `Priority Alerts`
  String get priorityAlerts {
    return Intl.message(
      'Priority Alerts',
      name: 'priorityAlerts',
      desc: '',
      args: [],
    );
  }

  /// `View all`
  String get viewAll {
    return Intl.message('View all', name: 'viewAll', desc: '', args: []);
  }

  /// `Heavy rain expected in next 3 days, secure your wheat crop`
  String get heavyRainAlert {
    return Intl.message(
      'Heavy rain expected in next 3 days, secure your wheat crop',
      name: 'heavyRainAlert',
      desc: '',
      args: [],
    );
  }

  /// `View Tips`
  String get viewTips {
    return Intl.message('View Tips', name: 'viewTips', desc: '', args: []);
  }

  /// `Choose Your Language`
  String get chooseLanguage {
    return Intl.message(
      'Choose Your Language',
      name: 'chooseLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Community`
  String get community {
    return Intl.message('Community', name: 'community', desc: '', args: []);
  }

  /// `Farmers`
  String get farmers {
    return Intl.message('Farmers', name: 'farmers', desc: '', args: []);
  }

  /// `Cooperatives`
  String get cooperatives {
    return Intl.message(
      'Cooperatives',
      name: 'cooperatives',
      desc: '',
      args: [],
    );
  }

  /// `Search...`
  String get search {
    return Intl.message('Search...', name: 'search', desc: '', args: []);
  }

  /// `Contact Information`
  String get contactInformation {
    return Intl.message(
      'Contact Information',
      name: 'contactInformation',
      desc: '',
      args: [],
    );
  }

  /// `City`
  String get city {
    return Intl.message('City', name: 'city', desc: '', args: []);
  }

  /// `State`
  String get state {
    return Intl.message('State', name: 'state', desc: '', args: []);
  }

  /// `Farming Details`
  String get farmingDetails {
    return Intl.message(
      'Farming Details',
      name: 'farmingDetails',
      desc: '',
      args: [],
    );
  }

  /// `Message Farmer`
  String get messageUser {
    return Intl.message(
      'Message Farmer',
      name: 'messageUser',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get about {
    return Intl.message('About', name: 'about', desc: '', args: []);
  }

  /// `Total Members`
  String get totalMembers {
    return Intl.message(
      'Total Members',
      name: 'totalMembers',
      desc: '',
      args: [],
    );
  }

  /// `Admin`
  String get admin {
    return Intl.message('Admin', name: 'admin', desc: '', args: []);
  }

  /// `Join Cooperative`
  String get joinCooperative {
    return Intl.message(
      'Join Cooperative',
      name: 'joinCooperative',
      desc: '',
      args: [],
    );
  }

  /// `Coming Soon`
  String get comingSoon {
    return Intl.message('Coming Soon', name: 'comingSoon', desc: '', args: []);
  }

  /// `Messaging feature will be available soon!`
  String get messagingFeature {
    return Intl.message(
      'Messaging feature will be available soon!',
      name: 'messagingFeature',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `No notifications yet`
  String get noNotificationsYet {
    return Intl.message(
      'No notifications yet',
      name: 'noNotificationsYet',
      desc: '',
      args: [],
    );
  }

  /// `Create Listing`
  String get createListing {
    return Intl.message(
      'Create Listing',
      name: 'createListing',
      desc: '',
      args: [],
    );
  }

  /// `Listing Type`
  String get listingType {
    return Intl.message(
      'Listing Type',
      name: 'listingType',
      desc: '',
      args: [],
    );
  }

  /// `Transaction Type`
  String get transactionType {
    return Intl.message(
      'Transaction Type',
      name: 'transactionType',
      desc: '',
      args: [],
    );
  }

  /// `Title`
  String get title {
    return Intl.message('Title', name: 'title', desc: '', args: []);
  }

  /// `Description`
  String get description {
    return Intl.message('Description', name: 'description', desc: '', args: []);
  }

  /// `Quantity`
  String get quantity {
    return Intl.message('Quantity', name: 'quantity', desc: '', args: []);
  }

  /// `Unit`
  String get unit {
    return Intl.message('Unit', name: 'unit', desc: '', args: []);
  }

  /// `Price per unit (₹)`
  String get pricePerUnit {
    return Intl.message(
      'Price per unit (₹)',
      name: 'pricePerUnit',
      desc: '',
      args: [],
    );
  }

  /// `Availability`
  String get availability {
    return Intl.message(
      'Availability',
      name: 'availability',
      desc: '',
      args: [],
    );
  }

  /// `From`
  String get from {
    return Intl.message('From', name: 'from', desc: '', args: []);
  }

  /// `To`
  String get to {
    return Intl.message('To', name: 'to', desc: '', args: []);
  }

  /// `Select Date`
  String get selectDate {
    return Intl.message('Select Date', name: 'selectDate', desc: '', args: []);
  }

  /// `Required`
  String get required {
    return Intl.message('Required', name: 'required', desc: '', args: []);
  }

  /// `Invalid number`
  String get invalidNumber {
    return Intl.message(
      'Invalid number',
      name: 'invalidNumber',
      desc: '',
      args: [],
    );
  }

  /// `Invalid price`
  String get invalidPrice {
    return Intl.message(
      'Invalid price',
      name: 'invalidPrice',
      desc: '',
      args: [],
    );
  }

  /// `Create`
  String get create {
    return Intl.message('Create', name: 'create', desc: '', args: []);
  }

  /// `Creating...`
  String get creating {
    return Intl.message('Creating...', name: 'creating', desc: '', args: []);
  }

  /// `Start Your Cooperative`
  String get startYourCooperative {
    return Intl.message(
      'Start Your Cooperative',
      name: 'startYourCooperative',
      desc: '',
      args: [],
    );
  }

  /// `Create a community of farmers working together`
  String get createCommunity {
    return Intl.message(
      'Create a community of farmers working together',
      name: 'createCommunity',
      desc: '',
      args: [],
    );
  }

  /// `Cooperative Name`
  String get cooperativeName {
    return Intl.message(
      'Cooperative Name',
      name: 'cooperativeName',
      desc: '',
      args: [],
    );
  }

  /// `Enter cooperative name`
  String get enterCooperativeName {
    return Intl.message(
      'Enter cooperative name',
      name: 'enterCooperativeName',
      desc: '',
      args: [],
    );
  }

  /// `Describe your cooperative's mission and goals`
  String get describeCooperative {
    return Intl.message(
      'Describe your cooperative\'s mission and goals',
      name: 'describeCooperative',
      desc: '',
      args: [],
    );
  }

  /// `Select Members`
  String get selectMembers {
    return Intl.message(
      'Select Members',
      name: 'selectMembers',
      desc: '',
      args: [],
    );
  }

  /// `Optional`
  String get optional {
    return Intl.message('Optional', name: 'optional', desc: '', args: []);
  }

  /// `Cooperative Banner`
  String get cooperativeBanner {
    return Intl.message(
      'Cooperative Banner',
      name: 'cooperativeBanner',
      desc: '',
      args: [],
    );
  }

  /// `Add Banner`
  String get addBanner {
    return Intl.message('Add Banner', name: 'addBanner', desc: '', args: []);
  }

  /// `Upload a banner for your cooperative`
  String get uploadBanner {
    return Intl.message(
      'Upload a banner for your cooperative',
      name: 'uploadBanner',
      desc: '',
      args: [],
    );
  }

  /// `Select Image Source`
  String get selectImageSource {
    return Intl.message(
      'Select Image Source',
      name: 'selectImageSource',
      desc: '',
      args: [],
    );
  }

  /// `Camera`
  String get camera {
    return Intl.message('Camera', name: 'camera', desc: '', args: []);
  }

  /// `Gallery`
  String get gallery {
    return Intl.message('Gallery', name: 'gallery', desc: '', args: []);
  }

  /// `Listing Details`
  String get listingDetails {
    return Intl.message(
      'Listing Details',
      name: 'listingDetails',
      desc: '',
      args: [],
    );
  }

  /// `My Listing Details`
  String get myListingDetails {
    return Intl.message(
      'My Listing Details',
      name: 'myListingDetails',
      desc: '',
      args: [],
    );
  }

  /// `Offers`
  String get offers {
    return Intl.message('Offers', name: 'offers', desc: '', args: []);
  }

  /// `No offers yet`
  String get noOffersYet {
    return Intl.message(
      'No offers yet',
      name: 'noOffersYet',
      desc: '',
      args: [],
    );
  }

  /// `Make Offer`
  String get makeOffer {
    return Intl.message('Make Offer', name: 'makeOffer', desc: '', args: []);
  }

  /// `Submit`
  String get submit {
    return Intl.message('Submit', name: 'submit', desc: '', args: []);
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Cancel Listing`
  String get cancelListing {
    return Intl.message(
      'Cancel Listing',
      name: 'cancelListing',
      desc: '',
      args: [],
    );
  }

  /// `Delete Listing`
  String get deleteListing {
    return Intl.message(
      'Delete Listing',
      name: 'deleteListing',
      desc: '',
      args: [],
    );
  }

  /// `Offer submitted successfully`
  String get offerSubmittedSuccess {
    return Intl.message(
      'Offer submitted successfully',
      name: 'offerSubmittedSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Failed to submit offer`
  String get failedToSubmitOffer {
    return Intl.message(
      'Failed to submit offer',
      name: 'failedToSubmitOffer',
      desc: '',
      args: [],
    );
  }

  /// `Error loading offers`
  String get errorLoadingOffers {
    return Intl.message(
      'Error loading offers',
      name: 'errorLoadingOffers',
      desc: '',
      args: [],
    );
  }

  /// `Please enter quantity`
  String get pleaseEnterQuantity {
    return Intl.message(
      'Please enter quantity',
      name: 'pleaseEnterQuantity',
      desc: '',
      args: [],
    );
  }

  /// `Please enter valid quantity`
  String get pleaseEnterValidQuantity {
    return Intl.message(
      'Please enter valid quantity',
      name: 'pleaseEnterValidQuantity',
      desc: '',
      args: [],
    );
  }

  /// `Cannot exceed required quantity`
  String get cannotExceedQuantity {
    return Intl.message(
      'Cannot exceed required quantity',
      name: 'cannotExceedQuantity',
      desc: '',
      args: [],
    );
  }

  /// `Please enter price`
  String get pleaseEnterPrice {
    return Intl.message(
      'Please enter price',
      name: 'pleaseEnterPrice',
      desc: '',
      args: [],
    );
  }

  /// `Please enter valid price`
  String get pleaseEnterValidPrice {
    return Intl.message(
      'Please enter valid price',
      name: 'pleaseEnterValidPrice',
      desc: '',
      args: [],
    );
  }

  /// `Posted by {name}`
  String postedBy(Object name) {
    return Intl.message(
      'Posted by $name',
      name: 'postedBy',
      desc: '',
      args: [name],
    );
  }

  /// `Posted on {date}`
  String postedOn(Object date) {
    return Intl.message(
      'Posted on $date',
      name: 'postedOn',
      desc: '',
      args: [date],
    );
  }

  /// `{quantity} {unit}`
  String quantityValue(Object quantity, Object unit) {
    return Intl.message(
      '$quantity $unit',
      name: 'quantityValue',
      desc: '',
      args: [quantity, unit],
    );
  }

  /// `₹{price} per {unit}`
  String priceValue(Object price, Object unit) {
    return Intl.message(
      '₹$price per $unit',
      name: 'priceValue',
      desc: '',
      args: [price, unit],
    );
  }

  /// `Available from`
  String get availableFrom {
    return Intl.message(
      'Available from',
      name: 'availableFrom',
      desc: '',
      args: [],
    );
  }

  /// `Available until`
  String get availableUntil {
    return Intl.message(
      'Available until',
      name: 'availableUntil',
      desc: '',
      args: [],
    );
  }

  /// `Chat`
  String get chat {
    return Intl.message('Chat', name: 'chat', desc: '', args: []);
  }

  /// `Accept`
  String get accept {
    return Intl.message('Accept', name: 'accept', desc: '', args: []);
  }

  /// `Offer Status`
  String get offerStatus {
    return Intl.message(
      'Offer Status',
      name: 'offerStatus',
      desc: '',
      args: [],
    );
  }

  /// `View on Map`
  String get viewOnMap {
    return Intl.message('View on Map', name: 'viewOnMap', desc: '', args: []);
  }

  /// `Offers ({count})`
  String offerCount(Object count) {
    return Intl.message(
      'Offers ($count)',
      name: 'offerCount',
      desc: '',
      args: [count],
    );
  }

  /// `Quantity: {quantity} {unit}`
  String quantityWithUnit(Object quantity, Object unit) {
    return Intl.message(
      'Quantity: $quantity $unit',
      name: 'quantityWithUnit',
      desc: '',
      args: [quantity, unit],
    );
  }

  /// `₹{price}/{unit}`
  String pricePerUnitWithUnit(Object price, Object unit) {
    return Intl.message(
      '₹$price/$unit',
      name: 'pricePerUnitWithUnit',
      desc: '',
      args: [price, unit],
    );
  }

  /// `Cannot accept offer`
  String get cannotAcceptOffer {
    return Intl.message(
      'Cannot accept offer',
      name: 'cannotAcceptOffer',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message('Error', name: 'error', desc: '', args: []);
  }

  /// `Fetching your local weather...`
  String get weatherLoading {
    return Intl.message(
      'Fetching your local weather...',
      name: 'weatherLoading',
      desc: '',
      args: [],
    );
  }

  /// `Weather update unavailable`
  String get weatherUnavailable {
    return Intl.message(
      'Weather update unavailable',
      name: 'weatherUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `We recommend checking crop conditions manually today`
  String get weatherCheckManually {
    return Intl.message(
      'We recommend checking crop conditions manually today',
      name: 'weatherCheckManually',
      desc: '',
      args: [],
    );
  }

  /// `Good morning`
  String get goodMorning {
    return Intl.message(
      'Good morning',
      name: 'goodMorning',
      desc: '',
      args: [],
    );
  }

  /// `Good afternoon`
  String get goodAfternoon {
    return Intl.message(
      'Good afternoon',
      name: 'goodAfternoon',
      desc: '',
      args: [],
    );
  }

  /// `Good evening`
  String get goodEvening {
    return Intl.message(
      'Good evening',
      name: 'goodEvening',
      desc: '',
      args: [],
    );
  }

  /// `Hope your weekend on the farm is going well`
  String get weekendFarmWish {
    return Intl.message(
      'Hope your weekend on the farm is going well',
      name: 'weekendFarmWish',
      desc: '',
      args: [],
    );
  }

  /// `Starting a fresh month on your farm`
  String get startingMonth {
    return Intl.message(
      'Starting a fresh month on your farm',
      name: 'startingMonth',
      desc: '',
      args: [],
    );
  }

  /// `Wrapping up the month on your farm`
  String get endingMonth {
    return Intl.message(
      'Wrapping up the month on your farm',
      name: 'endingMonth',
      desc: '',
      args: [],
    );
  }

  /// `Welcome back to your farm today`
  String get welcomeBack {
    return Intl.message(
      'Welcome back to your farm today',
      name: 'welcomeBack',
      desc: '',
      args: [],
    );
  }

  /// `Market Prices`
  String get marketPrices {
    return Intl.message(
      'Market Prices',
      name: 'marketPrices',
      desc: '',
      args: [],
    );
  }

  /// `Your Watchlist`
  String get yourWatchlist {
    return Intl.message(
      'Your Watchlist',
      name: 'yourWatchlist',
      desc: '',
      args: [],
    );
  }

  /// `See all`
  String get seeAll {
    return Intl.message('See all', name: 'seeAll', desc: '', args: []);
  }

  /// `Showing cached prices`
  String get showingCachedPrices {
    return Intl.message(
      'Showing cached prices',
      name: 'showingCachedPrices',
      desc: '',
      args: [],
    );
  }

  /// `Your watchlist is empty`
  String get emptyWatchlist {
    return Intl.message(
      'Your watchlist is empty',
      name: 'emptyWatchlist',
      desc: '',
      args: [],
    );
  }

  /// `Add crops to your watchlist to see them here`
  String get addToWatchlistHint {
    return Intl.message(
      'Add crops to your watchlist to see them here',
      name: 'addToWatchlistHint',
      desc: '',
      args: [],
    );
  }

  /// `Add to Watchlist`
  String get addToWatchlist {
    return Intl.message(
      'Add to Watchlist',
      name: 'addToWatchlist',
      desc: '',
      args: [],
    );
  }

  /// `Unable to load market prices`
  String get unableToLoadPrices {
    return Intl.message(
      'Unable to load market prices',
      name: 'unableToLoadPrices',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get retry {
    return Intl.message('Retry', name: 'retry', desc: '', args: []);
  }

  /// `Quick Access`
  String get quickAccess {
    return Intl.message(
      'Quick Access',
      name: 'quickAccess',
      desc: '',
      args: [],
    );
  }

  /// `Farmer Groups`
  String get farmerGroups {
    return Intl.message(
      'Farmer Groups',
      name: 'farmerGroups',
      desc: '',
      args: [],
    );
  }

  /// `Podcasts`
  String get podcasts {
    return Intl.message('Podcasts', name: 'podcasts', desc: '', args: []);
  }

  /// `Transport`
  String get transport {
    return Intl.message('Transport', name: 'transport', desc: '', args: []);
  }

  /// `Loans`
  String get loans {
    return Intl.message('Loans', name: 'loans', desc: '', args: []);
  }

  /// `Weather`
  String get weather {
    return Intl.message('Weather', name: 'weather', desc: '', args: []);
  }

  /// `Help Desk`
  String get helpDesk {
    return Intl.message('Help Desk', name: 'helpDesk', desc: '', args: []);
  }

  /// `AI Farming Tips`
  String get aiFarmingTips {
    return Intl.message(
      'AI Farming Tips',
      name: 'aiFarmingTips',
      desc: '',
      args: [],
    );
  }

  /// `Refresh`
  String get refresh {
    return Intl.message('Refresh', name: 'refresh', desc: '', args: []);
  }

  /// `Getting farming tips...`
  String get gettingTips {
    return Intl.message(
      'Getting farming tips...',
      name: 'gettingTips',
      desc: '',
      args: [],
    );
  }

  /// `No tips available. Tap refresh to try again.`
  String get noTipsAvailable {
    return Intl.message(
      'No tips available. Tap refresh to try again.',
      name: 'noTipsAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Humidity`
  String get weatherHumidity {
    return Intl.message(
      'Humidity',
      name: 'weatherHumidity',
      desc: '',
      args: [],
    );
  }

  /// `Wind`
  String get weatherWind {
    return Intl.message('Wind', name: 'weatherWind', desc: '', args: []);
  }

  /// `km/h`
  String get weatherWindUnit {
    return Intl.message('km/h', name: 'weatherWindUnit', desc: '', args: []);
  }

  /// `Pressure`
  String get weatherPressure {
    return Intl.message(
      'Pressure',
      name: 'weatherPressure',
      desc: '',
      args: [],
    );
  }

  /// `hPa`
  String get weatherPressureUnit {
    return Intl.message('hPa', name: 'weatherPressureUnit', desc: '', args: []);
  }

  /// `All Services`
  String get allServices {
    return Intl.message(
      'All Services',
      name: 'allServices',
      desc: '',
      args: [],
    );
  }

  /// `Connect with farmers in your area`
  String get farmerGroupsDesc {
    return Intl.message(
      'Connect with farmers in your area',
      name: 'farmerGroupsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Listen to farming tips and news`
  String get podcastsDesc {
    return Intl.message(
      'Listen to farming tips and news',
      name: 'podcastsDesc',
      desc: '',
      args: [],
    );
  }

  /// `Find transport for your produce`
  String get transportDesc {
    return Intl.message(
      'Find transport for your produce',
      name: 'transportDesc',
      desc: '',
      args: [],
    );
  }

  /// `Check local weather forecasts`
  String get weatherDesc {
    return Intl.message(
      'Check local weather forecasts',
      name: 'weatherDesc',
      desc: '',
      args: [],
    );
  }

  /// `Best to stay indoors today`
  String get weatherPhraseRain {
    return Intl.message(
      'Best to stay indoors today',
      name: 'weatherPhraseRain',
      desc: '',
      args: [],
    );
  }

  /// `Moderate day for fieldwork`
  String get weatherPhraseCloud {
    return Intl.message(
      'Moderate day for fieldwork',
      name: 'weatherPhraseCloud',
      desc: '',
      args: [],
    );
  }

  /// `Stay hydrated in the fields`
  String get weatherPhraseClearHot {
    return Intl.message(
      'Stay hydrated in the fields',
      name: 'weatherPhraseClearHot',
      desc: '',
      args: [],
    );
  }

  /// `Perfect day for outdoor work`
  String get weatherPhraseClear {
    return Intl.message(
      'Perfect day for outdoor work',
      name: 'weatherPhraseClear',
      desc: '',
      args: [],
    );
  }

  /// `Protect your crops today`
  String get weatherPhraseSnow {
    return Intl.message(
      'Protect your crops today',
      name: 'weatherPhraseSnow',
      desc: '',
      args: [],
    );
  }

  /// `Quite cold for crop growth`
  String get weatherPhraseCold {
    return Intl.message(
      'Quite cold for crop growth',
      name: 'weatherPhraseCold',
      desc: '',
      args: [],
    );
  }

  /// `Watch for heat stress on crops`
  String get weatherPhraseHot {
    return Intl.message(
      'Watch for heat stress on crops',
      name: 'weatherPhraseHot',
      desc: '',
      args: [],
    );
  }

  /// `Good conditions for farming`
  String get weatherPhraseDefault {
    return Intl.message(
      'Good conditions for farming',
      name: 'weatherPhraseDefault',
      desc: '',
      args: [],
    );
  }

  /// `Kisaan Assistant`
  String get chatbotTitle {
    return Intl.message(
      'Kisaan Assistant',
      name: 'chatbotTitle',
      desc: 'The title of the chatbot screen',
      args: [],
    );
  }

  /// `Your Farming Assistant`
  String get farmingAssistant {
    return Intl.message(
      'Your Farming Assistant',
      name: 'farmingAssistant',
      desc: 'Title shown on the empty chat screen',
      args: [],
    );
  }

  /// `Reset Conversation`
  String get resetConversation {
    return Intl.message(
      'Reset Conversation',
      name: 'resetConversation',
      desc: 'Button tooltip to reset the conversation',
      args: [],
    );
  }

  /// `Scroll to bottom`
  String get scrollToBottom {
    return Intl.message(
      'Scroll to bottom',
      name: 'scrollToBottom',
      desc: 'Tooltip for the scroll to bottom button',
      args: [],
    );
  }

  /// `Try asking:`
  String get suggestedQuestions {
    return Intl.message(
      'Try asking:',
      name: 'suggestedQuestions',
      desc: 'Header for suggested questions section',
      args: [],
    );
  }

  /// `Transport Services`
  String get transportServices {
    return Intl.message(
      'Transport Services',
      name: 'transportServices',
      desc: 'Label for transport services in navigation',
      args: [],
    );
  }

  /// `Weather Details`
  String get weatherDetails {
    return Intl.message(
      'Weather Details',
      name: 'weatherDetails',
      desc: 'Label for detailed weather in navigation',
      args: [],
    );
  }

  /// `Detailed weather information`
  String get weatherDetailsDesc {
    return Intl.message(
      'Detailed weather information',
      name: 'weatherDetailsDesc',
      desc: 'Description for weather details',
      args: [],
    );
  }

  /// `Related Content:`
  String get relatedContent {
    return Intl.message(
      'Related Content:',
      name: 'relatedContent',
      desc: 'Header for related content section',
      args: [],
    );
  }

  /// `Listen to our Podcast`
  String get listenPodcast {
    return Intl.message(
      'Listen to our Podcast',
      name: 'listenPodcast',
      desc: 'Label for podcast navigation',
      args: [],
    );
  }

  /// `Join Discussion`
  String get joinDiscussion {
    return Intl.message(
      'Join Discussion',
      name: 'joinDiscussion',
      desc: 'Label for community discussion navigation',
      args: [],
    );
  }

  /// `Go to Marketplace`
  String get goToMarketplace {
    return Intl.message(
      'Go to Marketplace',
      name: 'goToMarketplace',
      desc: 'Label for marketplace navigation',
      args: [],
    );
  }

  /// `Explore Resources`
  String get exploreResources {
    return Intl.message(
      'Explore Resources',
      name: 'exploreResources',
      desc: 'Label for resources navigation',
      args: [],
    );
  }

  /// `Check Weather`
  String get checkWeather {
    return Intl.message(
      'Check Weather',
      name: 'checkWeather',
      desc: 'Label for weather navigation',
      args: [],
    );
  }

  /// `Learn More`
  String get learnMore {
    return Intl.message(
      'Learn More',
      name: 'learnMore',
      desc: 'Default label for navigation',
      args: [],
    );
  }

  /// `Connect with other farmers`
  String get communityDesc {
    return Intl.message(
      'Connect with other farmers',
      name: 'communityDesc',
      desc: 'Description for community feature',
      args: [],
    );
  }

  /// `Buy and sell farm products`
  String get marketplaceDesc {
    return Intl.message(
      'Buy and sell farm products',
      name: 'marketplaceDesc',
      desc: 'Description for marketplace feature',
      args: [],
    );
  }

  /// `Farming guides and resources`
  String get resourcesDesc {
    return Intl.message(
      'Farming guides and resources',
      name: 'resourcesDesc',
      desc: 'Description for resources feature',
      args: [],
    );
  }

  /// `Related information`
  String get relatedInfoDesc {
    return Intl.message(
      'Related information',
      name: 'relatedInfoDesc',
      desc: 'Description for general related information',
      args: [],
    );
  }

  /// `Agri Help`
  String get agriHelp {
    return Intl.message('Agri Help', name: 'agriHelp', desc: '', args: []);
  }

  /// `Emergency Contacts`
  String get emergencyContacts {
    return Intl.message(
      'Emergency Contacts',
      name: 'emergencyContacts',
      desc: '',
      args: [],
    );
  }

  /// `Frequently Asked Questions`
  String get frequentlyAskedQuestions {
    return Intl.message(
      'Frequently Asked Questions',
      name: 'frequentlyAskedQuestions',
      desc: '',
      args: [],
    );
  }

  /// `Call`
  String get call {
    return Intl.message('Call', name: 'call', desc: '', args: []);
  }

  /// `Kisan Call Center`
  String get kisanCallCenter {
    return Intl.message(
      'Kisan Call Center',
      name: 'kisanCallCenter',
      desc: '',
      args: [],
    );
  }

  /// `24x7 helpline for farmers' queries on agriculture and allied sectors`
  String get kisanCallCenterDesc {
    return Intl.message(
      '24x7 helpline for farmers\' queries on agriculture and allied sectors',
      name: 'kisanCallCenterDesc',
      desc: '',
      args: [],
    );
  }

  /// `Crop Insurance Helpline`
  String get agriInsuranceHelpline {
    return Intl.message(
      'Crop Insurance Helpline',
      name: 'agriInsuranceHelpline',
      desc: '',
      args: [],
    );
  }

  /// `Get help with crop insurance claims and information`
  String get agriInsuranceDesc {
    return Intl.message(
      'Get help with crop insurance claims and information',
      name: 'agriInsuranceDesc',
      desc: '',
      args: [],
    );
  }

  /// `Plant Protection Helpline`
  String get plantProtectionHelpline {
    return Intl.message(
      'Plant Protection Helpline',
      name: 'plantProtectionHelpline',
      desc: '',
      args: [],
    );
  }

  /// `Expert advice on pest and disease management`
  String get plantProtectionDesc {
    return Intl.message(
      'Expert advice on pest and disease management',
      name: 'plantProtectionDesc',
      desc: '',
      args: [],
    );
  }

  /// `Seed Helpline`
  String get seedHelpline {
    return Intl.message(
      'Seed Helpline',
      name: 'seedHelpline',
      desc: '',
      args: [],
    );
  }

  /// `Information about quality seeds and seed-related issues`
  String get seedHelplineDesc {
    return Intl.message(
      'Information about quality seeds and seed-related issues',
      name: 'seedHelplineDesc',
      desc: '',
      args: [],
    );
  }

  /// `How can I apply for agricultural subsidies?`
  String get faqSubsidyQuestion {
    return Intl.message(
      'How can I apply for agricultural subsidies?',
      name: 'faqSubsidyQuestion',
      desc: '',
      args: [],
    );
  }

  /// `To apply for agricultural subsidies, register with your local agriculture office with your land documents, Aadhaar card, and bank account details. You can also apply online through the PM-KISAN portal or your state's agriculture department website. Eligibility varies by scheme.`
  String get faqSubsidyAnswer {
    return Intl.message(
      'To apply for agricultural subsidies, register with your local agriculture office with your land documents, Aadhaar card, and bank account details. You can also apply online through the PM-KISAN portal or your state\'s agriculture department website. Eligibility varies by scheme.',
      name: 'faqSubsidyAnswer',
      desc: '',
      args: [],
    );
  }

  /// `What are organic methods to control common pests?`
  String get faqPestControlQuestion {
    return Intl.message(
      'What are organic methods to control common pests?',
      name: 'faqPestControlQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Effective organic pest control methods include crop rotation, companion planting, and using neem oil spray. You can also introduce beneficial insects like ladybugs, use sticky traps, or apply garlic-chili spray. For specific pests, contact your local agriculture extension office.`
  String get faqPestControlAnswer {
    return Intl.message(
      'Effective organic pest control methods include crop rotation, companion planting, and using neem oil spray. You can also introduce beneficial insects like ladybugs, use sticky traps, or apply garlic-chili spray. For specific pests, contact your local agriculture extension office.',
      name: 'faqPestControlAnswer',
      desc: '',
      args: [],
    );
  }

  /// `How can I improve my soil health naturally?`
  String get faqSoilHealthQuestion {
    return Intl.message(
      'How can I improve my soil health naturally?',
      name: 'faqSoilHealthQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Improve soil health by adding organic matter like compost and farmyard manure, practicing crop rotation with legumes, using green manures, minimizing tillage, and maintaining proper drainage. Regular soil testing can help identify specific nutrient deficiencies to address.`
  String get faqSoilHealthAnswer {
    return Intl.message(
      'Improve soil health by adding organic matter like compost and farmyard manure, practicing crop rotation with legumes, using green manures, minimizing tillage, and maintaining proper drainage. Regular soil testing can help identify specific nutrient deficiencies to address.',
      name: 'faqSoilHealthAnswer',
      desc: '',
      args: [],
    );
  }

  /// `How can I protect crops during extreme weather?`
  String get faqWeatherImpactQuestion {
    return Intl.message(
      'How can I protect crops during extreme weather?',
      name: 'faqWeatherImpactQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Protect crops during extreme weather by using windbreaks, shade cloths, and mulching. For drought, implement drip irrigation and moisture retention practices. For heavy rains, ensure proper drainage and use raised beds. Consider weather-resistant crop varieties and check weather alerts regularly.`
  String get faqWeatherImpactAnswer {
    return Intl.message(
      'Protect crops during extreme weather by using windbreaks, shade cloths, and mulching. For drought, implement drip irrigation and moisture retention practices. For heavy rains, ensure proper drainage and use raised beds. Consider weather-resistant crop varieties and check weather alerts regularly.',
      name: 'faqWeatherImpactAnswer',
      desc: '',
      args: [],
    );
  }

  /// `How does the crop insurance scheme work?`
  String get faqCropInsuranceQuestion {
    return Intl.message(
      'How does the crop insurance scheme work?',
      name: 'faqCropInsuranceQuestion',
      desc: '',
      args: [],
    );
  }

  /// `The Pradhan Mantri Fasal Bima Yojana (PMFBY) provides financial support to farmers suffering crop loss. Premium rates are 2% for kharif crops, 1.5% for rabi crops, and 5% for commercial crops. Register at your bank or Common Service Centre with land records and premium payment. Claims are assessed based on crop cutting experiments.`
  String get faqCropInsuranceAnswer {
    return Intl.message(
      'The Pradhan Mantri Fasal Bima Yojana (PMFBY) provides financial support to farmers suffering crop loss. Premium rates are 2% for kharif crops, 1.5% for rabi crops, and 5% for commercial crops. Register at your bank or Common Service Centre with land records and premium payment. Claims are assessed based on crop cutting experiments.',
      name: 'faqCropInsuranceAnswer',
      desc: '',
      args: [],
    );
  }

  /// `Loading your profile...`
  String get loadingProfile {
    return Intl.message(
      'Loading your profile...',
      name: 'loadingProfile',
      desc: '',
      args: [],
    );
  }

  /// `Could not load profile`
  String get couldNotLoadProfile {
    return Intl.message(
      'Could not load profile',
      name: 'couldNotLoadProfile',
      desc: '',
      args: [],
    );
  }

  /// `Please try again`
  String get pleaseRetryAgain {
    return Intl.message(
      'Please try again',
      name: 'pleaseRetryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Apply Now`
  String get applyNow {
    return Intl.message('Apply Now', name: 'applyNow', desc: '', args: []);
  }

  /// `No podcasts available`
  String get noPodcastsAvailable {
    return Intl.message(
      'No podcasts available',
      name: 'noPodcastsAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Check back later for new farming podcasts`
  String get checkBackLater {
    return Intl.message(
      'Check back later for new farming podcasts',
      name: 'checkBackLater',
      desc: '',
      args: [],
    );
  }

  /// `Popular Podcasts`
  String get popularPodcasts {
    return Intl.message(
      'Popular Podcasts',
      name: 'popularPodcasts',
      desc: '',
      args: [],
    );
  }

  /// `New Releases`
  String get newReleases {
    return Intl.message(
      'New Releases',
      name: 'newReleases',
      desc: '',
      args: [],
    );
  }

  /// `Featured`
  String get featured {
    return Intl.message('Featured', name: 'featured', desc: '', args: []);
  }

  /// `Debug Mode`
  String get debugMode {
    return Intl.message('Debug Mode', name: 'debugMode', desc: '', args: []);
  }

  /// `My Cooperatives`
  String get myCooperatives {
    return Intl.message(
      'My Cooperatives',
      name: 'myCooperatives',
      desc: '',
      args: [],
    );
  }

  /// `Suggested Nearby`
  String get suggestedNearby {
    return Intl.message(
      'Suggested Nearby',
      name: 'suggestedNearby',
      desc: '',
      args: [],
    );
  }

  /// `Create New`
  String get createNew {
    return Intl.message('Create New', name: 'createNew', desc: '', args: []);
  }

  /// `Search Cooperatives`
  String get searchCooperatives {
    return Intl.message(
      'Search Cooperatives',
      name: 'searchCooperatives',
      desc: '',
      args: [],
    );
  }

  /// `Loading your cooperatives...`
  String get loadingCooperatives {
    return Intl.message(
      'Loading your cooperatives...',
      name: 'loadingCooperatives',
      desc: '',
      args: [],
    );
  }

  /// `You haven't joined any cooperatives yet`
  String get noCooperativesJoined {
    return Intl.message(
      'You haven\'t joined any cooperatives yet',
      name: 'noCooperativesJoined',
      desc: '',
      args: [],
    );
  }

  /// `Check out suggested cooperatives near you`
  String get checkOutSuggested {
    return Intl.message(
      'Check out suggested cooperatives near you',
      name: 'checkOutSuggested',
      desc: '',
      args: [],
    );
  }

  /// `Show Nearby Cooperatives`
  String get showNearbyCooperatives {
    return Intl.message(
      'Show Nearby Cooperatives',
      name: 'showNearbyCooperatives',
      desc: '',
      args: [],
    );
  }

  /// `Explore Nearby Cooperatives`
  String get exploreNearbyCooperatives {
    return Intl.message(
      'Explore Nearby Cooperatives',
      name: 'exploreNearbyCooperatives',
      desc: '',
      args: [],
    );
  }

  /// `Tap on markers to see cooperative details`
  String get tapOnMarkers {
    return Intl.message(
      'Tap on markers to see cooperative details',
      name: 'tapOnMarkers',
      desc: '',
      args: [],
    );
  }

  /// `Cooperatives Near You`
  String get cooperativesNearYou {
    return Intl.message(
      'Cooperatives Near You',
      name: 'cooperativesNearYou',
      desc: '',
      args: [],
    );
  }

  /// `No cooperatives found`
  String get noCooperativesFound {
    return Intl.message(
      'No cooperatives found',
      name: 'noCooperativesFound',
      desc: '',
      args: [],
    );
  }

  /// `No nearby cooperatives found`
  String get noNearbyCooperativesFound {
    return Intl.message(
      'No nearby cooperatives found',
      name: 'noNearbyCooperativesFound',
      desc: '',
      args: [],
    );
  }

  /// `Try a different search term`
  String get tryDifferentSearchTerm {
    return Intl.message(
      'Try a different search term',
      name: 'tryDifferentSearchTerm',
      desc: '',
      args: [],
    );
  }

  /// `There are no cooperatives within 5km of your current location`
  String get noCooperativesInRange {
    return Intl.message(
      'There are no cooperatives within 5km of your current location',
      name: 'noCooperativesInRange',
      desc: '',
      args: [],
    );
  }

  /// `Name is required`
  String get nameIsRequired {
    return Intl.message(
      'Name is required',
      name: 'nameIsRequired',
      desc: '',
      args: [],
    );
  }

  /// `Description is required`
  String get descriptionIsRequired {
    return Intl.message(
      'Description is required',
      name: 'descriptionIsRequired',
      desc: '',
      args: [],
    );
  }

  /// `Create Cooperative`
  String get createCooperativeAction {
    return Intl.message(
      'Create Cooperative',
      name: 'createCooperativeAction',
      desc: '',
      args: [],
    );
  }

  /// `Upload a banner for your cooperative`
  String get uploadBannerDescription {
    return Intl.message(
      'Upload a banner for your cooperative',
      name: 'uploadBannerDescription',
      desc: '',
      args: [],
    );
  }

  /// `Create a community of farmers working together`
  String get createCommunityDescription {
    return Intl.message(
      'Create a community of farmers working together',
      name: 'createCommunityDescription',
      desc: '',
      args: [],
    );
  }

  /// `Search cooperatives by name or location`
  String get searchCooperativesByLocation {
    return Intl.message(
      'Search cooperatives by name or location',
      name: 'searchCooperativesByLocation',
      desc: '',
      args: [],
    );
  }

  /// `Searching...`
  String get searching {
    return Intl.message('Searching...', name: 'searching', desc: '', args: []);
  }

  /// `Found {count} cooperatives`
  String foundCooperatives(Object count) {
    return Intl.message(
      'Found $count cooperatives',
      name: 'foundCooperatives',
      desc: '',
      args: [count],
    );
  }

  /// `{count} Nearby Cooperatives`
  String nearbyCooperatives(Object count) {
    return Intl.message(
      '$count Nearby Cooperatives',
      name: 'nearbyCooperatives',
      desc: '',
      args: [count],
    );
  }

  /// `5 km radius`
  String get fiveKmRadius {
    return Intl.message(
      '5 km radius',
      name: 'fiveKmRadius',
      desc: '',
      args: [],
    );
  }

  /// `Getting location...`
  String get gettingLocation {
    return Intl.message(
      'Getting location...',
      name: 'gettingLocation',
      desc: '',
      args: [],
    );
  }

  /// `Manage`
  String get manage {
    return Intl.message('Manage', name: 'manage', desc: '', args: []);
  }

  /// `Details`
  String get details {
    return Intl.message('Details', name: 'details', desc: '', args: []);
  }

  /// `Join`
  String get join {
    return Intl.message('Join', name: 'join', desc: '', args: []);
  }

  /// `Found {count} cooperatives`
  String foundCount(Object count) {
    return Intl.message(
      'Found $count cooperatives',
      name: 'foundCount',
      desc: '',
      args: [count],
    );
  }

  /// `{distance} km`
  String kmAway(Object distance) {
    return Intl.message(
      '$distance km',
      name: 'kmAway',
      desc: '',
      args: [distance],
    );
  }

  /// `members`
  String get members {
    return Intl.message('members', name: 'members', desc: '', args: []);
  }

  /// `member`
  String get member {
    return Intl.message('member', name: 'member', desc: '', args: []);
  }

  /// `Unverified`
  String get unverified {
    return Intl.message('Unverified', name: 'unverified', desc: '', args: []);
  }

  /// `Sorry, I encountered an error. Please try again.`
  String get genericError {
    return Intl.message(
      'Sorry, I encountered an error. Please try again.',
      name: 'genericError',
      desc: '',
      args: [],
    );
  }

  /// `Speech recognition error`
  String get speechRecognitionError {
    return Intl.message(
      'Speech recognition error',
      name: 'speechRecognitionError',
      desc: '',
      args: [],
    );
  }

  /// `User not found`
  String get userNotFound {
    return Intl.message(
      'User not found',
      name: 'userNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Network connection error`
  String get networkError {
    return Intl.message(
      'Network connection error',
      name: 'networkError',
      desc: '',
      args: [],
    );
  }

  /// `Request timed out`
  String get timeoutError {
    return Intl.message(
      'Request timed out',
      name: 'timeoutError',
      desc: '',
      args: [],
    );
  }

  /// `An unknown error occurred`
  String get unknownError {
    return Intl.message(
      'An unknown error occurred',
      name: 'unknownError',
      desc: '',
      args: [],
    );
  }

  /// `Permission denied`
  String get permissionDenied {
    return Intl.message(
      'Permission denied',
      name: 'permissionDenied',
      desc: '',
      args: [],
    );
  }

  /// `Service temporarily unavailable`
  String get serviceUnavailable {
    return Intl.message(
      'Service temporarily unavailable',
      name: 'serviceUnavailable',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'hi'),
      Locale.fromSubtags(languageCode: 'pa'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
