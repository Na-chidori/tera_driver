import 'package:tera_driver/State/punishment_bloc.dart';
import 'package:tera_driver/models/punishmentmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PunishmentCard extends StatelessWidget {
  const PunishmentCard({
    super.key,
    required this.punishment,
  });

  final Punishment punishment;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(
                Icons.payment,
                color: Colors.green,
                size: 40,
              ),
              title: Text(
                punishment.name,
              ),
              subtitle: Text(
                '${punishment.fine.toStringAsFixed(2)} Br',
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    context.read<PunishmentBloc>().add(PayPunishments(
                          punishmentId: punishment.id,
                        ));
                  },
                  child: const Text('Pay'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
