// Utility classes and functions
part of staff_management;

// Load XML data 
void loadXML(String filename) {
  List<String> xmlcontents = [];
  File file = new File(filename);
  file.readAsString().then((content) {
		xmlcontents.add(content);
		var completer = new Completer();
        completer.complete(xmlcontents);
        return completer.future;
  }).then((contents) {
        xmlDoc = XML.parse( xmlcontents.join(' ') );
  });	
}

// delete staffs data from XML by taking out their id attribute
// can be recovered later
void deleteStaffsFromXML(String ids, String filename) {
   File file = new File(filename);
   String contents = file.readAsStringSync();
   RegExp staffPatt;
   ids.split(',').forEach((id) {
     String patt = "<staff id='${id}' deleted='false'>";
     staffPatt = new RegExp(patt, multiLine:true);
     contents = contents.replaceAll(staffPatt, "<staff id='${id}' deleted='true'>");
   });
   file.writeAsStringSync(contents);

   loadXML(filename);
}

// Parse request uri to extract parameter values
class UriParamParser {
  static final RegExp startPatt = new RegExp(r"start=\d+");
  static final RegExp countPatt = new RegExp(r"count=\d+");
  static final RegExp keywordPatt = new RegExp(r"keyword=[\w\s]+");
  static final RegExp staff_idsPatt = new RegExp(r"staff_ids=[\d,]+");
  
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
}