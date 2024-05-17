import 'package:tera_driver/State/punishment_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class PaymentPage extends StatefulWidget {
  // comes from our backend after communicating with chapa

  final String paymentUrl;
  const PaymentPage({Key? key, required this.paymentUrl}) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late InAppWebViewController webViewController;

  // delay to keep the page shown before we pop the page after successful/failed
  // scenarios
  Future<void> delay() async {
    await Future.delayed(const Duration(seconds: 2));
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: <Widget>[
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(widget.paymentUrl)),
              onWebViewCreated: (controller) {
                setState(() {
                  webViewController = controller;
                });
                controller.addJavaScriptHandler(
                    handlerName: "buttonState",
                    callback: (args) async {
                      webViewController = controller;

                      if (args[2][1] == 'CancelbuttonClicked') {
                        _showSnackbar(context, 'Payment Cancelled');
                        Navigator.of(context).pop();
                      }

                      return args.reduce((curr, next) => curr + next);
                    });
              },
              onUpdateVisitedHistory: (InAppWebViewController controller,
                  Uri? uri, androidIsReload) async {
                if (uri.toString() == 'https://chapa.co') {
                  _showSnackbar(context, 'Payment Successful');
                  context.read<PunishmentBloc>().add(PaymentSuccessful());
                  Navigator.of(context).pop();
                } else if (uri
                    .toString()
                    .contains('checkout/test-payment-receipt/')) {
                  _showSnackbar(context, 'Payment Successful');
                  // delay to show success message from chapa
                  await delay();
                  if (mounted) {
                    context.read<PunishmentBloc>().add(PaymentSuccessful());
                    Navigator.of(context).pop();
                  }
                }
                controller.addJavaScriptHandler(
                    handlerName: "handlerFooWithArgs",
                    callback: (args) async {
                      webViewController = controller;

                      if (args[2][1] == 'failed') {
                        await delay();
                        if (mounted) {
                          Navigator.of(context).pop();
                        }
                      }
                      if (args[2][1] == 'success') {
                        if (mounted) {
                          _showSnackbar(context, 'Payment Successful');
                        }
                        // delay to show successful message from chapa
                        await delay();
                        if (mounted) {
                          context
                              .read<PunishmentBloc>()
                              .add(PaymentSuccessful());
                          Navigator.of(context).pop();
                        }
                      }
                      return args.reduce((curr, next) => curr + next);
                    });

                controller.addJavaScriptHandler(
                    handlerName: "buttonState",
                    callback: (args) async {
                      webViewController = controller;

                      if (args[2][1] == 'CancelbuttonClicked') {
                        _showSnackbar(context, 'Payment Cancelled');

                        Navigator.of(context).pop();
                      }

                      return args.reduce((curr, next) => curr + next);
                    });
              },
            ),
          ),
        ]),
      ),
    );
  }
}
