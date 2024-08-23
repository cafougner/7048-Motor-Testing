bool validIPv4Address(final String address) {
  try {
    Uri.parseIPv4Address(address);

    return true;
  }

  on FormatException {
    return false;
  }
}
