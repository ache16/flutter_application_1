part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  
  static const SPLASH = _Paths.SPLASH;
  static const LOGIN = _Paths.LOGIN;
  static const REGISTER = _Paths.REGISTER;
  static const HOME = _Paths.HOME;
  static const DIARY_DETAIL = _Paths.DIARY_DETAIL;
  static const DIARY_EDIT = _Paths.DIARY_EDIT;
  static const DIARY_CALENDAR = _Paths.DIARY_CALENDAR;
  static const CHAT = _Paths.CHAT;
  static const FRIENDS = _Paths.FRIENDS;
  static const FRIEND_SEARCH = _Paths.FRIEND_SEARCH;
  static const PROFILE = _Paths.PROFILE;
  static const PROFILE_EDIT = _Paths.PROFILE_EDIT;
  static const SETTINGS = _Paths.SETTINGS;
  static const STATISTICS = _Paths.STATISTICS;
  static const MOMENTS = _Paths.MOMENTS;
}

abstract class _Paths {
  static const SPLASH = '/splash';
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const HOME = '/home';
  static const DIARY_DETAIL = '/diary/:id';
  static const DIARY_EDIT = '/diary/edit';
  static const DIARY_CALENDAR = '/diary/calendar';
  static const CHAT = '/chat/:userId';
  static const FRIENDS = '/friends';
  static const FRIEND_SEARCH = '/friends/search';
  static const PROFILE = '/profile';
  static const PROFILE_EDIT = '/profile/edit';
  static const SETTINGS = '/settings';
  static const STATISTICS = '/statistics';
  static const MOMENTS = '/moments';
}
