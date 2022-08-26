class TopReads{
  String bookName;
  String imageLink;

  TopReads(this.bookName,this.imageLink);

  Map<String,dynamic> toMap() => {
    "book_name": this.bookName,
    "image_link": this.imageLink
  };

  TopReads.fromMap(Map<String, dynamic> map): bookName = map['book_name'],imageLink = map['image_link'];

}