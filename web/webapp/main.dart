// Server side code
library staff_management;

import "dart:json" as Json;
import "dart:io";
import "dart:uri";
import "dart:async";
import "package:stream/stream.dart";
import "package:xml/xml.dart";

part "config.dart";
part "dao.dart";
part "utility.dart";

// Data Access Object responsible for business logic and performing data operation
// both XML and database will be supported
Dao _dao;
Dao get dao => _dao;

void main() {
  new StreamServer(uriMapping: _mapping).start();
  // initialize Data Access Object with XML implementation, will be database in future
  _dao = new DaoXmlImpl('web/webapp/data.xml');
  // process XML file
  dao.processXML();
}

void loadStaffsInfo(HttpConnect connect) {
  String uri = decodeUriComponent(connect.request.uri.toString());
  int start = UriParamParser.getStart(uri);
  int count = UriParamParser.getCount(uri);
  String keyword = UriParamParser.getKeyword(uri);
  
  String jsonResponse;
  if(keyword == null)
    jsonResponse = dao.getStaffs(start, count);
  else 
    jsonResponse = dao.searchStaffs(start, count, keyword);

  connect.response
    ..headers.contentType = contentTypes["json"]
    ..write(jsonResponse);
  connect.close();
}

void deleteStaffsInfo(HttpConnect connect) {
  String uri = decodeUriComponent(connect.request.uri.toString());
  String staff_ids = UriParamParser.getStaff_ids(uri);
  
  String jsonResponse = dao.deleteStaffsByIDs(staff_ids);
  
  connect.response
    ..headers.contentType = contentTypes["json"]
    ..write(jsonResponse);
  connect.close();
}

void recoverStaffsInfo(HttpConnect connect) {
  String uri = decodeUriComponent(connect.request.uri.toString());
  int start = UriParamParser.getStart(uri);
  int count = UriParamParser.getCount(uri);
  
  dao.recoverStaffs();
  
  String jsonResponse = dao.getStaffs(start, count);
  
   connect.response
    ..headers.contentType = contentTypes["json"]
    ..write(jsonResponse);
  connect.close();
}
