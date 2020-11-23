import 'package:flutter/cupertino.dart';
import 'package:instagram/utilities/show_error_dialog.dart';
import 'package:http/http.dart' as http;

class UrlValidatorService {
  static Future<String> isUrlValid(
    BuildContext context,
    String _website,
  ) async {
    String url = _website.trim();
    String https = 'https://';

    if (url != '') {
      try {
        if (_website.startsWith('www.')) {
          url = _website.replaceAll('www.', https);
        } else if (!_website.startsWith(https)) {
          url = _website.replaceAll(_website, '$https$_website');
        }
        await http.head(url);
      } catch (err) {
        ShowErrorDialog.showAlertDialog(
            errorMessage: 'Please enter a valid Website Url!',
            context: context);
        return null;
      }
      return url;
    } else {
      return null;
    }
  }
}
