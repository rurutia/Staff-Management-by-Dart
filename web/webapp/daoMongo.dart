// Concrete Dao class using MongoDB as data store
part of staff_management;

// concrete DAO class (MongoDB implementation)
class DaoMongoDBImpl {
   // initial documents in database
   List _documents = [
                                 {
                                   "_id": "1",
                                   "-deleted": "false",
                                   "employeeno": "mongo101",
                                   "name": "Michael Yu",
                                   "position": "Developer",
                                   "yearjoin": "2013"
                                 },
                                 {
                                   "_id": "2",
                                   "-deleted": "false",
                                   "employeeno": "mongo102",
                                   "name": "Steve Jones",
                                   "position": "Project Manager",
                                   "yearjoin": "2006"
                                 },
                                 {
                                   "_id": "3",
                                   "-deleted": "false",
                                   "employeeno": "mongo103",
                                   "name": "Bernard Kean",
                                   "position": "Database Admin",
                                   "yearjoin": "2010"
                                 },
                                 {
                                   "_id": "4",
                                   "-deleted": "false",
                                   "employeeno": "mongo104",
                                   "name": "Julia Anderson",
                                   "position": "Payroll Accountant",
                                   "yearjoin": "2011"
                                 },
                                 {
                                   "_id": "5",
                                   "-deleted": "false",
                                   "employeeno": "mongo105",
                                   "name": "Bill Nielson",
                                   "position": "Senior Developer",
                                   "yearjoin": "2004"
                                 },
                                 {
                                   "_id": "6",
                                   "-deleted": "false",
                                   "employeeno": "mongo106",
                                   "name": "Rubin Antler",
                                   "position": "Software Tester",
                                   "yearjoin": "2010"
                                 },
                                 {
                                   "_id": "7",
                                   "-deleted": "false",
                                   "employeeno": "mongo107",
                                   "name": "Mark Kidman",
                                   "position": "UI Designer",
                                   "yearjoin": "1999"
                                 },
                                 {
                                   "_id": "8",
                                   "-deleted": "false",
                                   "employeeno": "mongo108",
                                   "name": "William Chin",
                                   "position": "Operator",
                                   "yearjoin": "2009"
                                 }
                                 
                      ];
   
   List get documents => this._documents;
   set data(List documents) => this._documents = documents;
   
   Db db;
   DbCollection coll;
   // constructor to initialize database and collection 
   DaoMongoDBImpl(String host, String db_name, String collection) {
   	 db = new Db('$host/$db_name');
   	 coll = db.collection(collection);
   	 db.open().then((c){
	   // load original staff data into database, reset it every time before use
	   coll.remove();
	   coll.insertAll(documents);
	 }).then((c){
	   db.close();
	 });
   }

   Future getStaffs(int start, int count) {
	  Map data = {};
	  var completer = new Completer();
	  int end;
	  int staffs_total;
	  // internal helping function to retrieve every staff document and build a map
	  build_map(doc) { 
		  Map staff = {};
		  staff['employeeno'] = doc['employeeno'];
		  staff['name'] = doc['name'];
		  staff['position'] = doc['position'];
		  staff['yearjoin'] = doc['yearjoin'];
		  data[doc['_id']] = staff;
	  }
  	  
	  db.open().then((c) {
	  	// get total documents in "staffs" collection
    	return coll.count(where.gt("_id", "0"));
	  }).then((total) {
	    staffs_total = total;
	    end = (start + count ) > staffs_total ? staffs_total : (start + count);
	    
	    // iterate through documents within range of ids in collection and put into the map
		return coll.find(where.inRange("_id", (++start).toString(), end.toString(), minInclude:true, maxInclude:true)).each( (doc) => build_map(doc) );
	  }).then((val) {
	    data['total'] = staffs_total;
		if( (--start) > 0 ) data['previous'] = true;
        if( end < staffs_total ) data['next'] = true;
		data['mongoDB'] = true;
		db.close();	
		
		// convert data map to Json string
		completer.complete(Json.stringify(data));
	  });
	  return completer.future;
	}

  Future deleteStaffsByIDs(List<String> ids) {
    Map data = {};
  	var completer = new Completer();
  	db.open().then((c){
	   for(var id in ids) {
	   	 coll.remove({"_id": id});
	   };
	}).then((c){
	   data['deleted_staff_ids'] = ids;
	   completer.complete(Json.stringify(data));
	   db.close();
	}); 	
  	return completer.future;
  }

}
