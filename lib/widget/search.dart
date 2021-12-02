
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:convert' as JSON;

import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'geocoding.dart';
import 'place.dart';

class SearchMapPlaceWidget extends StatefulWidget {
  SearchMapPlaceWidget({
    required this.apiKey,
    required this.noPlacesErrorMessage,
    required this.noPlacesErrorMessageStyle,
    required this.searchStyle,
    required this.searchHintStyle,
    required this.placesStyle,
    this.placeholder = 'Search',
    this.icon,
    this.searchKey,
    this.onSelected,
    this.onSearch,
    this.language = 'en',
    this.location,
    this.radius,
    this.strictBounds = false,
  }) : assert((location == null && radius == null) ||
            (location != null && radius != null));

  /// API Key of the Google Maps API.
  final GlobalKey? searchKey;
  final String apiKey;
  final String noPlacesErrorMessage;
  final TextStyle noPlacesErrorMessageStyle;

  final TextStyle searchStyle;
  final TextStyle searchHintStyle;
  final TextStyle placesStyle;

  /// Placeholder text to show when the user has not entered any input.
  final String placeholder;

  /// The callback that is called when one Place is selected by the user.
  final void Function(Place place)? onSelected;

  /// The callback that is called when the user taps on the search icon.
  final void Function(String value, Future<Null> clearPlaces)? onSearch;

  /// Language used for the autocompletion.
  ///
  /// Check the full list of [supported languages](https://developers.google.com/maps/faq#languagesupport) for the Google Maps API
  final String language;

  /// The point around which you wish to retrieve place information.
  ///
  /// If this value is provided, `radius` must be provided aswell.
  final LatLng? location;

  /// The distance (in meters) within which to return place results. Note that setting a radius biases results to the indicated area, but may not fully restrict results to the specified area.
  ///
  /// If this value is provided, `location` must be provided aswell.
  ///
  /// See [Location Biasing and Location Restrict](https://developers.google.com/places/web-service/autocomplete#location_biasing) in the documentation.
  final int? radius;

  /// Returns only those places that are strictly within the region defined by location and radius. This is a restriction, rather than a bias, meaning that results outside this region will not be returned even if they match the user input.
  final bool strictBounds;

  /// The icon to show in the search box
  final Widget? icon;

  @override
  _SearchMapPlaceWidgetState createState() => _SearchMapPlaceWidgetState();
}

class _SearchMapPlaceWidgetState extends State<SearchMapPlaceWidget>
    with SingleTickerProviderStateMixin {
  TextEditingController _textEditingController = TextEditingController();
  FocusNode _focusNode = FocusNode();
  AnimationController? _animationController;

  // SearchContainer height.
  Animation? _containerHeight;

  // Place options opacity.
  Animation? _listOpacity;

  List<dynamic> _placePredictions = [];
  Place? _selectedPlace;
  Geocoding? geocode;
  double dynamicheigh = 45;

  @override
  void initState() {
    _selectedPlace = null;
    _placePredictions = [];
    geocode = Geocoding(apiKey: widget.apiKey, language: widget.language);
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _containerHeight = Tween<double>(begin: 55, end: 360).animate(
      CurvedAnimation(
        curve: Interval(0.0, 0.5, curve: Curves.easeInOut),
        parent: _animationController!,
      ),
    );
    _listOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        curve: Interval(0.5, 1.0, curve: Curves.easeInOut),
        parent: _animationController!,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: dynamicheigh + 15,
        child: _searchContainer(
          child: _searchInput(context),
        ),
      );

  // Widgets
  Widget _searchContainer({required Widget child}) {
    Widget _noData = Container();
    if (_textEditingController.text.trim().length == 0 &&
        _placePredictions.length == 0) {
      _noData = Container();
    }
    /*else if(_textEditingController.text.trim().length > 0 && _placePredictions.length == 0){
      _noData = Container(
        margin: EdgeInsets.only(
          top: _containerHeight.value / 2.5,
          right: 20.0,
          left: 20.0
        ),
        child: Center(
          child: Text(widget.noPlacesErrorMessage + ' " ' + _textEditingController.text + ' "',
          style: widget.noPlacesErrorMessageStyle,
          textAlign: TextAlign.center,),
        ),
      );
    }*/
    else {
      _noData = Container();
    }
    return AnimatedBuilder(
        animation: _animationController!,
        builder: (context, _) {
          return Container(
            height: _containerHeight!.value + 9,
            decoration: _containerDecoration(),
            padding: EdgeInsets.only(left: 0, right: 0, top: 0),
            alignment: Alignment.topCenter,
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: child,
                ),
                Opacity(
                  opacity: _listOpacity!.value,
                  child: _placePredictions.length == 0
                      ? _noData
                      : _textEditingController.text.trim().length == 0
                          ? Container()
                          : Column(
                              //shrinkWrap: true,
                              children: _placePredictions
                                  .asMap()
                                  .map((index, prediction) {
                                    return MapEntry(
                                        index,
                                        _placeOption(Place.fromJSON(
                                            prediction, geocode!)));
                                  })
                                  .values
                                  .toList(),
                            ),
                ),
              ],
            ),
          );
        });
  }

  Future<Null> clearPlaces() async {
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      _placePredictions = [];
    });
    _animationController!.reverse();
  }

  Widget _searchInput(BuildContext context) {
    return Center(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: TextField(
                focusNode: _focusNode,
                decoration: _inputStyle(),
                controller: _textEditingController,
                style: widget.searchStyle,
                onChanged: (value) {
                  if (value.trim().length == 0) {
                    setState(() {
                      dynamicheigh = MediaQuery.of(context).size.height * .048;
                    });
                  } else {
                    _autocompletePlace(value);
                    setState(() {
                      dynamicheigh = MediaQuery.of(context).size.height * .4;
                    });
                  }
                } //setState(() => _autocompletePlace(value)),
                ),
          ),
          Container(width: 15),
          GestureDetector(
            child: this.widget.icon,
            //onTap: () => widget.onSearch(Place.fromJSON(_selectedPlace, geocode)),
            onTap: () =>
                widget.onSearch!(_textEditingController.text, clearPlaces()),
          )
        ],
      ),
    );
  }

  Widget _placeOption(Place prediction) {
    String? place = prediction.description;

    return MaterialButton(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      onPressed: () => _selectPlace(prediction),
      child: ListTile(
        title: Text(
          place!.length < 45
              ? "$place"
              : "${place.replaceRange(45, place.length, "")} ...",
          style: widget.placesStyle,
          maxLines: 1,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 0,
          vertical: 0,
        ),
      ),
    );
  }

  // Styling
  InputDecoration _inputStyle() {
    return InputDecoration(
      hintText: this.widget.placeholder,
      hintStyle: widget.searchHintStyle,
      contentPadding: EdgeInsets.all(0),
      border: InputBorder.none,
    );
  }

  BoxDecoration _containerDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(6.0)),
      boxShadow: [
        BoxShadow(color: Colors.black12, blurRadius: 20, spreadRadius: 10)
      ],
    );
  }

  // Methods
  void _autocompletePlace(String input) async {
    /// Will be called everytime the input changes. Making callbacks to the Places
    /// Api and giving the user Place options
    if (input.trim().length > 0) {
      String url =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=${widget.apiKey}&language=${widget.language}";
      if (widget.location != null && widget.radius != null) {
        url +=
            "&location=${widget.location!.latitude},${widget.location!.longitude}&radius=${widget.radius}";
        if (widget.strictBounds) {
          url += "&strictbounds";
        }
      }
      final response = await http.get(Uri.parse(url));
      final json = JSON.jsonDecode(response.body);

      if (json["error_message"] != null) {
        var error = json["error_message"];
        if (error == "This API project is not authorized to use this API.")
          error +=
              " Make sure the Places API is activated on your Google Cloud Platform";
        throw Exception(error);
      } else {
        final predictions = json["predictions"];
        await _animationController!.animateTo(0.5);
        setState(() => _placePredictions = predictions);
        await _animationController!.forward();
      }
    } else {
      await _animationController!.animateTo(0.5);
      setState(() => _placePredictions = []);
      await _animationController!.reverse();
    }
  }

  void _selectPlace(Place prediction) async {
    /// Will be called when a user selects one of the Place options.
    // Sets TextField value to be the location selected
    _textEditingController.value = TextEditingValue(
      text: prediction.description!,
      selection:
          TextSelection.collapsed(offset: prediction.description!.length),
    );
    FocusScope.of(context).requestFocus(FocusNode());
    // Makes animation
    await _animationController!.animateTo(0.5);
    setState(() {
      _placePredictions = [];
      _selectedPlace = prediction;
    });
    _animationController!.reverse();

    // Calls the `onSelected` callback
    widget.onSelected!(prediction);
    setState(() {
      dynamicheigh = dynamicheigh = MediaQuery.of(context).size.height * .05;
    });
  }
}
