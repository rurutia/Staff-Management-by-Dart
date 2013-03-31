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
  String uri = decodeUriComponent(connect.request.uri.toString());
  
  // Dart MongoDB test, experimental codes which will be improved in future
  // Feel free to comment out to ignore MongoDB part of the application 
  if( uri.contains('mongo') ) {
  	DaoMongoDBImpl daoMongo = 
   	     new DaoMongoDBImpl('mongodb://127.0.0.1', 'mongo-dart-test', 'staffs');
    var future = daoMongo.getStaffs();
    future.then((results) {
   	  String str = results;
      sendResponse(connect, str);   
    });  
    return;
  }
  
  // back to normal flow
  // process request uri
  int start = UriParamParser.getStart(uri);
  int count = UriParamParser.getCount(uri);
  String keyword = UriParamParser.getKeyword(uri);
  // call dao to perform business logic
  String jsonResponse
		   = (keyword == null) ? dao.getStaffs(start, count):dao.searchStaffs(start, count, keyword);
  
   // DaoMongoDBImpl daoMongo = 
//    	     new DaoMongoDBImpl('mongodb://127.0.0.1', 'mongo_dart-test', 'forsave1');
//    var future = daoMongo.getStaffs();
//    future.then((results) {
//    	 String str = results;
//      sendResponse(connect, str);   
//    });  
   // send response back to client, "json" as default type  
   sendResponse(connect, jsonResponse);
}

Future mongo(){
  Db db = new Db('mongodb://127.0.0.1/mongo_dart-test');
  DbCollection coll = db.collection('forsave1');
  Map data = {};
  var completer = new Completer();
  simpleUpdate() {
   
    coll.remove();
    List toInsert =  [
                                 {
                                   "_id": "1",
                                   "-deleted": "true",
                                   "employeeno": "101",
                                   "name": "Michael Yu",
                                   "position": "Developer",
                                   "yearjoin": "2013"
                                 },
                                 {
                                   "_id": "2",
                                   "-deleted": "true",
                                   "employeeno": "102",
                                   "name": "Steve Jones",
                                   "position": "Project Manager",
                                   "yearjoin": "2006"
                                 },
                                 {
                                   "_id": "3",
                                   "-deleted": "true",
                                   "employeeno": "103",
                                   "name": "Bernard Kean",
                                   "position": "Database Admin",
                                   "yearjoin": "2010"
                                 },
                                 {
                                   "_id": "4",
                                   "-deleted": "true",
                                   "employeeno": "104",
                                   "name": "Julia Anderson",
                                   "position": "Payroll Accountant",
                                   "yearjoin": "2011"
                                 },
                                 {
                                   "_id": "5",
                                   "-deleted": "true",
                                   "employeeno": "105",
                                   "name": "Bill Nielson",
                                   "position": "Senior Developer",
                                   "yearjoin": "2004"
                                 },
                                 {
                                   "_id": "6",
                                   "-deleted": "false",
                                   "employeeno": "106",
                                   "name": "Rubin Antler",
                                   "position": "Software Tester",
                                   "yearjoin": "2010"
                                 },
                                 {
                                   "_id": "7",
                                   "-deleted": "false",
                                   "employeeno": "107",
                                   "name": "Mark Kidman",
                                   "position": "UI Designer",
                                   "yearjoin": "1999"
                                 },
                                 {
                                   "_id": "8",
                                   "-deleted": "false",
                                   "employeeno": "108",
                                   "name": "William Chin",
                                   "position": "Operator",
                                   "yearjoin": "2009"
                                 }
                                 
                      ];
    coll.insertAll(toInsert);
  };
  
  handle(doc) { 
      Map staff = {};
      staff['employeeno'] = doc['employeeno'];
      staff['name'] = doc['name'];
      staff['position'] = doc['position'];
      staff['yearjoin'] = doc['yearjoin'];
      data[doc['_id']] = staff;
  }
  
  db.open().then((c)=>simpleUpdate())
  .then((c) {
    return coll.find().each( (doc) => handle(doc) );
  }).then((val) {
    db.close();
    
    data['total'] = data.length;
    data['next'] = true;
// 	print(Json.stringify(data));
	completer.complete(Json.stringify(data));
// 	return Json.stringify(data);
    
  });
  return completer.future;
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
