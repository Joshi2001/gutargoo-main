class MyApi {
  static const String _baseUrl = 'https://admin.gutargooplus.com/api';
  // static const String _baseUrl = 'http://192.168.1.16:3001/api';
  static const String sendOtp = '$_baseUrl/otp/send';
  static const String verifyOtp = '$_baseUrl/otp/verify';
  static const String banner = '$_baseUrl/banners';
  static const String movies = '$_baseUrl/movies';
  static const String search = '$_baseUrl/search';
  static const String redeemGet = '$_baseUrl/redeem/list';
  static const String redeemPost = '$_baseUrl/redeem';
  static const String download = '$_baseUrl/download';
  static const String like = '$_baseUrl/movie-likes';
  static const String category = '$_baseUrl/category';
  static const String ads = '$_baseUrl/ads/all';
  static const String continueWatching = '$_baseUrl/continue-watching';
  static const String sections = '$_baseUrl/admin/sections/alllist';
  static const String webseries = '$_baseUrl/webseries';
  static const String mainPopup = '$_baseUrl/popups';
  static String dynamicUrl(String endpoint) => '$_baseUrl/$endpoint';
} 