// Server side code
library staff_management;

import "dart:json" as Json;
import "dart:io";
import "dart:uri";
import "dart:async";
import "package:stream/stream.dart";
import "package:xml/xml.dart";

part "config.dart";
part "utility.dart";

// XML contents
XmlElement xmlDoc;

void loadStaffsInfo(HttpConnect connect) {
  String uri = decodeUriComponent(connect.request.uri.toString());
  int start = UriParamParser.getStart(uri);
  int count = UriParamParser.getCount(uri);
  String keyword = UriParamParser.getKeyword(uri);
  
  String jsonResponse;
  if(keyword == null)
    jsonResponse = getStaffsFromXML(start, count);
  else 
    jsonResponse = searchStaffsFromXML(start, count, keyword);

  connect.response
    ..headers.contentType = contentTypes["json"]
    ..write(jsonResponse);
  connect.close();
}

void deleteStaffsInfo(HttpConnect connect) {
  String uri = decodeUriComponent(connect.request.uri.toString());
  String staff_ids = UriParamParser.getStaff_ids(uri);
  
   String jsonResponse = deleteStaffsFromXML(staff_ids, 'web/webapp/data.xml');
  
  connect.response
    ..headers.contentType = contentTypes["json"]
    ..write(jsonResponse);
  connect.close();
}

void recoverStaffsInfo(HttpConnect connect) {
  String uri = decodeUriComponent(connect.request.uri.toString());
  int start = UriParamParser.getStart(uri);
  int count = UriParamParser.getCount(uri);
  
  recoverStaffsFromXML("web/webapp/data.xml");
  
  String jsonResponse = getStaffsFromXML(start, count);
  
   connect.response
    ..headers.contentType = contentTypes["json"]
    ..write(jsonResponse);
  connect.close();
}

void main() {
  new StreamServer(uriMapping: _mapping).start();
  // load XML which contains staffs information
  loadXML('web/webapp/data.xml');
}

String searchStaffsFromXML(int start, int count, String keyword) {
  Map allStaffs = xmlDoc.queryAll({'deleted':'false'}).asMap();
  
  int end;
  // if count is 0, get all staff records
  if( count == 0 ) end = allStaffs.length;
  // Parse XML into JSON map 
  Map data = {};  
  for(var i = start;i < end; i++) {
    Map attributes = {};
    bool isFound = false;
    for(var j = 0;j < allStaffs[i].children.length; j++) {
      String text = allStaffs[i].children[j].text;
      if( text.toLowerCase().contains(keyword.toLowerCase()) ) {
        isFound = true;
        text = text.toLowerCase().replaceAll(new RegExp(keyword.toLowerCase()), "<span class='keyword-found'>${keyword}</span>");
      }   
      String tag = allStaffs[i].children[j].name;
      attributes[tag] = text;      
    }
    if( !allStaffs[i].attributes.isEmpty && isFound ) 
    	data[allStaffs[i].attributes['id']] = attributes;

    isFound = false;
  }
  
  data['total'] = data.length;
  data['search'] = true;
  
  return Json.stringify(data);
}

String getStaffsFromXML(int start, int count) {
   // get all staff nodes from XML	
   Map allNodes = xmlDoc.queryAll({'deleted':'false'}).asMap();

   // staff start index can not be more than the number of staffs in XML
   if( start >= allNodes.length) 
     return "Error: can not list staffs from the index specified.";
   // staff end index can not be more than the number of staffs in XML
   int end = (start + count ) > allNodes.length ? allNodes.length : (start + count);
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
      if( !allNodes[i].attributes.isEmpty )
     	 data[allNodes[i].attributes['id']] = map; 
    }
  data['total'] = allNodes.length;
  
  if( start > 0 ) data['previous'] = true;
  if( end < allNodes.length ) data['next'] = true;
  return Json.stringify(data);
}


// delete staffs data from XML by taking out their id attribute
// can be recovered later
String deleteStaffsFromXML(String ids, String filename) {
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
   
   Map data = {}; 
   data['deleted_staff_ids'] = ids;
   return Json.stringify(data);
}

// recover staffs records in XML by changing staff "delete" attribute to false
void recoverStaffsFromXML(String filename) {
   File file = new File(filename);
   String contents = file.readAsStringSync();
   RegExp recoverPatt = new RegExp("deleted='true'", multiLine:true);
   contents = contents.replaceAll(recoverPatt, "deleted='false'");

   xmlDoc = XML.parse(contents);
   file.writeAsStringSync(contents);
   
}


