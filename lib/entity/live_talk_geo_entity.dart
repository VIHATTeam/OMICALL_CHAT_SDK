/// geoplugin_request : "171.244.236.86"
/// geoplugin_status : 200
/// geoplugin_delay : "1ms"
/// geoplugin_credit : "Some of the returned data includes GeoLite data created by MaxMind, available from <a href='http://www.maxmind.com'>http://www.maxmind.com</a>."
/// geoplugin_city : "Ho Chi Minh City"
/// geoplugin_region : "Ho Chi Minh"
/// geoplugin_regionCode : "SG"
/// geoplugin_regionName : "Ho Chi Minh"
/// geoplugin_areaCode : ""
/// geoplugin_dmaCode : ""
/// geoplugin_countryCode : "VN"
/// geoplugin_countryName : "Vietnam"
/// geoplugin_inEU : 0
/// geoplugin_euVATrate : false
/// geoplugin_continentCode : "AS"
/// geoplugin_continentName : "Asia"
/// geoplugin_latitude : "10.8326"
/// geoplugin_longitude : "106.6581"
/// geoplugin_locationAccuracyRadius : "5"
/// geoplugin_timezone : "Asia/Ho_Chi_Minh"
/// geoplugin_currencyCode : "VND"
/// geoplugin_currencySymbol : "₫"
/// geoplugin_currencySymbol_UTF8 : "₫"
/// geoplugin_currencyConverter : 23489

class LiveTalkGeoEntity {
  LiveTalkGeoEntity({
      this.geopluginRequest, 
      this.geopluginStatus, 
      this.geopluginDelay, 
      this.geopluginCredit, 
      this.geopluginCity, 
      this.geopluginRegion, 
      this.geopluginRegionCode, 
      this.geopluginRegionName, 
      this.geopluginAreaCode, 
      this.geopluginDmaCode, 
      this.geopluginCountryCode, 
      this.geopluginCountryName, 
      this.geopluginInEU, 
      this.geopluginEuVATrate, 
      this.geopluginContinentCode, 
      this.geopluginContinentName, 
      this.geopluginLatitude, 
      this.geopluginLongitude, 
      this.geopluginLocationAccuracyRadius, 
      this.geopluginTimezone, 
      this.geopluginCurrencyCode, 
      this.geopluginCurrencySymbol, 
      this.geopluginCurrencySymbolUTF8, 
      this.geopluginCurrencyConverter,});

  LiveTalkGeoEntity.fromJson(dynamic json) {
    geopluginRequest = json['geoplugin_request'];
    geopluginStatus = json['geoplugin_status'];
    geopluginDelay = json['geoplugin_delay'];
    geopluginCredit = json['geoplugin_credit'];
    geopluginCity = json['geoplugin_city'];
    geopluginRegion = json['geoplugin_region'];
    geopluginRegionCode = json['geoplugin_regionCode'];
    geopluginRegionName = json['geoplugin_regionName'];
    geopluginAreaCode = json['geoplugin_areaCode'];
    geopluginDmaCode = json['geoplugin_dmaCode'];
    geopluginCountryCode = json['geoplugin_countryCode'];
    geopluginCountryName = json['geoplugin_countryName'];
    geopluginInEU = json['geoplugin_inEU'];
    geopluginEuVATrate = json['geoplugin_euVATrate'];
    geopluginContinentCode = json['geoplugin_continentCode'];
    geopluginContinentName = json['geoplugin_continentName'];
    geopluginLatitude = json['geoplugin_latitude'];
    geopluginLongitude = json['geoplugin_longitude'];
    geopluginLocationAccuracyRadius = json['geoplugin_locationAccuracyRadius'];
    geopluginTimezone = json['geoplugin_timezone'];
    geopluginCurrencyCode = json['geoplugin_currencyCode'];
    geopluginCurrencySymbol = json['geoplugin_currencySymbol'];
    geopluginCurrencySymbolUTF8 = json['geoplugin_currencySymbol_UTF8'];
    geopluginCurrencyConverter = json['geoplugin_currencyConverter'];
  }
  String? geopluginRequest;
  int? geopluginStatus;
  String? geopluginDelay;
  String? geopluginCredit;
  String? geopluginCity;
  String? geopluginRegion;
  String? geopluginRegionCode;
  String? geopluginRegionName;
  String? geopluginAreaCode;
  String? geopluginDmaCode;
  String? geopluginCountryCode;
  String? geopluginCountryName;
  int? geopluginInEU;
  bool? geopluginEuVATrate;
  String? geopluginContinentCode;
  String? geopluginContinentName;
  String? geopluginLatitude;
  String? geopluginLongitude;
  String? geopluginLocationAccuracyRadius;
  String? geopluginTimezone;
  String? geopluginCurrencyCode;
  String? geopluginCurrencySymbol;
  String? geopluginCurrencySymbolUTF8;
  int? geopluginCurrencyConverter;
LiveTalkGeoEntity copyWith({  String? geopluginRequest,
  int? geopluginStatus,
  String? geopluginDelay,
  String? geopluginCredit,
  String? geopluginCity,
  String? geopluginRegion,
  String? geopluginRegionCode,
  String? geopluginRegionName,
  String? geopluginAreaCode,
  String? geopluginDmaCode,
  String? geopluginCountryCode,
  String? geopluginCountryName,
  int? geopluginInEU,
  bool? geopluginEuVATrate,
  String? geopluginContinentCode,
  String? geopluginContinentName,
  String? geopluginLatitude,
  String? geopluginLongitude,
  String? geopluginLocationAccuracyRadius,
  String? geopluginTimezone,
  String? geopluginCurrencyCode,
  String? geopluginCurrencySymbol,
  String? geopluginCurrencySymbolUTF8,
  int? geopluginCurrencyConverter,
}) => LiveTalkGeoEntity(  geopluginRequest: geopluginRequest ?? this.geopluginRequest,
  geopluginStatus: geopluginStatus ?? this.geopluginStatus,
  geopluginDelay: geopluginDelay ?? this.geopluginDelay,
  geopluginCredit: geopluginCredit ?? this.geopluginCredit,
  geopluginCity: geopluginCity ?? this.geopluginCity,
  geopluginRegion: geopluginRegion ?? this.geopluginRegion,
  geopluginRegionCode: geopluginRegionCode ?? this.geopluginRegionCode,
  geopluginRegionName: geopluginRegionName ?? this.geopluginRegionName,
  geopluginAreaCode: geopluginAreaCode ?? this.geopluginAreaCode,
  geopluginDmaCode: geopluginDmaCode ?? this.geopluginDmaCode,
  geopluginCountryCode: geopluginCountryCode ?? this.geopluginCountryCode,
  geopluginCountryName: geopluginCountryName ?? this.geopluginCountryName,
  geopluginInEU: geopluginInEU ?? this.geopluginInEU,
  geopluginEuVATrate: geopluginEuVATrate ?? this.geopluginEuVATrate,
  geopluginContinentCode: geopluginContinentCode ?? this.geopluginContinentCode,
  geopluginContinentName: geopluginContinentName ?? this.geopluginContinentName,
  geopluginLatitude: geopluginLatitude ?? this.geopluginLatitude,
  geopluginLongitude: geopluginLongitude ?? this.geopluginLongitude,
  geopluginLocationAccuracyRadius: geopluginLocationAccuracyRadius ?? this.geopluginLocationAccuracyRadius,
  geopluginTimezone: geopluginTimezone ?? this.geopluginTimezone,
  geopluginCurrencyCode: geopluginCurrencyCode ?? this.geopluginCurrencyCode,
  geopluginCurrencySymbol: geopluginCurrencySymbol ?? this.geopluginCurrencySymbol,
  geopluginCurrencySymbolUTF8: geopluginCurrencySymbolUTF8 ?? this.geopluginCurrencySymbolUTF8,
  geopluginCurrencyConverter: geopluginCurrencyConverter ?? this.geopluginCurrencyConverter,
);
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['geoplugin_request'] = geopluginRequest;
    map['geoplugin_status'] = geopluginStatus;
    map['geoplugin_delay'] = geopluginDelay;
    map['geoplugin_credit'] = geopluginCredit;
    map['geoplugin_city'] = geopluginCity;
    map['geoplugin_region'] = geopluginRegion;
    map['geoplugin_regionCode'] = geopluginRegionCode;
    map['geoplugin_regionName'] = geopluginRegionName;
    map['geoplugin_areaCode'] = geopluginAreaCode;
    map['geoplugin_dmaCode'] = geopluginDmaCode;
    map['geoplugin_countryCode'] = geopluginCountryCode;
    map['geoplugin_countryName'] = geopluginCountryName;
    map['geoplugin_inEU'] = geopluginInEU;
    map['geoplugin_euVATrate'] = geopluginEuVATrate;
    map['geoplugin_continentCode'] = geopluginContinentCode;
    map['geoplugin_continentName'] = geopluginContinentName;
    map['geoplugin_latitude'] = geopluginLatitude;
    map['geoplugin_longitude'] = geopluginLongitude;
    map['geoplugin_locationAccuracyRadius'] = geopluginLocationAccuracyRadius;
    map['geoplugin_timezone'] = geopluginTimezone;
    map['geoplugin_currencyCode'] = geopluginCurrencyCode;
    map['geoplugin_currencySymbol'] = geopluginCurrencySymbol;
    map['geoplugin_currencySymbol_UTF8'] = geopluginCurrencySymbolUTF8;
    map['geoplugin_currencyConverter'] = geopluginCurrencyConverter;
    return map;
  }

}