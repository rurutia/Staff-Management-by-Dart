// Server side code
library staff_management;

import "dart:json" as Json;
import "dart:io";
import "dart:uri";
import "dart:async";
import "package:stream/stream.dart";
import "package:xml/xml.dart";
import 'package:mongo_dart/mongo_dart.dart';

part "config.dart";
part "dao.dart";
part "daoXML.dart";
part "daoMongo.dart";
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
  UriParamParser parser = new UriParamParser(connect.request);
  int start = parser.getParamValue('start', type:UriParamParser.TYPE_INT);
  int count = parser.getParamValue('count', type:UriParamParser.TYPE_INT);
  String keyword = parser.getParamValue('keyword');
  
  // Dart MongoDB test, experimental codes which will be improved in future
  // Feel free to comment out to ignore MongoDB part of the application 
  if( parser.containsParam('mongo') ) {
    DaoMongoDBImpl daoMongo = new DaoMongoDBImpl('mongodb://127.0.0.1', 'mongo-dart-test', 'staffs');
    var future = daoMongo.getStaffs(start, count);
    future.then((results) {
   	  String str = results;
      sendResponse(connect, str);   
    });  
    return;
  }
  // back to normal flow
  
  // call dao to perform business logic
  String jsonResponse
		   = (keyword == null) ? dao.getStaffs(start, count):dao.searchStaffs(start, count, keyword);
 
   sendResponse(connect, jsonResponse);
}

void deleteStaffsInfo(HttpConnect connect) {
  // process request uri
  UriParamParser parser = new UriParamParser(connect.request);
  List<String> staff_ids = parser.getParamValue('staff_ids', 
  											type:UriParamParser.TYPE_LIST_STRING, 
  											pattern: new RegExp(","));
  											
  // Dart MongoDB test, experimental codes which will be improved in future
  // Feel free to comment out to ignore MongoDB part of the application 
  if( parser.containsParam('mongo') ) { 
    DaoMongoDBImpl daoMongo = new DaoMongoDBImpl('mongodb://127.0.0.1', 'mongo-dart-test', 'staffs');	
    var future = daoMongo.deleteStaffsByIDs(staff_ids);
    future.then((results) {
   	  String str = results;
      sendResponse(connect, str);   
    });  
    return;
  }
  // back to normal flow

  // call dao to perform business logic
  String jsonResponse = dao.deleteStaffsByIDs(staff_ids); 
  sendResponse(connect, jsonResponse);
}

void recoverStaffsInfo(HttpConnect connect) {
  // process request uri
  UriParamParser parser = new UriParamParser(connect.request);
  int start = parser.getParamValue('start', type:UriParamParser.TYPE_INT);
  int count = parser.getParamValue('count', type:UriParamParser.TYPE_INT);
  // call dao to perform business logic
  dao.recoverStaffs();
  
  String jsonResponse = dao.getStaffs(start, count); 
  sendResponse(connect, jsonResponse);
}

void addNewStaff(HttpConnect connect) {
  // process request uri
  UriParamParser parser = new UriParamParser(connect.request);
  int employeeNo = parser.getParamValue('no', type:UriParamParser.TYPE_INT);
  String name = parser.getParamValue('name');
  String position = parser.getParamValue('position');
  int yearJoin = parser.getParamValue('year', type:UriParamParser.TYPE_INT);
  
  // call dao to perform business logic
  dao.addNewStaff(employeeNo, name, position, yearJoin);
  
  String jsonResponse = dao.searchStaffs(0, 0, name);
  sendResponse(connect, jsonResponse);
}

void sendResponse(HttpConnect connect, String response, {String type:"json"}) {
  connect.response
    ..headers.contentType = contentTypes[type]
    ..write(response);
  connect.close();
}
