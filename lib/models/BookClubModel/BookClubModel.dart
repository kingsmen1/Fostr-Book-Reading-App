import 'package:json_annotation/json_annotation.dart';
part 'BookClubModel.g.dart';

@JsonSerializable(explicitToJson: true, anyMap: true)
class BookClubModel {
  String id;
  int adminAccounts;
  String? adminProfile;
  List<String> adminUsers;
  String? bookClubBio;
  String bookClubName;
  String? bookClubProfile;
  String createdBy;
  DateTime createdOn;
  List<String> genres;
  List<String> followers;
  List<String> members;
  List<String> pendingMembers;
  List<String> followings;
  String? instagram;
  String? twitter;
  bool isActive;
  bool isInviteOnly;
  String bookclubLowerName;

  int membersCount;
  int roomsCount;

  BookClubModel({
    required this.id,
    required this.adminAccounts,
    this.adminProfile,
    required this.adminUsers,
    this.bookClubBio,
    required this.bookClubName,
    this.bookClubProfile,
    required this.createdBy,
    required this.createdOn,
    required this.genres,
    this.instagram,
    required this.isActive,
    required this.isInviteOnly,
    required this.membersCount,
    required this.roomsCount,
    this.twitter,
    required this.followers,
    required this.followings,
    required this.members,
    required this.pendingMembers,
  }) : bookclubLowerName = bookClubName.toLowerCase();

  Map<String, dynamic> toJson() => _$BookClubModelToJson(this);

  factory BookClubModel.fromJson(Map<String, dynamic> json) =>
      _$BookClubModelFromJson(json);

  factory BookClubModel.empty() => BookClubModel(
        id: '',
        adminAccounts: 0,
        adminProfile: null,
        adminUsers: [],
        bookClubBio: null,
        bookClubName: "",
        bookClubProfile: null,
        createdBy: "",
        createdOn: DateTime.now(),
        genres: [],
        instagram: null,
        isActive: false,
        isInviteOnly: false,
        membersCount: 0,
        roomsCount: 0,
        twitter: null,
        followers: [],
        followings: [],
        members: [],
        pendingMembers: [],
      );

  factory BookClubModel.fromBookClub(BookClubModel bookClub) {
    var json = bookClub.toJson();
    return BookClubModel.fromJson(json);
  }
}
