import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scalex_assignment/models/book_store_model.dart';

class BookStoreController extends GetxController {
  TextEditingController searchController = TextEditingController();

  BookStoreModel bookStoreModel = BookStoreModel();
  RxBool isLoading = false.obs;
  RxBool isLoadingMainList = true.obs;
  RxList<ReadingLogEntry> readLogEntry = <ReadingLogEntry>[].obs;
  RxList<ReadingLogEntry> readLogEntryFiltered = <ReadingLogEntry>[].obs;
  late ScrollController scrollController;
  bool isScrollUpVisible = false;
  int index = 20;

  void filterUserList(String value) {
    readLogEntryFiltered.clear();
    if (value.isEmpty) {
      readLogEntryFiltered.addAll(readLogEntry);
    } else {
      for (var item in readLogEntry) {
        if (item.work!.title != null &&
            item.work!.title!.toLowerCase().contains(value.toLowerCase())) {
          readLogEntryFiltered.add(item);
        }
      }
    }
    update();
  }

  void onClearPressed() {
    searchController.clear();
    readLogEntryFiltered.clear();
    readLogEntryFiltered.addAll(readLogEntry);
    update();
  }

  void scrollListener() {
    if (scrollController.position.pixels > 200) {
      isScrollUpVisible = true;
      update();
    }
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (index == readLogEntry.length) {
        isLoading.value = true;
        index += 20;
        getBooksListByStatus();
      }
    }
  }

  Future<void> scrollAnimateTop() async {
    await scrollController.animateTo(0,
        duration: const Duration(seconds: 1), curve: Curves.easeInOut);
    isScrollUpVisible = false;
    update();
  }

  @override
  void onInit() {
    scrollController = ScrollController();
    scrollController.addListener(scrollListener);
    getBooksListByStatus();
    super.onInit();
  }

  Future<BookStoreModel?> getBooksListByStatus() async {
    final dio = Dio();
    isLoading.value = true;
    try {
      final response = await dio
          .get('https://openlibrary.org/people/mekBot/books/already-read.json');

      bookStoreModel = BookStoreModel.fromJson(jsonDecode(response.toString()));

      readLogEntry.addAll(bookStoreModel.readingLogEntries!);

      for (int i = 0; i < 20; i++) {
        readLogEntryFiltered.add(bookStoreModel.readingLogEntries![i]);
      }

      isLoading.value = false;
      isLoadingMainList.value = false;
      return bookStoreModel;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }
}
