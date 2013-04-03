// Concrete Dao class using XML as data store
part of staff_management;

// concrete DAO class (XML implementation)
class DaoXmlImpl implements Dao {
   // XML data source file name
   String _filename;
   // XML data source contents
   XmlElement _xmlDoc;
   
   String get filename => this._filename;
   XmlElement get xmlDoc => this._xmlDoc;
   set filename(filename) => this._filename = filename;
   set xmlDoc(xmlDoc) => this._xmlDoc = xmlDoc;
   
   DaoXmlImpl(this._filename) {
   }

   // convert XML file to XmlElement for future processing
	void processXML() {
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

   String getStaffs(int start, int count) {
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
   
   String searchStaffs(int start, int count, String keyword) {
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
	
	// Add new staff into XML data store
	String addNewStaff(int employeeNo, String name, String position, int yearJoin) {
	  Map allStaffs = xmlDoc.queryAll("staff").asMap(); 
	  int maxId = 0;
   	  for(var i = 0;i < allStaffs.length; i++) {
   	    int currentId = int.parse(allStaffs[i].attributes['id']);
      	maxId = ( maxId < currentId ) ? currentId : maxId;
      }
	  int newId = maxId + 1;
	  
	  String newStaffInfo = '''
	  	<staff id='${newId.toString()}' deleted='false'>
  			<employeeno>${employeeNo.toString()}</employeeno>
    		<name>${name}</name>
    		<position>${position}</position>
    		<yearjoin>${yearJoin.toString()}</yearjoin>
		</staff>
	  ''';
	  
	  File file = new File(filename);
	  String contents = file.readAsStringSync();
	  contents = contents.replaceAll("</company>", "");
	  StringBuffer sb = new StringBuffer(contents);
	  sb.writeln(newStaffInfo);
	  sb.writeln("</company>");
	  
	  xmlDoc = XML.parse(sb.toString());
	  
	  file.writeAsStringSync(sb.toString());
	  
	  return newStaffInfo;
	}
	
	// delete staffs data from XML by setting "deleted" attribute to "false"
	// call "recoverStaffs" method to recover
	String deleteStaffsByIDs(List<String> ids) {
	   File file = new File(filename);
	   String contents = file.readAsStringSync();
	   RegExp staffPatt;
	   ids.forEach((id) {
		 String patt = "<staff id='${id}' deleted='false'>";
		 staffPatt = new RegExp(patt, multiLine:true);
		 contents = contents.replaceAll(staffPatt, "<staff id='${id}' deleted='true'>");
	   });
	   file.writeAsStringSync(contents);

	   processXML();
   
	   Map data = {}; 
	   data['deleted_staff_ids'] = ids;
	   return Json.stringify(data);
	}
	
	// recover original staffs records in XML by changing staff "delete" attribute to "false"
	void recoverStaffs() {
	   File file = new File(filename);
	   String contents = file.readAsStringSync();
	   RegExp recoverPatt = new RegExp("deleted='true'", multiLine:true);
	   contents = contents.replaceAll(recoverPatt, "deleted='false'");

	   xmlDoc = XML.parse(contents);
	   file.writeAsStringSync(contents);
   
	}

}