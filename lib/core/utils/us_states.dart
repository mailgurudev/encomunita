/// US States list with 2-letter codes
class USStates {
  static const List<Map<String, String>> states = [
    {'code': 'AL', 'name': 'Alabama'},
    {'code': 'AK', 'name': 'Alaska'},
    {'code': 'AZ', 'name': 'Arizona'},
    {'code': 'AR', 'name': 'Arkansas'},
    {'code': 'CA', 'name': 'California'},
    {'code': 'CO', 'name': 'Colorado'},
    {'code': 'CT', 'name': 'Connecticut'},
    {'code': 'DE', 'name': 'Delaware'},
    {'code': 'FL', 'name': 'Florida'},
    {'code': 'GA', 'name': 'Georgia'},
    {'code': 'HI', 'name': 'Hawaii'},
    {'code': 'ID', 'name': 'Idaho'},
    {'code': 'IL', 'name': 'Illinois'},
    {'code': 'IN', 'name': 'Indiana'},
    {'code': 'IA', 'name': 'Iowa'},
    {'code': 'KS', 'name': 'Kansas'},
    {'code': 'KY', 'name': 'Kentucky'},
    {'code': 'LA', 'name': 'Louisiana'},
    {'code': 'ME', 'name': 'Maine'},
    {'code': 'MD', 'name': 'Maryland'},
    {'code': 'MA', 'name': 'Massachusetts'},
    {'code': 'MI', 'name': 'Michigan'},
    {'code': 'MN', 'name': 'Minnesota'},
    {'code': 'MS', 'name': 'Mississippi'},
    {'code': 'MO', 'name': 'Missouri'},
    {'code': 'MT', 'name': 'Montana'},
    {'code': 'NE', 'name': 'Nebraska'},
    {'code': 'NV', 'name': 'Nevada'},
    {'code': 'NH', 'name': 'New Hampshire'},
    {'code': 'NJ', 'name': 'New Jersey'},
    {'code': 'NM', 'name': 'New Mexico'},
    {'code': 'NY', 'name': 'New York'},
    {'code': 'NC', 'name': 'North Carolina'},
    {'code': 'ND', 'name': 'North Dakota'},
    {'code': 'OH', 'name': 'Ohio'},
    {'code': 'OK', 'name': 'Oklahoma'},
    {'code': 'OR', 'name': 'Oregon'},
    {'code': 'PA', 'name': 'Pennsylvania'},
    {'code': 'RI', 'name': 'Rhode Island'},
    {'code': 'SC', 'name': 'South Carolina'},
    {'code': 'SD', 'name': 'South Dakota'},
    {'code': 'TN', 'name': 'Tennessee'},
    {'code': 'TX', 'name': 'Texas'},
    {'code': 'UT', 'name': 'Utah'},
    {'code': 'VT', 'name': 'Vermont'},
    {'code': 'VA', 'name': 'Virginia'},
    {'code': 'WA', 'name': 'Washington'},
    {'code': 'WV', 'name': 'West Virginia'},
    {'code': 'WI', 'name': 'Wisconsin'},
    {'code': 'WY', 'name': 'Wyoming'},
    {'code': 'DC', 'name': 'District of Columbia'},
  ];

  /// Get list of state codes only
  static List<String> get stateCodes => states.map((state) => state['code']!).toList();

  /// Get list of state names only
  static List<String> get stateNames => states.map((state) => state['name']!).toList();

  /// Get state name from code
  static String? getStateName(String code) {
    final state = states.firstWhere(
      (state) => state['code'] == code.toUpperCase(),
      orElse: () => {},
    );
    return state['name'];
  }

  /// Get state code from name
  static String? getStateCode(String name) {
    final state = states.firstWhere(
      (state) => state['name']?.toLowerCase() == name.toLowerCase(),
      orElse: () => {},
    );
    return state['code'];
  }
}