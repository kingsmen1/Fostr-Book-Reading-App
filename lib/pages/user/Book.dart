class VolumeJson {
  final int totalItems;

  final String kind;

  final List<Item> items;

  VolumeJson(this.items, this.kind, this.totalItems);

  factory VolumeJson.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['items'] as List;

    List<Item> itemList = list.map((i) => Item.fromJson(i)).toList();
    print(itemList.length);

    return VolumeJson(itemList, parsedJson['kind'], parsedJson['totalItems']);
  }
}

class Item {
  final String kind;

  final String etag;

  final VolumeInfo volumeinfo;

  Item(this.kind, this.etag, this.volumeinfo);

  factory Item.fromJson(Map<String, dynamic> parsedJson) {
    return Item(parsedJson['kind'], parsedJson['etag'],
        VolumeInfo.fromJson(parsedJson['volumeInfo']));
  }
}

class VolumeInfo {
  final String title;

  final String publisher;

  final String printType;

  final ImageLinks image;

  final String isbn13;

  final String description;

  final String pubDate;

  final String author;

  VolumeInfo(this.printType, this.title, this.publisher, this.image,
      this.isbn13, this.description, this.pubDate, this.author);

  factory VolumeInfo.fromJson(Map<String, dynamic> parsedJson) {
    //print(isbnList[1]);
    return VolumeInfo(
        parsedJson['binding'],
        parsedJson['title'],
        parsedJson['publisher'],
        ImageLinks.fromJson(
          parsedJson['image'],
        ),
        parsedJson['isbn13'],
        parsedJson['synopsys'],
        parsedJson['date_published'],
        parsedJson['authors'][0]);
  }
}

class ImageLinks {
  final String thumb;

  ImageLinks(this.thumb);

  factory ImageLinks.fromJson(Map<String, dynamic> parsedJson) {
    return ImageLinks(parsedJson['thumbnail']);
  }
}

class ISBN {
  final String iSBN13;
  final String type;

  ISBN(this.iSBN13, this.type);

  factory ISBN.fromJson(Map<String, dynamic> parsedJson) {
    return ISBN(
      parsedJson['identifier'],
      parsedJson['type'],
    );
  }
}
