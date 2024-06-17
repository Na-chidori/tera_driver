import 'package:flutter/material.dart';
import 'package:tera_driver/State/punishment_bloc.dart';
import 'package:tera_driver/widgets/punishment_card_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:tera_driver/views/Pages/payments_page.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class PunishmentsPage extends StatefulWidget {
  final String token;
  const PunishmentsPage({required this.token, Key? key}) : super(key: key);

  @override
  _PunishmentsPageState createState() => _PunishmentsPageState();
}

class _PunishmentsPageState extends State<PunishmentsPage> {
  late String userId;

  @override
  void initState() {
    super.initState();
    try {
      Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);
      userId = jwtDecodedToken['_id'];
      print('Decoded User ID: $userId'); // Debug print
      fetchPunishments(userId);
    } catch (e) {
      print('Error decoding token: $e');
    }
  }

  Future<void> fetchPunishments(String userId) async {
    if (userId.isNotEmpty) {
      print('Fetching punishments for User ID: $userId'); // Debug print
      context.read<PunishmentBloc>().add(GetPunishments(userId: userId));
    } else {
      print("User ID not found!");
    }
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: Center(
              child: Container(
                width: 80,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(200),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text('Punishments'),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<PunishmentBloc, PunishmentState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              print('Current PunishmentState: $state');
              if (state.status == PunishmentStatus.error) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.errorMessage),
                ));
              }
            },
          ),
          BlocListener<PunishmentBloc, PunishmentState>(
            listenWhen: (previous, current) =>
                previous.paymentStatus != current.paymentStatus,
            listener: (context, state) {
              if (state.paymentStatus == PaymentStatus.error) {
                // remove the loading indicator dialog
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.errorMessage),
                ));
              }
              // show loading indicator
              print('Payment Status: ${state.paymentStatus}');
              if (state.paymentStatus == PaymentStatus.loading) {
                _showLoadingDialog(context);
              }
              // paymentUrl is loaded, so go to payment page
              if (state.paymentStatus == PaymentStatus.loaded) {
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      PaymentPage(paymentUrl: state.paymentUrl),
                ));
              }
              // payment was successful, show success dialog
              if (state.paymentStatus == PaymentStatus.success) {
                AwesomeDialog(
                  dialogBorderRadius: BorderRadius.circular(5),
                  dismissOnTouchOutside: true,
                  context: context,
                  dialogType: DialogType.success,
                  animType: AnimType.bottomSlide,
                  title: 'Success',
                  desc: 'Payment Successful!',
                  btnOkOnPress: () {},
                ).show();
              }
            },
          ),
        ],
        child: BlocBuilder<PunishmentBloc, PunishmentState>(
          builder: (context, state) {
            if (state.status == PunishmentStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            print('Punishments: ${state.punishments}'); // Debug print
            return ListView.builder(
              itemCount: state.punishments.length,
              itemBuilder: (context, index) {
                print('Index: $index'); // Debug print
                final punishment = state.punishments[index];
                return PunishmentCard(punishment: punishment);
              },
            );
          },
        ),
      ),
    );
  }
}
