import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../models/usage_models.dart';

class UsageProvider extends ChangeNotifier {
  final _api = ApiClient();

  List<AccountInfo> _accounts = [];
  AccountInfo? _selectedAccount;
  ServiceDetailBundle? _serviceDetail;
  UsageSummaryBundle? _usageSummary;
  List<UsageDetail> _vasBundles = [];

  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _errorMessage;

  List<AccountInfo> get accounts => _accounts;
  AccountInfo? get selectedAccount => _selectedAccount;
  ServiceDetailBundle? get serviceDetail => _serviceDetail;
  UsageSummaryBundle? get usageSummary => _usageSummary;
  List<UsageDetail> get vasBundles => _vasBundles;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;

  Future<void> init() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final raw = await _api.fetchAccounts();
      _accounts = raw
          .map((e) => AccountInfo.fromJson(e as Map<String, dynamic>))
          .toList();

      if (_accounts.isEmpty) {
        _errorMessage = 'No accounts found.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      _selectedAccount ??= _accounts.first;
      await _fetchForSelected();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectAccount(AccountInfo account) async {
    if (_selectedAccount == account) return;
    _selectedAccount = account;
    _usageSummary = null;
    _vasBundles = [];
    _serviceDetail = null;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    await _fetchForSelected();
  }

  Future<void> refresh() async {
    _isRefreshing = true;
    _errorMessage = null;
    notifyListeners();
    await _fetchForSelected(isRefresh: true);
  }

  Future<void> _fetchForSelected({bool isRefresh = false}) async {
    final account = _selectedAccount;
    if (account == null) return;

    try {
      final rawService =
          await _api.fetchServiceDetails(account.telephoneno);
      if (rawService != null) {
        _serviceDetail = ServiceDetailBundle.fromJson(rawService);
      }

      final subscriberId =
          _serviceDetail?.bbServices.firstOrNull?.serviceId ?? account.telephoneno;

      final results = await Future.wait([
        _api.fetchUsageSummary(subscriberId),
        _api.fetchVasBundles(subscriberId),
      ]);

      final rawSummary = results[0] as Map<String, dynamic>?;
      final rawVas = results[1] as List<dynamic>;

      _usageSummary =
          rawSummary != null ? UsageSummaryBundle.fromJson(rawSummary) : null;
      _vasBundles = rawVas
          .map((e) => UsageDetail.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      _isRefreshing = false;
      notifyListeners();
    }
  }

  void reset() {
    _accounts = [];
    _selectedAccount = null;
    _serviceDetail = null;
    _usageSummary = null;
    _vasBundles = [];
    _isLoading = false;
    _isRefreshing = false;
    _errorMessage = null;
  }
}
