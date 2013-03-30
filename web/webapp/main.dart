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

// read staffs data including searching 
void loadStaffsInfo(HttpConnect connect) {
  // process request uri
  String uri = decodeUriComponent(connect.request.uri.toString());
  int start = UriParamParser.getStart(uri);
  int count = UriParamParser.getCount(uri);
  String keyword = UriParamParser.getKeyword(uri);
  // call dao to perform business logic
  String jsonResponse
		   = (keyword == null) ? dao.getStaffs(start, count):dao.searchStaffs(start, count, keyword);
  // send response back to client, "json" as default type
  sendResponse(connect, jsonResponse);
}

void deleteStaffsInfo(HttpConnect connect) {
  // process request uri
  String uri = decodeUriComponent(connect.request.uri.toString());
  String staff_ids = UriParamParser.getStaff_ids(uri);
  // call dao to perform business logic
  String jsonResponse = dao.deleteStaffsByIDs(staff_ids); 
  sendResponse(connect, jsonResponse);
}

void recoverStaffsInfo(HttpConnect connect) {
  // process request uri
  String uri = decodeUriComponent(connect.request.uri.toString());
  int start = UriParamParser.getStart(uri);
  int count = UriParamParser.getCount(uri);
  // call dao to perform business logic
  dao.recoverStaffs();
  
  String jsonResponse = dao.getStaffs(start, count); 
  sendResponse(connect, jsonResponse);
}

void sendResponse(HttpConnect connect, String response, {String type:"json"}) {
  connect.response
    ..headers.contentType = contentTypes[type]
    ..write(response);
  connect.close();
}

void addNewStaff(HttpConnect connect) {
  // process request uri
  String uri = decodeUriComponent(connect.request.uri.toString());
  int employeeNo = UriParamParser.getEmployeeNo(uri);
  String name = UriParamParser.getName(uri);
  String position = UriParamParser.getPosition(uri);
  int yearJoin = UriParamParser.getYear(uri);
  
  // call dao to perform business logic
  dao.addNewStaff(employeeNo, name, position, yearJoin);
  
  String jsonResponse = dao.searchStaffs(0, 0, name);
  sendResponse(connect, jsonResponse);
}
