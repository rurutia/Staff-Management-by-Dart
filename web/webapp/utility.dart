// Utility classes and functions
part of staff_management;

// Load XML data to List<String>
void loadXML(String filename) {
  File file = new File(filename);
  file.readAsString().then((content) {
		xmlcontents.add(content);
  });	
}

// Parse request uri to extract parameter values
class UriParamParser {
  static final RegExp startPatt = new RegExp(r"start=\d+");
  static final RegExp countPatt = new RegExp(r"count=\d+");
  
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
}