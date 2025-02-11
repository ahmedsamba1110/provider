class CountryCodeModel {
  final String name;
  final String flag;
  final String countryCode;
  final String callingCode;

  const CountryCodeModel(this.name, this.flag, this.countryCode, this.callingCode);

  factory CountryCodeModel.fromJson(Map<String, dynamic> json) {
    return  CountryCodeModel(
      json['name'] as String,
      json['flag'] as String,
      json['country_code'] as String,
      json['calling_code'] as String,
    );
  }
}
