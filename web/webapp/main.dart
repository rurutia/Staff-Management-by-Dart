// Server side code
library staff_management;

import "dart:json" as Json;
import "dart:io";
import "package:stream/stream.dart";
import "package:xml/xml.dart";

part "config.dart";
part "utility.dart";

// XML contents
List<String> xmlcontents = [];

void loadStaffsInfo(HttpConnect connect) {
  String uri = connect.request.uri.toString();
  int start = UriParamParser.getStart(uri);
  int count = UriParamParser.getCount(uri);
  
  String jsonResponse = getStaffsFromXML(start, count);

  connect.response
    ..headers.contentType = contentTypes["json"]
    ..write(jsonResponse);
    //..write(u.toString());
  connect.close();
}

void main() {
  new StreamServer(uriMapping: _mapping).start();
  // load XML which contains staffs information
  loadXML('webapp/data.xml');
}

String getStaffsFromXML(int start, int count) {
   // get all staff nodes from XML
   XmlElement xmlDoc = XML.parse( xmlcontents.join(' ') );	
   Map allNodes = xmlDoc.queryAll("staff").asMap();

   // staff start index can not be more than the number of staffs in XML
   if( start >= allNodes.length) 
     return "Error: can not list staffs from the index specified.";
   // staff end index can not be more than the number of staffs in XML
   int end = (start + count - 1) > allNodes.length ? allNodes.length : (start + count);
   // if count is 0, get all staff records
   if( count == 0 ) end = allNodes.length;
    
   // Parse XML into JSON map 
   Map data = {};
     for(var i = start;i < end; i++) {
      Map map = {};
      for(var j = 0;j < allNodes[i].children.length; j++) {
       String tag = allNodes[i].children[j].name;
       String text =allNodes[i].children[j].text;
       map[tag] = text;
      }
      data[i.toString()] = map; 
    }
  
  return Json.stringify(data);
}


