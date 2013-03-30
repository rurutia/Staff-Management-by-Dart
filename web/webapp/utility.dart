// Utility classes and functions
part of staff_management;

// Parse request uri to extract parameter values
class UriParamParser {
  static final RegExp startPatt = new RegExp(r"start=\d+");
  static final RegExp countPatt = new RegExp(r"count=\d+");
  static final RegExp keywordPatt = new RegExp(r"keyword=[\w\s]+");
  static final RegExp staff_idsPatt = new RegExp(r"staff_ids=[\d,]+");
  static final RegExp employeeNoPatt = new RegExp(r"no=\d+");
  static final RegExp namePatt = new RegExp(r"name=[\w\s]+");
  static final RegExp positionPatt = new RegExp(r"position=[\w\s]+");
  static final RegExp yearPatt = new RegExp(r"year=[\w\s]+");
  
  static int getStart(String uri) {
    int start;
    for(var match in startPatt.allMatches(uri)) {
      start = int.parse(match.group(0).split("=")[1]);
    }
    return start;
  }
  
  static int getCount(String uri) {
    int count;
    for(var match in countPatt.allMatches(uri)) {
      count = int.parse(match.group(0).split("=")[1]);
    }
    return count;
  }
  
  static String getKeyword(String uri) {
    String keyword;
    for(var match in keywordPatt.allMatches(uri)) {
      keyword = match.group(0).split("=")[1];
    }
    return keyword;
  }
  
  static String getStaff_ids(String uri) {
    String staff_ids;
    for(var match in staff_idsPatt.allMatches(uri)) {
      staff_ids = match.group(0).split("=")[1];
    }
    return staff_ids;
  }
  
  static int getEmployeeNo(String uri) {
    int employeeNo;
    for(var match in employeeNoPatt.allMatches(uri)) {
      employeeNo = int.parse(match.group(0).split("=")[1]);
    }
    return employeeNo;
  }
  
  static String getName(String uri) {
    String name;
    for(var match in namePatt.allMatches(uri)) {
      name = match.group(0).split("=")[1];
    }
    return name;
  }
  
  static String getPosition(String uri) {
    String position;
    for(var match in positionPatt.allMatches(uri)) {
      position = match.group(0).split("=")[1];
    }
    return position;
  }
  
  static int getYear(String uri) {
    int year;
    for(var match in yearPatt.allMatches(uri)) {
      year = int.parse(match.group(0).split("=")[1]);
    }
    return year;
  }
}