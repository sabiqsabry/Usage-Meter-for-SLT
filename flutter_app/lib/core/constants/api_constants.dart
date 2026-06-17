const String kBaseUrl = 'https://omniscapp.slt.lk/slt/ext/api';

// MySLT's Google OAuth web client ID — used as serverClientId so Google issues
// a token that MySLT's backend can verify.
const String kMySltGoogleClientId =
    '531709258665-atiep7rt3mrbutfrosms4sset496l026.apps.googleusercontent.com';

// Your iOS OAuth client ID from Google Cloud Console.
// Replace with the value from console.cloud.google.com → Credentials → iOS client.
const String kGoogleIosClientId =
    '977775449797-henat6gb5l84sfo6ajt240kprm17eb0t.apps.googleusercontent.com';

// Replace with your actual IBM Client ID
// Obtain from the SLT developer portal or from the original app's Secrets.swift
const String kClientId = 'b7402e9d66808f762ccedbe42c20668e';

class ApiEndpoints {
  static const String login = '$kBaseUrl/Account/Login';
  static const String loginExternal = '$kBaseUrl/Account/LoginExternal';
  static const String refreshToken = '$kBaseUrl/Account/RefreshToken';

  static String accountDetail(String username) =>
      '$kBaseUrl/AccountOMNI/GetAccountDetailRequest?username=$username';

  static String serviceDetail(String telephoneNo) =>
      '$kBaseUrl/AccountOMNI/GetServiceDetailRequest?categoryID=BB&telephoneNo=$telephoneNo';

  static String usageSummary(String subscriberId) =>
      '$kBaseUrl/BBVAS/UsageSummary?subscriberID=$subscriberId';

  static String vasBundles(String subscriberId) =>
      '$kBaseUrl/BBVAS/GetDashboardVASBundles?subscriberID=$subscriberId';
}
