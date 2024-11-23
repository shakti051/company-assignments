import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scalex_assignment/controllers/book_store_controller.dart';
import 'package:scalex_assignment/main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BookStoreController bookStoreController = Get.put(BookStoreController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          return Column(
            children: [
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(left: 15),
                child: ListTile(
                  leading: const Icon(Icons.search, color: appColor),
                  title: TextField(
                    controller: bookStoreController.searchController,
                    decoration: const InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        hintText: "Search",
                        border: InputBorder.none),
                    onChanged: (value) {
                      bookStoreController.filterUserList(value);
                    },
                  ),
                  trailing: bookStoreController.searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.cancel,
                            color: appColor,
                          ),
                          onPressed: () {
                            bookStoreController.onClearPressed();
                          },
                        )
                      : null,
                ),
              ).marginOnly(top: 10),
              const SizedBox(height: 15),
              bookStoreController.isLoadingMainList.value
                  ? const Center(child: CircularProgressIndicator())
                  : bookStoreController.readLogEntry.isEmpty
                      ? const Center(child: Text("Data not found"))
                      : Expanded(
                          child: Stack(
                            children: [
                              ListView.builder(
                                itemCount: bookStoreController
                                    .readLogEntryFiltered.length,
                                controller:
                                    bookStoreController.scrollController,
                                shrinkWrap: true,
                                itemBuilder: (BuildContext context, int index) {
                                  var data =
                                      bookStoreController.readLogEntryFiltered;
                                  return GestureDetector(
                                    child: Card(
                                      elevation: 3,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 7),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      maxLines: 2,
                                                      data[index].work!.title ??
                                                          "",
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: appColor),
                                                    ),
                                                  ),
                                                  Text(
                                                    data[index]
                                                            .work
                                                            ?.firstPublishYear!
                                                            .toString() ??
                                                        "",
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey),
                                                  ),
                                                ]),
                                            Text(
                                              "Key ${data[index].work?.key}",
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.left,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ).marginOnly(top: 3),
                                            Row(
                                              children: [
                                                Expanded(
                                                    child: Text(
                                                  maxLines: 4,
                                                  data[index]
                                                      .work!
                                                      .authorNames!
                                                      .toString(),
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                )),
                                              ],
                                            ).marginOnly(top: 5),
                                            Align(
                                                alignment:
                                                    Alignment.bottomRight,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      color: Colors.pink),
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  child: const Text(
                                                      "book status",
                                                      style: TextStyle(
                                                          fontSize: 13,
                                                          color: Colors.white)),
                                                ))
                                          ],
                                        ),
                                      ),
                                    ),
                                    onTap: () async {},
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
            ],
          );
        }),
      ),
    );
  }
}
