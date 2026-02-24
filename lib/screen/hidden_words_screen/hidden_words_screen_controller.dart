import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/common/controller/base_controller.dart';
import 'package:shortzz/common/service/api/user_service.dart';

class HiddenWordsScreenController extends BaseController {
  RxList<String> hiddenWords = RxList<String>();
  final TextEditingController textController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchHiddenWords();
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }

  Future<void> fetchHiddenWords() async {
    isLoading.value = true;
    List<String> words = await UserService.instance.fetchHiddenWords();
    hiddenWords.value = words;
    isLoading.value = false;
  }

  Future<void> addWord() async {
    String word = textController.text.trim().toLowerCase();
    if (word.isEmpty) return;
    if (hiddenWords.contains(word)) {
      textController.clear();
      return;
    }
    await UserService.instance.addHiddenWord(word: word);
    hiddenWords.add(word);
    textController.clear();
  }

  Future<void> removeWord(String word) async {
    await UserService.instance.removeHiddenWord(word: word);
    hiddenWords.remove(word);
  }
}
