class SettingsModel {
  final AppInfo app;
  final ContactsInfo contacts;
  final AppsLinks apps;
  final PagesInfo pages;

  SettingsModel({
    required this.app,
    required this.contacts,
    required this.apps,
    required this.pages,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      app: AppInfo.fromJson(json['app'] ?? {}),
      contacts: ContactsInfo.fromJson(json['contacts'] ?? {}),
      apps: AppsLinks.fromJson(json['apps'] ?? {}),
      pages: PagesInfo.fromJson(json['pages'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'app': app.toJson(),
    'contacts': contacts.toJson(),
    'apps': apps.toJson(),
    'pages': pages.toJson(),
  };
}

class AppInfo {
  final String name;
  final String copyright;
  final String logo;

  AppInfo({
    required this.name,
    required this.copyright,
    required this.logo,
  });

  factory AppInfo.fromJson(Map<String, dynamic> json) => AppInfo(
    name: json['name'] ?? '',
    copyright: json['copyright'] ?? '',
    logo: json['logo'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'copyright': copyright,
    'logo': logo,
  };
}

class ContactsInfo {
  final String facebook;
  final String instagram;
  final String snapchat;
  final String twitter;
  final String tiktok;
  final String phone;
  final String email;
  final String branchName;
  final String address;
  final String whatsapp;
  final String website;

  ContactsInfo({
    required this.facebook,
    required this.instagram,
    required this.snapchat,
    required this.twitter,
    required this.tiktok,
    required this.phone,
    required this.email,
    required this.branchName,
    required this.address,
    required this.whatsapp,
    required this.website,
  });

  factory ContactsInfo.fromJson(Map<String, dynamic> json) => ContactsInfo(
    facebook:   json['facebook']    ?? '',
    instagram:  json['instagram']   ?? '',
    snapchat:   json['snapchat']    ?? '',
    twitter:    json['twitter']     ?? '',
    tiktok:     json['tiktok']      ?? '',
    phone:      json['phone']       ?? '',
    email:      json['email']       ?? '',
    branchName: json['branch_name'] ?? '',
    address:    json['address']     ?? '',
    whatsapp:   json['whatsapp']    ?? '',
    website:    json['website']     ?? '',
  );

  Map<String, dynamic> toJson() => {
    'facebook':    facebook,
    'instagram':   instagram,
    'snapchat':    snapchat,
    'twitter':     twitter,
    'tiktok':      tiktok,
    'phone':       phone,
    'email':       email,
    'branch_name': branchName,
    'address':     address,
    'whatsapp':    whatsapp,
    'website':     website,
  };
}

class AppsLinks {
  final String apple;
  final String android;
  final String huawei;

  AppsLinks({
    required this.apple,
    required this.android,
    required this.huawei,
  });

  factory AppsLinks.fromJson(Map<String, dynamic> json) => AppsLinks(
    apple:   json['apple']   ?? '',
    android: json['android'] ?? '',
    huawei:  json['huawei']  ?? '',
  );

  Map<String, dynamic> toJson() => {
    'apple':   apple,
    'android': android,
    'huawei':  huawei,
  };
}

class PagesInfo {
  final AboutPage about;
  final TermsPage terms;
  final PrivacyPage privacy;

  PagesInfo({
    required this.about,
    required this.terms,
    required this.privacy,
  });

  factory PagesInfo.fromJson(Map<String, dynamic> json) => PagesInfo(
    about:   AboutPage.fromJson(json['about']   ?? {}),
    terms:   TermsPage.fromJson(json['terms']   ?? {}),
    privacy: PrivacyPage.fromJson(json['privacy'] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    'about':   about.toJson(),
    'terms':   terms.toJson(),
    'privacy': privacy.toJson(),
  };
}

class AboutPage {
  final String link;
  final String content;

  AboutPage({required this.link, required this.content});

  factory AboutPage.fromJson(Map<String, dynamic> json) => AboutPage(
    link:    json['link']    ?? '',
    content: json['content'] ?? '',
  );

  Map<String, dynamic> toJson() => {'link': link, 'content': content};
}

class TermsPage {
  final String link;
  final String title;
  final List<TermsArticle> articles;

  TermsPage({
    required this.link,
    required this.title,
    required this.articles,
  });

  factory TermsPage.fromJson(Map<String, dynamic> json) => TermsPage(
    link:  json['link']  ?? '',
    title: json['title'] ?? '',
    articles: (json['articles'] as List<dynamic>? ?? [])
        .map((e) => TermsArticle.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'link':     link,
    'title':    title,
    'articles': articles.map((e) => e.toJson()).toList(),
  };
}

class TermsArticle {
  final String title;
  final String content;

  TermsArticle({required this.title, required this.content});

  factory TermsArticle.fromJson(Map<String, dynamic> json) => TermsArticle(
    title:   json['title']   ?? '',
    content: json['content'] ?? '',
  );

  Map<String, dynamic> toJson() => {'title': title, 'content': content};
}

class PrivacyPage {
  final String link;
  final String content;

  PrivacyPage({required this.link, required this.content});

  factory PrivacyPage.fromJson(Map<String, dynamic> json) => PrivacyPage(
    link:    json['link']    ?? '',
    content: json['content'] ?? '',
  );

  Map<String, dynamic> toJson() => {'link': link, 'content': content};
}