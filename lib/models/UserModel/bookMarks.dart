class BookMarks{

  String bookName;
  String publisher;
  String imageLink;
  String desc;
  String pubdate;

  BookMarks(this.bookName,this.publisher,this.imageLink, this.desc, this.pubdate);

  Map<String,dynamic> toMap() => {
    "book_name": this.bookName,
    "publisher": this.publisher,
    "image_link": this.imageLink,
    "desc": this.desc,
    "pub_date": this.pubdate,
  };
  BookMarks.fromMap(Map<String, dynamic> map): bookName = map['book_name'], publisher = map['publisher'],imageLink = map['image_link'], desc = map['desc'], pubdate = map['pub_date'];

}