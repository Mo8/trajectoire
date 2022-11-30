import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

class LocationRepository {
  late io.Socket socket;

  String websocketAdress;
  Stream<LatLng> streamUserlocation;
  late StreamSubscription subscription;

  void Function(Map)? callbackOtherLocation;

  LocationRepository({required this.websocketAdress, required this.streamUserlocation, bool openSocket = false, this.callbackOtherLocation}) {
    if (openSocket) {
      tryConnectToSocket();
    }
  }

  Future<void> sendUserLocation({required double longitude, required double latitude}) async {
    socket.emit("position:post", {"lat": latitude, "lng": longitude});
  }

  tryConnectToSocket() {
    print("TRY CONNECT");
    socket = io.io(
        websocketAdress,
        io.OptionBuilder().setTransports(['websocket'])
            // .disableAutoConnect()
            .build());

    socket.onConnect((_) {
      print("CONNECT");
      subscription = streamUserlocation.listen((location) {
        sendUserLocation(longitude: location.longitude, latitude: location.latitude);
      });
      socket.on(
        "position",
        (data) {
          if (callbackOtherLocation != null) {
            callbackOtherLocation!(data);
          }
        },
      );
    });
    if (socket.disconnected) socket.connect();
  }

  closeSocket() {
    socket.clearListeners();
    socket.disconnect();
    subscription.cancel();
  }

  bool isConnected() {
    return socket.connected;
  }
}

class LatLng {
  double latitude;
  double longitude;

  LatLng(this.latitude,this.longitude);

  @override
  String toString() {
    return 'LatLng{latitude: $latitude, longitude: $longitude}';
  }
}
