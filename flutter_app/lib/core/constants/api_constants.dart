const String kBaseUrl = 'https://omniscapp.slt.lk/slt/ext/api';

// Replace with your actual IBM Client ID
// Obtain from the SLT developer portal or from the original app's Secrets.swift
const String kClientId = 'b7402e9d66808f762ccedbe42c20668e';

class ApiEndpoints {
  static const String login = '$kBaseUrl/Account/Login';
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
