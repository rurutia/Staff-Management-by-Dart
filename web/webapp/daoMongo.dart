// Concrete Dao class using MongoDB as data store
part of staff_management;

// concrete DAO class (MongoDB implementation)
class DaoMongoDBImpl implements Dao {
   // initial documents in database
   List _documents = [
                                 {
                                   "_id": "1",
                                   "-deleted": "true",
                                   "employeeno": "mongo101",
                                   "name": "Michael Yu",
                                   "position": "Developer",
                                   "yearjoin": "2013"
                                 },
                                 {
                                   "_id": "2",
                                   "-deleted": "true",
                                   "employeeno": "mongo102",
                                   "name": "Steve Jones",
                                   "position": "Project Manager",
                                   "yearjoin": "2006"
                                 },
                                 {
                                   "_id": "3",
                                   "-deleted": "true",
                                   "employeeno": "mongo103",
                                   "name": "Bernard Kean",
                                   "position": "Database Admin",
                                   "yearjoin": "2010"
                                 },
                                 {
                                   "_id": "4",
                                   "-deleted": "true",
                                   "employeeno": "mongo104",
                                   "name": "Julia Anderson",
                                   "position": "Payroll Accountant",
                                   "yearjoin": "2011"
                                 },
                                 {
                                   "_id": "5",
                                   "-deleted": "true",
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
   
   String get documents => this._documents;
   set data(List documents) => this._documents = documents;
   
   Db db;
   DbCollection coll;
   // constructor to initialize database and collection 
   DaoMongoDBImpl(String host, String db_name, String collection) {
   	 db = new Db('$host/$db_name');
   	 coll = db.collection(collection);
   }

   Future getStaffs() {
	  Map data = {};
	  var completer = new Completer();
	  // internal helping function to retrieve every staff document and build a map
	  build_map(doc) { 
		  Map staff = {};
		  staff['employeeno'] = doc['employeeno'];
		  staff['name'] = doc['name'];
		  staff['position'] = doc['position'];
		  staff['yearjoin'] = doc['yearjoin'];
		  data[doc['_id']] = staff;
	  }
  	  
	  db.open().then((c){
	     // load original staff data into database, reset it every time before use
	  	 coll.remove();
		 coll.insertAll(documents);
	  })
	  .then((c) {
	    // iterate through every document in collection and put into the map
		return coll.find().each( (doc) => build_map(doc) );
	  }).then((val) {
		db.close();
		data['total'] = data.length;
		data['next'] = true;
		// convert data map to Json string
		completer.complete(Json.stringify(data));
	  });
	  return completer.future;
	}

}