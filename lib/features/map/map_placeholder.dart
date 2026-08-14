import 'package:flutter/material.dart';

class MapPlaceholder extends StatelessWidget {
  const MapPlaceholder({super.key});

  @override
  Widget build(BuildContext context) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: const Padding(
            padding: EdgeInsets.all(32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.public_off_outlined, size: 58),
              SizedBox(height: 18),
              Text('REAL MAP COMING NEXT',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, letterSpacing: 1.4)),
              SizedBox(height: 10),
              Text(
                  'The static prototype map is intentionally not reproduced. This tab will use a replaceable slippy-map provider with real latitude and longitude.',
                  textAlign: TextAlign.center),
            ]),
          ),
        ),
      );
}
