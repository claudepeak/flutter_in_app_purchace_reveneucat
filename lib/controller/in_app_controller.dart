import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class InAppController extends GetxController {
  final entitlementList = [
    'premium_access',
    'premium_monthly',
    'premium_annually',
    'premium_access',
    'premium_monthly2',
    'premium_annually2',
  ];

  late final Rx<Offerings?>? offerings = Rx<Offerings?>(null);
  late final Rx<Package?>? monthly = Rx<Package?>(null);
  late final Rx<Package?>? annually = Rx<Package?>(null);

  /// Get the products for sale
  Future<void> getProducts() async {
    try {
      final Offerings tempOfferings = await Purchases.getOfferings();
      offerings!.value = tempOfferings;

      if (offerings!.value!.current!.monthly != null) {
        monthly!.value = offerings!.value!.current!.monthly!;
      }

      if (offerings!.value!.current!.annual != null) {
        annually!.value = offerings!.value!.current!.annual!;
      }
    } on PlatformException catch (e) {
      debugPrint('Error: ${e.message}');
      rethrow;
    } finally {
      update(['updateId']);
    }
  }

  /// Purchase a product
  Future<void> purchaseProduct(Package? package) async {
    log(package!.toJson().toString());
    try {
      CustomerInfo customerInfo = await Purchases.purchasePackage(package);

      if (customerInfo.entitlements.all['entitlementIdentifier']!.isActive) {
        log('Purchase successful');

        /*   appData.entitlementIsActive = true;
        showSnackbar(AppLocalization.getLabels.purchaseSuccesfullText);
        final response = await General().updatePremiumStatus(true); */
        //   if (response.status == 200) {
        //  final model = sessionService.currentUser.copyWith(isPremium: true);
        //  sessionService.currentUser = model;
        //  }
      } else {
        // appData.entitlementIsActive = false;
        log('Purchase failed');
      }

      /// ErrorCode: ITEM_ALREADY_OWNED.null
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        log('User cancelled');
      } else if (errorCode == PurchasesErrorCode.purchaseNotAllowedError) {
        log('User not allowed to purchase');
      } else if (errorCode == PurchasesErrorCode.paymentPendingError) {
        log('Payment pending');
      } else if (errorCode == PurchasesErrorCode.productAlreadyPurchasedError) {
        log('Product already purchased');
      } else if (errorCode == PurchasesErrorCode.unknownError) {
        log('Unknown error');
      } else {
        log('Error: ${e.message}');
      }
    }
  }

  /// Restore a purchase
  Future<void> restorePurchase() async {
    //  restoreButtonIsLoading = true;
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();

      if (customerInfo.entitlements.all['entitlementIdentifier']!.isActive) {
        log('Restore successful');
        // appData.entitlementIsActive = true;

        /*    final response = await General().updatePremiumStatus(true);
        if (response.status == BaseModelStatus.Ok) {
          final model = sessionService.currentUser.copyWith(isPremium: true);
          sessionService.currentUser = model;
        } */
      } else {
        //     appData.entitlementIsActive = false;
        log('Restore failed');
      }
    } on PlatformException catch (e) {
      log('[restorePurchase] Error: ${e.message}');
    } finally {
      //restoreButtonIsLoading = false;
    }
  }

  ///Check if the user has an active subscription
  Future<bool> checkActiveSubscription() async {
    CustomerInfo customerInfo = await Purchases.getCustomerInfo();

    return (customerInfo.entitlements.all['entitlementId']?.isActive ?? false);
  }

  Future ready() async {
    await getProducts();
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    await ready();
  }
}
