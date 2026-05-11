import 'package:url_launcher/url_launcher.dart';

Future<bool> pay() async {

  final Uri url = Uri.parse(
    "https://buy.stripe.com/test_6oU6oH6W50kU7Bw2mMf7i00"
  );

  return launchUrl(url);
}