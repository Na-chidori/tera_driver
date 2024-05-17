import 'package:flutter/material.dart';
import 'package:tera_driver/State/punishment_bloc.dart';
import 'package:tera_driver/widgets/punishment_card_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:tera_driver/views/Pages/payments_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PunishmentsPage extends StatefulWidget {
  const PunishmentsPage({super.key});

  @override
  _PunishmentsPageState createState() => _PunishmentsPageState();
}

class _PunishmentsPageState extends State<PunishmentsPage> {
  @override
  void initState() {
    super.initState();
    fetchPunishments(context);
  }

  Future<void> fetchPunishments(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');

    if (userId != null) {
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
                  color: Colors.white,
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
            // display the punishments in grid view
            return GridView.builder(
                itemCount: state.punishments.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 9 / 10,
                ),
                itemBuilder: (context, index) {
                  final punishment = state.punishments[index];
                  return PunishmentCard(punishment: punishment);
                });
          },
        ),
      ),
    );
  }
}