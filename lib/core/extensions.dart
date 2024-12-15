import 'package:webfeed_revised/domain/atom_person.dart';

extension CapitalizeFirstLetter on String {
  String capitalizeFirst() {
    if (isEmpty) {
      return this;
    }
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}

extension UrlToAtom on AtomPerson {
  String? getAtomUrl() {
    if (uri == null) return null;
    return uri!.endsWith('.atom') ? uri : '$uri.atom';
  }
}
