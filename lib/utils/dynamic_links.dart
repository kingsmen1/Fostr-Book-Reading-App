import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DynamicLinksApi {
  late BuildContext context;
  final dynamicLink = FirebaseDynamicLinks.instance;

  // handleDynamicLink() async {
  //   await dynamicLink.getInitialLink();
  //   dynamicLink.onLink(onSuccess: (data) async {
  //     handleSuccessLinking(data, context);
  //   }, onError: (OnLinkErrorException error) async {
  //     print(error.message.toString());
  //   });
  // }

  static Future<String> createReferralLink(String referralCode) async {
    final DynamicLinkParameters dynamicLinkParameters = DynamicLinkParameters(
      uriPrefix: 'https://clubfostrdev.page.link',
      link:
          Uri.parse('https://clubfostrdev.page.link/refer?code=$referralCode'),
      androidParameters: AndroidParameters(
        packageName: 'com.clubfostrdev.fostr',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Refer A Friend',
        description: 'Refer and earn Foster Coins',
        imageUrl: Uri.parse(
            'https://www.insperity.com/wp-content/uploads/Referral-_Program1200x600.png'),
      ),
    );

    final ShortDynamicLink shortLink = await FirebaseDynamicLinks.instance
        .buildShortLink(dynamicLinkParameters);

    final Uri dynamicUrl = shortLink.shortUrl;
    print(dynamicUrl);
    return dynamicUrl.toString();
  }

  static Future<String> createDynamicLink(String referralCode) async {
    final DynamicLinkParameters dynamicLinkParameters = DynamicLinkParameters(
      uriPrefix: 'https://clubfostrdev.page.link',
      link:
          Uri.parse('https://clubfostrdev.page.link/refer?code=$referralCode'),
      androidParameters: AndroidParameters(
        packageName: 'com.clubfostrdev.fostr',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Refer A Friend',
        description: 'Refer and earn Foster Coins',
        imageUrl: Uri.parse(
            'https://www.insperity.com/wp-content/uploads/Referral-_Program1200x600.png'),
      ),
    );

    final Uri dynaLink =
        await FirebaseDynamicLinks.instance.buildLink(dynamicLinkParameters);

    print(dynaLink);
    return dynaLink.toString();
  }

  static Future<String> createInviteOnlyDynamicLink(String inviteOnlyCode,
      {String clubName = ""}) async {
    final DynamicLinkParameters dynamicLinkParameters = DynamicLinkParameters(
      uriPrefix: 'https://clubfostr.page.link',
      link: Uri.parse(
          'https://clubfostr.page.link/bookClub?code=$inviteOnlyCode'),
      androidParameters: AndroidParameters(
        packageName: 'com.clubfostr.fostr',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Join${clubName.length == 0 ? '' : ' ' + clubName} Book Club',
        description: 'Join Book Club on Fostr Reads',
        imageUrl: Uri.parse(
            'https://static.wixstatic.com/media/04ed56_2d5c61293ba94717889b83b89d219c73~mv2.png/v1/fill/w_1920,h_1080,al_c/04ed56_2d5c61293ba94717889b83b89d219c73~mv2.png'),
      ),
    );

    final ShortDynamicLink dynaLink = await FirebaseDynamicLinks.instance
        .buildShortLink(dynamicLinkParameters);

    print(dynaLink);
    return dynaLink.shortUrl.toString();
  }

  static Future<String> inviteOnlyRoomLink(String roomCode, String creatorId,
      {String roomName = "", String? imageUrl, String? creatorName}) async {
    final DynamicLinkParameters dynamicLinkParameters = DynamicLinkParameters(
      navigationInfoParameters: NavigationInfoParameters(
        forcedRedirectEnabled: true,
      ),
      uriPrefix: 'https://clubfostr.page.link',
      link: Uri.parse(
          'https://clubfostr.page.link/r?roomId=$roomCode&&creator=$creatorId'),
      androidParameters: AndroidParameters(
        packageName: 'com.clubfostr.fostr',
      ),
      iosParameters: IOSParameters(
        appStoreId: "1586328359",
        bundleId: 'com.clubfostr.fostrfinal',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Join${roomName.length == 0 ? '' : ' ' + roomName} Room',
        description:
            'Join the room ${roomName.length == 0 ? '' : ' ' + roomName} and be a part of the discussion',
        imageUrl: Uri.parse(imageUrl ??
            'https://static.wixstatic.com/media/04ed56_2d5c61293ba94717889b83b89d219c73~mv2.png/v1/fill/w_1920,h_1080,al_c/04ed56_2d5c61293ba94717889b83b89d219c73~mv2.png'),
      ),
    );

    final ShortDynamicLink dynaLink = await FirebaseDynamicLinks.instance
        .buildShortLink(dynamicLinkParameters);

    return dynaLink.shortUrl.toString();
  }

  static Future<String> inviteOnlyTheatreLink(
      String theatreId, String creatorId,
      {String roomName = "", String? imageUrl, String? creatorName}) async {
    final DynamicLinkParameters dynamicLinkParameters = DynamicLinkParameters(
      navigationInfoParameters: NavigationInfoParameters(
        forcedRedirectEnabled: true,
      ),
      uriPrefix: 'https://clubfostr.page.link',
      link: Uri.parse(
          'https://clubfostr.page.link/theatre?theatreId=$theatreId&&creatorId=$creatorId'),
      androidParameters: AndroidParameters(
        packageName: 'com.clubfostr.fostr',
      ),
      iosParameters: IOSParameters(
        appStoreId: "1586328359",
        bundleId: 'com.clubfostr.fostrfinal',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Join${roomName.length == 0 ? '' : ' ' + roomName} Theatre',
        description:
            'Join the theatre ${roomName.length == 0 ? '' : ' ' + roomName} and be a part of the discussion',
        imageUrl: Uri.parse(imageUrl ??
            'https://static.wixstatic.com/media/04ed56_2d5c61293ba94717889b83b89d219c73~mv2.png/v1/fill/w_1920,h_1080,al_c/04ed56_2d5c61293ba94717889b83b89d219c73~mv2.png'),
      ),
    );

    final ShortDynamicLink dynaLink = await FirebaseDynamicLinks.instance
        .buildShortLink(dynamicLinkParameters);

    return dynaLink.shortUrl.toString();
  }

  static Future<String> fosterBitsLink(String bitsId,
      {required bookName, required userName}) async {
    final DynamicLinkParameters dynamicLinkParameters = DynamicLinkParameters(
      navigationInfoParameters: NavigationInfoParameters(
        forcedRedirectEnabled: true,
      ),
      uriPrefix: 'https://clubfostr.page.link',
      link: Uri.parse('https://clubfostr.page.link/fosterbits?id=$bitsId'),
      androidParameters: AndroidParameters(
        packageName: 'com.clubfostr.fostr',
      ),
      iosParameters: IOSParameters(
        appStoreId: "1586328359",
        bundleId: 'com.clubfostr.fostrfinal',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Foster Bits',
        description:
            'Serving you quick 2-minute audio reviews on Foster Reads!',
      ),
    );

    final ShortDynamicLink dynaLink = await FirebaseDynamicLinks.instance
        .buildShortLink(dynamicLinkParameters);

    return dynaLink.shortUrl.toString();
  }

  static Future<String> fosterUserLink(
      {required String userId, required String name}) async {
    final DynamicLinkParameters dynamicLinkParameters = DynamicLinkParameters(
      navigationInfoParameters: NavigationInfoParameters(
        forcedRedirectEnabled: true,
      ),
      uriPrefix: 'https://clubfostr.page.link',
      link: Uri.parse('https://clubfostr.page.link/fosteruser?id=$userId'),
      androidParameters: AndroidParameters(
        packageName: 'com.clubfostr.fostr',
      ),
      iosParameters: IOSParameters(
        appStoreId: "1586328359",
        bundleId: 'com.clubfostr.fostrfinal',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: name,
        description:
            "Check $name's amazing profile on Foster Reads!",
      ),
    );

    final ShortDynamicLink dynaLink = await FirebaseDynamicLinks.instance
        .buildShortLink(dynamicLinkParameters);

    return dynaLink.shortUrl.toString();
  }

  static Future<String> fosterPodsLink(String podsId,
      {String roomName = ""}) async {
    final DynamicLinkParameters dynamicLinkParameters = DynamicLinkParameters(
      navigationInfoParameters: NavigationInfoParameters(
        forcedRedirectEnabled: true,
      ),
      uriPrefix: 'https://clubfostr.page.link',
      link: Uri.parse('https://clubfostr.page.link/pods?id=$podsId'),
      androidParameters: AndroidParameters(
        packageName: 'com.clubfostr.fostr',
      ),
      iosParameters: IOSParameters(
        appStoreId: "1586328359",
        bundleId: 'com.clubfostr.fostrfinal',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Foster Pods',
        description: 'Listen to the podcast about the Room $roomName ',
      ),
    );

    final ShortDynamicLink dynaLink = await FirebaseDynamicLinks.instance
        .buildShortLink(dynamicLinkParameters);

    return dynaLink.shortUrl.toString();
  }

  static Future<String> fosterAlbumsLink(String authId, String albumId,) async {
    final DynamicLinkParameters dynamicLinkParameters = DynamicLinkParameters(
      navigationInfoParameters: NavigationInfoParameters(
        forcedRedirectEnabled: true,
      ),
      uriPrefix: 'https://clubfostr.page.link',
      link: Uri.parse('https://clubfostr.page.link/albums?authId=$authId&&albumId=$albumId'),
      androidParameters: AndroidParameters(
        packageName: 'com.clubfostr.fostr',
      ),
      iosParameters: IOSParameters(
        appStoreId: "1586328359",
        bundleId: 'com.clubfostr.fostrfinal',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Foster Album',
        description: 'Listen to the episodes in $albumId album',
      ),
    );

    final ShortDynamicLink dynaLink = await FirebaseDynamicLinks.instance
        .buildShortLink(dynamicLinkParameters);

    return dynaLink.shortUrl.toString();
  }

  static Future<String> fosterEpisodeLink(String episodeId, String albumId, String username,) async {
    final DynamicLinkParameters dynamicLinkParameters = DynamicLinkParameters(
      navigationInfoParameters: NavigationInfoParameters(
        forcedRedirectEnabled: true,
      ),
      uriPrefix: 'https://clubfostr.page.link',
      link: Uri.parse('https://clubfostr.page.link/episode?episodeId=$episodeId&&albumId=$albumId&&username=$username'),
      androidParameters: AndroidParameters(
        packageName: 'com.clubfostr.fostr',
      ),
      iosParameters: IOSParameters(
        appStoreId: "1586328359",
        bundleId: 'com.clubfostr.fostrfinal',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Foster Episode',
        description: 'Listen to the episode',
      ),
    );

    final ShortDynamicLink dynaLink = await FirebaseDynamicLinks.instance
        .buildShortLink(dynamicLinkParameters);

    return dynaLink.shortUrl.toString();
  }

  void handleSuccessLinking(data, BuildContext context) {
    final Uri deepLink = data?.link;

    var isRefer = deepLink.pathSegments.contains('refer');
    if (isRefer) {
      var code = deepLink.queryParameters['code'];
      print(code.toString());
      if (code != null) {
        Navigator.pushNamed(context, '/signup', arguments: {
          'referralCode': code,
        });
      }
    }
  }
}
