class Filter {
  final String name;
  final List<double> matrixValues;

  Filter(this.name, this.matrixValues);
}

final Filter noFilter = Filter(
    'No Filter', [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0]);
final Filter year1977Filter = Filter('1977',
    [1, 0, 0, 0, 0, -0.4, 1.3, -0.4, 0.2, -0.1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0]);
final Filter adenFilter = Filter('Aden',
    [0.81, 0, 0, 0, 0, 0, 0.96, 0, 0, 0, 0, 0, 0.95, 0, 0, 0, 0, 0, 1, 0]);

final Filter brooklynFilter = Filter('Brooklyn',
    [0.37, 0, 0, 0, 0, 0, 0.82, 0, 0, 0, 0, 0, 0.8, 0, 0, 0, 0, 0, 1, 0]);
final Filter xProIIFilter = Filter('X-pro II',
    [0.66, 0, 0, 0, 0, 0, 0.87, 0, 0, 0, 0, 0, 0.76, 0, 0, 0, 0, 0, 0.5, 0]);

final Filter hudsonFilter = Filter('Hudson',
    [0.65, 0, 0, 0, 0, 0, 0.81, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0]);

final Filter waldenFilter = Filter('Walden',
    [0.42, 0, 0, 0, 0, 0, 0.73, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0.9, 0]);

final Filter sepiaFilter = Filter('Sepia', [
  0.39,
  0.769,
  0.189,
  0.0,
  0.0,
  0.349,
  0.686,
  0.168,
  0.0,
  0.0,
  0.272,
  0.534,
  0.131,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  1.0,
  0.0
]);

final Filter peachyFilter = Filter(
    'Peachy', [1, 0, 0, 0, 0, 0, .5, 0, 0, 0, 0, 0, 0, .5, 0, 0, 0, 0, 1, 0]);

final Filter vintageFilter = Filter('Vintage', [
  0.9,
  0.5,
  0.1,
  0.0,
  0.0,
  0.3,
  0.8,
  0.1,
  0.0,
  0.0,
  0.2,
  0.3,
  0.5,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  1.0,
  0.0
]);
final Filter sweetFilter = Filter('Sweet', [
  1.0,
  0.0,
  0.2,
  0.0,
  0.0,
  0.0,
  1.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  1.0,
  0.0,
  0.0,
  0.0,
  0.0,
  0.0,
  1.0,
  0.0
]);

final Filter coldLifeFilter = Filter('Cold Life',
    [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, -0.2, 0.2, 0.1, 0.4, 0, 0, 0, 0, 1, 0]);

final Filter sepiumFilter = Filter('Sepium', [
  1.3,
  -0.3,
  1.1,
  0,
  0,
  0,
  1.3,
  0.2,
  0,
  0,
  0,
  0,
  0.8,
  0.2,
  0,
  0,
  0,
  0,
  1,
  0
]);

final Filter milkFilter = Filter(
    'Milk', [0, 1.0, 0, 0, 0, 0, 1.0, 0, 0, 0, 0, 0.6, 1, 0, 0, 0, 0, 0, 1, 0]);

final Filter limeFilter = Filter(
    'Lime', [1, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, .5, 0, 0, 0, 0, 1, 0]);

final Filter greyLightFilter = Filter(
    'Grey Light', [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0]);

final Filter greyMediumFilter = Filter('Grey Medium',
    [0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0]);

final Filter greyDarkFilter = Filter(
    'Grey Dark', [0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0]);

final Filter lightenFilter = Filter('Lighten',
    [1.5, 0, 0, 0, 0, 0, 1.5, 0, 0, 0, 0, 0, 1.5, 0, 0, 0, 0, 0, 1, 0]);

final Filter darkenFilter = Filter('Darken',
    [0.5, 0, 0, 0, 0, 0, 0.5, 0, 0, 0, 0, 0, 0.5, 0, 0, 0, 0, 0, 1, 0]);

final Filter indigoFilter = Filter('Indigo',
    [0.29, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.51, 0, 0, 0, 0, 0, 1, 0]);

final Filter purpleFilter = Filter('Purple',
    [1, -0.2, 0, 0, 0, 0, 1, 0, -0.1, 0, 0, 1.2, 1, 0.1, 0, 0, 0, 1.7, 1, 0]);

final Filter blueFilter = Filter(
    'Blue', [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0]);
final Filter greenFilter = Filter(
    'Green', [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0]);
final Filter yellowFilter = Filter(
    'Yellow', [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0]);

final Filter lightYellowFilter = Filter('Light Yellow',
    [1, 0, 0, 0, 0, -0.2, 1.0, 0.3, 0.1, 0, -0.1, 0, 1, 0, 0, 0, 0, 0, 1, 0]);
final Filter orangeFilter = Filter(
    'Orange', [1, 0, 0, 0, 0, 0, 0.65, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0]);
final Filter redFilter =
    Filter('Red', [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0]);

final List<Filter> filters = [
  noFilter,
  year1977Filter,
  hudsonFilter,
  waldenFilter,
  sepiaFilter,
  peachyFilter,
  vintageFilter,
  sweetFilter,
  limeFilter,
  adenFilter,
  brooklynFilter,
  xProIIFilter,
  coldLifeFilter,
  sepiumFilter,
  milkFilter,
  greyLightFilter,
  greyMediumFilter,
  greyDarkFilter,
  lightenFilter,
  darkenFilter,
  indigoFilter,
  purpleFilter,
  blueFilter,
  greenFilter,
  lightYellowFilter,
  yellowFilter,
  orangeFilter,
  redFilter,
];
