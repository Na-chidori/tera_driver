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
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          Text(
            punishment.name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                '${punishment.price.toStringAsFixed(2)} Br',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
              ),
              SizedBox(
                height: 30,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    context.read<PunishmentBloc>().add(PayPunishments(
                          punishmentId: punishment.id,
                        ));
                  },
                  child: const Text(
                    'Pay',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}
