List<String> capitalize(List<String> list) {
  for (var i = 0; i < list.length; i++) {
    var element = list[i].replaceAll('_', ' ').toLowerCase();
    var split = element.split('');
    split[0] = split[0].toUpperCase();
    list[i] = split.join('');
  }
  return list;
}

String underscore(String string) {
  return string.replaceAll(' ', '_');
}

String space(String string) {
  return string.replaceAll('_', ' ');
}
