import 'package:args/args.dart';

import 'location_repository.dart';

main(List<String> args) {
  var parser = ArgParser();
  parser.addOption(
    'latitude',
    mandatory: true,
    aliases: ['lat'],
  );
  parser.addOption(
    'longitude',
    mandatory: true,
    aliases: ['lng'],
  );

  parser.addOption(
    'address',
    mandatory: true,
    aliases: ['addr'],
  );


  final result = parser.parse(args);
  LatLng currentLatLng = LatLng(double.parse(result["latitude"]) , double.parse(result["longitude"]));
  int stepLat = 0, stepLng = 0;
  final int stepMax = 10;
  final double realStep = 0.001;
  final sendPos = Stream.periodic(
    const Duration(seconds: 5),
    (computationCount) {
      if (stepLat < stepMax && stepLng == 0) {
        stepLat++;
        currentLatLng.latitude += realStep;
      } else if (stepLat == stepMax && stepLng < stepMax) {
        stepLng++;
        currentLatLng.longitude += realStep;
      } else if (stepLat > 0 && stepLng == stepMax) {
        stepLat--;
        currentLatLng.latitude -= realStep;
      } else if (stepLat == 0 && stepLng > 0) {
        stepLng--;
        currentLatLng.longitude -= realStep;
      }
      print(currentLatLng);
      return currentLatLng;
    },
  );
  final locationRepository = LocationRepository(websocketAdress: result["address"], streamUserlocation: sendPos, openSocket: true);
}
