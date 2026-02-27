import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/service/api/payment_service.dart';
import 'package:shortzz/model/payment/payment_model.dart';

class SellerKycController extends BaseController {
  final businessNameController = TextEditingController();
  final gstinController = TextEditingController();
  final panController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final pincodeController = TextEditingController();

  // Bank details
  final accountNumberController = TextEditingController();
  final ifscController = TextEditingController();
  final accountHolderController = TextEditingController();

  RxString selectedBusinessType = 'individual'.obs;
  Rx<SellerApplication?> application = Rx(null);
  RxBool isLoadingApplication = true.obs;
  RxList<XFile> documents = <XFile>[].obs;

  final businessTypes = [
    {'value': 'individual', 'label': 'Individual'},
    {'value': 'sole_proprietorship', 'label': 'Sole Proprietorship'},
    {'value': 'partnership', 'label': 'Partnership'},
    {'value': 'pvt_ltd', 'label': 'Private Limited'},
    {'value': 'llp', 'label': 'LLP'},
  ];

  @override
  void onInit() {
    super.onInit();
    fetchApplication();
  }

  @override
  void onClose() {
    businessNameController.dispose();
    gstinController.dispose();
    panController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    accountNumberController.dispose();
    ifscController.dispose();
    accountHolderController.dispose();
    super.onClose();
  }

  Future<void> fetchApplication() async {
    isLoadingApplication.value = true;
    try {
      final response =
          await PaymentService.instance.fetchMySellerApplication();
      if (response.status == true && response.data != null) {
        application.value = response.data;
        _populateFields(response.data!);
      }
    } catch (_) {}
    isLoadingApplication.value = false;
  }

  void _populateFields(SellerApplication app) {
    businessNameController.text = app.businessName ?? '';
    gstinController.text = app.gstin ?? '';
    panController.text = app.pan ?? '';
    addressController.text = app.businessAddress ?? '';
    cityController.text = app.businessCity ?? '';
    stateController.text = app.businessState ?? '';
    pincodeController.text = app.businessPincode ?? '';
    accountNumberController.text = app.bankAccountNumber ?? '';
    ifscController.text = app.bankIfsc ?? '';
    accountHolderController.text = app.bankAccountHolderName ?? '';
    if (app.businessType != null) {
      selectedBusinessType.value = app.businessType!;
    }
  }

  Future<void> pickDocuments() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(imageQuality: 80);
    if (files.isNotEmpty) {
      documents.addAll(files);
    }
  }

  void removeDocument(int index) {
    documents.removeAt(index);
  }

  Future<void> submitApplication() async {
    if (businessNameController.text.trim().isEmpty) {
      showSnackBar('Business name is required');
      return;
    }
    if (panController.text.trim().isEmpty) {
      showSnackBar('PAN number is required');
      return;
    }
    if (panController.text.trim().length != 10) {
      showSnackBar('Enter a valid 10-character PAN');
      return;
    }

    showLoader();
    try {
      final response = await PaymentService.instance.submitSellerApplication(
        businessName: businessNameController.text.trim(),
        businessType: selectedBusinessType.value,
        gstin: gstinController.text.trim().isEmpty
            ? null
            : gstinController.text.trim(),
        pan: panController.text.trim().toUpperCase(),
        businessAddress: addressController.text.trim().isEmpty
            ? null
            : addressController.text.trim(),
        businessCity:
            cityController.text.trim().isEmpty ? null : cityController.text.trim(),
        businessState: stateController.text.trim().isEmpty
            ? null
            : stateController.text.trim(),
        businessPincode: pincodeController.text.trim().isEmpty
            ? null
            : pincodeController.text.trim(),
        documents: documents.isEmpty ? null : documents,
      );
      stopLoader();
      if (response.status == true) {
        application.value = response.data;
        showSnackBar('Application submitted successfully');
      } else {
        showSnackBar(response.message ?? 'Something went wrong');
      }
    } catch (_) {
      stopLoader();
      showSnackBar('Something went wrong');
    }
  }

  Future<void> updateBankDetails() async {
    if (accountNumberController.text.trim().isEmpty ||
        ifscController.text.trim().isEmpty ||
        accountHolderController.text.trim().isEmpty) {
      showSnackBar('All bank details are required');
      return;
    }

    showLoader();
    try {
      final response = await PaymentService.instance.updateSellerBankDetails(
        accountNumber: accountNumberController.text.trim(),
        ifsc: ifscController.text.trim().toUpperCase(),
        accountHolderName: accountHolderController.text.trim(),
      );
      stopLoader();
      if (response.status == true) {
        showSnackBar('Bank details updated');
      } else {
        showSnackBar(response.message ?? 'Something went wrong');
      }
    } catch (_) {
      stopLoader();
      showSnackBar('Something went wrong');
    }
  }
}
