import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//colors
const Color kPrimaryColor = Color(0xFF345FB4);
const Color kSecondaryColor = Color(0xFF6789CA);
const Color kTextBlackColor = Color(0xFF313131);
const Color kTextWhiteColor = Color(0xFFFFFFFF);
const Color kContainerColor = Color(0xFF777777);
const Color kOtherColor = Color(0xFFF4F6F7);
const Color kTextLightColor = Color(0xFFA5A5A5);
const Color kErrorBorderColor = Color(0xFFE74C3C);

//default value
const kDefaultPadding = 20.0;

const sizedBox = SizedBox(
  height: kDefaultPadding,
);
const kWidthSizedBox = SizedBox(
  width: kDefaultPadding,
);

const kHalfSizedBox = SizedBox(
  height: kDefaultPadding / 2,
);

const kHalfWidthSizedBox = SizedBox(
  width: kDefaultPadding / 2,
);

const kTopBorderRadius = BorderRadius.only(
  topLeft: Radius.circular(20),
  topRight: Radius.circular(20),
);

const kBottomBorderRadius = BorderRadius.only(
  bottomRight: Radius.circular(20),
  bottomLeft: Radius.circular(20),
);

final kInputTextStyle = GoogleFonts.poppins(
    color: kTextBlackColor, fontSize: 11, fontWeight: FontWeight.w500);
//Global Variable for storing the API Data
String baseUrl = 'https://uat-api.augmontgold.com/';

int? merchantId;
String? accessToken;
String? tokenType;
DateTime? expiresAt;
String gBuy = '';
String gSell = '';
String sBuy = '';
String sSell = '';
String gBuyGst = '';
String sBuyGst = '';
String userName = '';
String uniqueId = '';
String customerMappedId = '';
String mobileNumber = '';
String blockId = '';
String quantity = '';
String totalAmount = '';
String preTaxAmount = '';
String metalType = '';
String rate = '';
String transactionId = '';
String merchantTransactionId = '';
String goldBalance = '';
String silverBalance = '';
String invoiceNumber = '';

//validation for mobile
const String mobilePattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';

//validation for email
const String emailPattern =
    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
