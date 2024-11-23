// To parse this JSON data, do
//
//     final bookStoreModel = bookStoreModelFromJson(jsonString);

import 'dart:convert';

BookStoreModel bookStoreModelFromJson(String str) => BookStoreModel.fromJson(json.decode(str));

String bookStoreModelToJson(BookStoreModel data) => json.encode(data.toJson());

class BookStoreModel {
    int? page;
    int? numFound;
    List<ReadingLogEntry>? readingLogEntries;

    BookStoreModel({
        this.page,
        this.numFound,
        this.readingLogEntries,
    });

    factory BookStoreModel.fromJson(Map<String, dynamic> json) => BookStoreModel(
        page: json["page"],
        numFound: json["numFound"],
        readingLogEntries: json["reading_log_entries"] == null ? [] : List<ReadingLogEntry>.from(json["reading_log_entries"]!.map((x) => ReadingLogEntry.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "page": page,
        "numFound": numFound,
        "reading_log_entries": readingLogEntries == null ? [] : List<dynamic>.from(readingLogEntries!.map((x) => x.toJson())),
    };
}

class ReadingLogEntry {
    Work? work;
    String? loggedEdition;
    String? loggedDate;

    ReadingLogEntry({
        this.work,
        this.loggedEdition,
        this.loggedDate,
    });

    factory ReadingLogEntry.fromJson(Map<String, dynamic> json) => ReadingLogEntry(
        work: json["work"] == null ? null : Work.fromJson(json["work"]),
        loggedEdition: json["logged_edition"],
        loggedDate: json["logged_date"],
    );

    Map<String, dynamic> toJson() => {
        "work": work?.toJson(),
        "logged_edition": loggedEdition,
        "logged_date": loggedDate,
    };
}

class Work {
    String? title;
    String? key;
    List<String>? authorKeys;
    List<String>? authorNames;
    int? firstPublishYear;
    String? lendingEditionS;
    List<String>? editionKey;
    int? coverId;
    String? coverEditionKey;

    Work({
        this.title,
        this.key,
        this.authorKeys,
        this.authorNames,
        this.firstPublishYear,
        this.lendingEditionS,
        this.editionKey,
        this.coverId,
        this.coverEditionKey,
    });

    factory Work.fromJson(Map<String, dynamic> json) => Work(
        title: json["title"],
        key: json["key"],
        authorKeys: json["author_keys"] == null ? [] : List<String>.from(json["author_keys"]!.map((x) => x)),
        authorNames: json["author_names"] == null ? [] : List<String>.from(json["author_names"]!.map((x) => x)),
        firstPublishYear: json["first_publish_year"],
        lendingEditionS: json["lending_edition_s"],
        editionKey: json["edition_key"] == null ? [] : List<String>.from(json["edition_key"]!.map((x) => x)),
        coverId: json["cover_id"],
        coverEditionKey: json["cover_edition_key"],
    );

    Map<String, dynamic> toJson() => {
        "title": title,
        "key": key,
        "author_keys": authorKeys == null ? [] : List<dynamic>.from(authorKeys!.map((x) => x)),
        "author_names": authorNames == null ? [] : List<dynamic>.from(authorNames!.map((x) => x)),
        "first_publish_year": firstPublishYear,
        "lending_edition_s": lendingEditionS,
        "edition_key": editionKey == null ? [] : List<dynamic>.from(editionKey!.map((x) => x)),
        "cover_id": coverId,
        "cover_edition_key": coverEditionKey,
    };
}
