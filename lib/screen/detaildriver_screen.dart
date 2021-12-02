import 'dart:async';
import 'dart:math';

import 'package:custojol/helper/constant.dart';
import 'package:custojol/helper/general_helper.dart';
import 'package:custojol/model/pin_pill_info.dart';
import 'package:custojol/network/network.dart';
import 'package:custojol/widget/map_pin_pill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:toast/toast.dart';

class DetailDriverScreen extends StatefulWidget {
  static String id = "detaildriver";
  String? idDriver;
  String? latOrigin;
  String? lngOrigin;

  DetailDriverScreen({Key? key, this.idDriver, this.latOrigin, this.lngOrigin})
      : super(key: key);

  @override
  _DetailDriverScreenState createState() => _DetailDriverScreenState();
}

class _DetailDriverScreenState extends State<DetailDriverScreen> {
  Location? location;

  PolylinePoints? polylinepoints;
  LocationData? currentLocation;

  LocationData? destinationLocation;
  Completer<GoogleMapController> controller = Completer();
  PinInformation? originPin;
  PinInformation? destinationPin;
  Set<Marker> markers = Set<Marker>();

  double pinPillPosition = -100;
  PinInformation? currentSelectedPin = PinInformation(
      pinPath: "gambar/marker_pin.png",
      avatarPath: "gambar/foods.png",
      location: LatLng(0, 0),
      locationName: "",
      labelColor: Colors.grey);

  BitmapDescriptor? originLocationIcon;

  BitmapDescriptor? destinationLocationIcon;

  Timer? timer;
  Network network = Network();

  String? latDriver;

  String? longDriver;

  String? originAdress;
  String? destinatioAddress;

  PolylinePoints polylinePoints = PolylinePoints();
  List<LatLng> polylineCoordinates = [];
  Set<Polyline> polylines = Set<Polyline>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    location = Location();
    polylinepoints = PolylinePoints();

    setOriginAndDestinationIcon();
    //deteksi perubahan lokasi
    location?.onLocationChanged.listen((event) {
      currentLocation = event;
      updatePinOnMap();
    });
    refresh();
  }

  void refresh() {
    Duration duration = Duration(seconds: 5);
    timer = Timer.periodic(
        duration,
        (Timer timer) => setState(() {
              checkLokasiDriver();
              print("refresh");
              print("lat :${widget.latOrigin} lng: ${widget.lngOrigin} ");
              setInitialLocation();
            }));
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition initialCameraPosition = CameraPosition(
        zoom: Constant.CAMERA_ZOOM,
        tilt: Constant.CAMERA_TILT,
        bearing: Constant.CAMERA_BEARING,
        target: currentLocation != null
            ? LatLng(double.parse(widget.latOrigin!),
                double.parse(widget.lngOrigin!))
            : LatLng(-6.8966979, 107.6132013));

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            myLocationButtonEnabled: true,
            compassEnabled: true,
            tiltGesturesEnabled: true,
            markers: markers,
            polylines: polylines,
            mapType: MapType.normal,
            onTap: (LatLng latLng) {
              pinPillPosition = -100;
            },
            initialCameraPosition: initialCameraPosition,
            onMapCreated: (GoogleMapController c) {
              controller.complete(c);
              showPinOnMap();
            },
          ),
          originPin == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      Text("Sabar ya....lagi get data")
                    ],
                  ),
                )
              : Container(),
          MapPinPillComponent(
            pinPillPosition: pinPillPosition,
            currentlySelectedPin: currentSelectedPin,
          )
        ],
      ),
    );
  }

  void updatePinOnMap() async {
    CameraPosition position = CameraPosition(
        zoom: Constant.CAMERA_ZOOM,
        tilt: Constant.CAMERA_TILT,
        bearing: Constant.CAMERA_BEARING,
        target: LatLng(
            double.parse(widget.latOrigin!), double.parse(widget.lngOrigin!)));

    GoogleMapController googleMapController = await controller.future;

    googleMapController.animateCamera(CameraUpdate.newCameraPosition(position));
    setState(() {
      var pinPosition = LatLng(
          double.parse(widget.latOrigin!), double.parse(widget.lngOrigin!));
      originPin?.location = pinPosition;
      markers.removeWhere((element) => element.markerId.value == "originPin");
      markers.add(Marker(
          markerId: MarkerId("originPin"),
          onTap: () {
            setState(() {
              currentSelectedPin = originPin;
              pinPillPosition = 0;
            });
          },
          position: pinPosition,
          icon: originLocationIcon!));
    });
  }

  setOriginAndDestinationIcon() async {
    originLocationIcon =
        await getBitmapDescriptorFromAssetBytes("gambar/marker_start.png", 100);
    destinationLocationIcon = await getBitmapDescriptorFromAssetBytes(
        "gambar/marker_destination.png", 100);
  }

  void checkLokasiDriver() {
    network.detailDriver(widget.idDriver).then((response) {
      if (response?.result == "true") {
        setState(() {
          latDriver = response?.data?[0].trackingLat.toString();
          longDriver = response?.data?[0].trackingLng.toString();
          ;
        });
        showPinOnMap();
      } else {
        Toast.show(response?.msg, context);
      }
    });
  }

  showPinOnMap() async {
    var originPosition = LatLng(
        double.parse(widget.latOrigin!), double.parse(widget.lngOrigin!));
    var destinationPosition = LatLng(
        destinationLocation?.latitude ?? -6.8893006,
        destinationLocation?.longitude ?? 107.5936679);
    originAdress = await getAddress(
        double.parse(widget.latOrigin!), double.parse(widget.lngOrigin!));

    destinatioAddress =
        await getAddress(double.parse(latDriver!), double.parse(longDriver!));
    originPin = PinInformation(
        locationName: originAdress,
        location: originPosition,
        pinPath: "gambar/marker_start.png",
        avatarPath: "gambar/friend1.jpg",
        labelColor: Colors.yellow[900]);

    destinationPin = PinInformation(
        locationName: destinatioAddress,
        location: LatLng(double.parse(latDriver!), double.parse(longDriver!)),
        pinPath: "gambar/marker_destination.png",
        avatarPath: "gambar/friend2.jpg",
        labelColor: Colors.blue[900]);

    addMarkerOriginDestination(
        originPin, destinationPin, originPosition, destinationPosition);
    setPolyline();
  }

  void setPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        Constant.API_KEY,
        PointLatLng(
            double.parse(widget.latOrigin!), double.parse(widget.lngOrigin!)),
        PointLatLng(
            destinationLocation!.latitude!, destinationLocation!.longitude!));
    polylineCoordinates.clear();
    polylines.removeWhere((element) => element.polylineId.value == "Route");
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng pointLatLng) {
        polylineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });

      setState(() {
        polylines.add(Polyline(
            polylineId: PolylineId("Route"),
            color: Colors.blue,
            width: 4,
            points: polylineCoordinates));
      });
    }
  }

  Future<String> getAddress(double lat, double lng) async {
    final coordinate = new Coordinates(lat, lng);

    var address = await Geocoder.local.findAddressesFromCoordinates(coordinate);
    var firstLocation = address.first;
    return firstLocation.addressLine;
  }

  void addMarkerOriginDestination(
      PinInformation? originPin,
      PinInformation? destinationPin,
      LatLng originPosition,
      LatLng destinationPosition) {
    markers.add(Marker(
        markerId: MarkerId("originPin"),
        onTap: () {
          setState(() {
            currentSelectedPin = originPin;
            pinPillPosition = 0;
          });
        },
        position: originPosition,
        icon: originLocationIcon!));

    markers.add(Marker(
        markerId: MarkerId("destinationPin"),
        onTap: () {
          setState(() {
            currentSelectedPin = destinationPin;
            pinPillPosition = 0;
          });
        },
        position: destinationPosition,
        icon: destinationLocationIcon!));
  }

  void setInitialLocation() async {
    currentLocation = await location?.getLocation();
    destinationLocation = LocationData.fromMap({
      "latitude": double.parse(latDriver!),
      "longitude": double.parse(longDriver!),
    });
  }
}
