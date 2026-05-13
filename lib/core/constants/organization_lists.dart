class OrganizationLists {
  OrganizationLists._();

  static const List<String> organizationTypes = [
    'Exco',
    'Club',
  ];

  static const List<String> excoNames = [
    'Exco Sukan',
    'Exco Akademik',
    'Exco Kerohanian',
    'Exco Kebajikan',
    'Exco Keusahawanan',
    'Exco Kebudayaan',
    'Exco Keselamatan',
    'Exco Dokumentasi',
  ];

  static const List<String> clubNames = [
    'Kirana Razak',
    'Senimas',
    'RASREC',
    'INVICTUS',
    'KSTAR',
    'UNLOC',
  ];

  static List<String> getOrganizationsByType(String organizationType) {
    switch (organizationType.toLowerCase()) {
      case 'exco':
        return excoNames;
      case 'club':
        return clubNames;
      default:
        return [];
    }
  }
}