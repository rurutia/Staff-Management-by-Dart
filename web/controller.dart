// register client events and dispatch server response to view renderer
part of staff_management_client;

// store client side variables
class LocalData {

  // track index, number of records and total records used for pagination
  int _start, _count, _total;
  // selected staff ids
  Set<String> _staff_ids = new Set<String>();
  
  LocalData(this._start, this._count, this._total) {
  } 
  
  int get start => _start;
  int get count => _count;
  int get total => _total;
  Set<String> get staff_ids => _staff_ids;
  set start(int start) => this._start = start;  
  set count(int count) => this._count = count; 
  set total(int total) => this._total = total; 
  set staff_ids(Set<String> staff_ids) => this._staff_ids = staff_ids;
  
  String toString() {
  	String all = '''
  		start_index = ${start} 
  		& count_per_page = ${count}
  		& total = ${total}
  		''';
  	return all;
  }
  
}

// application controller
class AppController {
    
  // contains client side variables
  LocalData _localData;
  
  // ui renderer
  AppViewRenderer _view;
   
  AppController() {
  	_localData = new LocalData(0, 0, 0);
  	_view = new AppViewRenderer(this);
  }
  
  LocalData get localData => _localData;
    
  // setup initial ui
  void setup_ui() {
    ButtonElement displayAllBtn = document.query('#displayAll');
    ButtonElement previousBtn = document.query('#previous'); 
    ButtonElement nextBtn = document.query('#next');
    SelectElement numPerPage = document.query("#number-per-page");
    ButtonElement searchBtn = document.query("#search");
    InputElement searchBox = document.query("#searchBox");
    ButtonElement deleteBtn = document.query("#delete");
    ButtonElement recoverBtn = document.query("#recover");
    ButtonElement confirmAddStaffBtn = document.query("#confirmAddStaff");
    ButtonElement mongoDBBtn = document.query("#mongoDBbtn");
   
    // attach event to relevent DOM objects
    // read staffs information from server when triggered
    attachEventLoadStaffs(displayAllBtn, "onClick");
    attachEventLoadStaffs(previousBtn, "onClick");
    attachEventLoadStaffs(nextBtn, "onClick");
    attachEventLoadStaffs(numPerPage, "onChange");
    attachEventLoadStaffs(searchBtn, "onClick"); 
    attachEventLoadStaffs(searchBox, "onKeyPress");
    attachEventLoadStaffs(mongoDBBtn, "onClick");
    // Delete and recover staffs from data store 
    attachEventDeleteStaffs(deleteBtn, "onClick"); 
    attachEventRecoverStaffs(recoverBtn, "onClick"); 
    // Add new staff to data store
    attachEventAddStaff(confirmAddStaffBtn, "onClick"); 
    
    // attach event to relevent DOM objects
    // register local events
    attachEventsClientSide(); 
  }
  
  // initial data load from server
  void load_initial_data() {
  	attachEventLoadStaffs(window, "onLoad");
  }

  void attachEventsClientSide() {
    ButtonElement displayAddStaffBtn = document.query("#add");
    displayAddStaffBtn.onClick.listen((e) {
		_view.toogleDisplayMode("add");
		_view.resetStaffInputFields();
		_view.cleartStaffInputWarning();
		_view.toggleSearchWarning(isShown: false);
    });
  	
    InputElement searchBox = document.query("#searchBox");
    searchBox.onClick.listen((e) {
      searchBox.value = '';
      _view.toggleSearchWarning(isShown: false);
    });
    
    ButtonElement deleteBtn = document.query("#delete");
    deleteBtn.onClick.listen((e) {
      if( localData.staff_ids.length == 0 ) {
      	  _view.toggleSearchWarning(isShown: true, message: "Please select at least one record.");
      }
    });
    
    ButtonElement cancelAddStaffBtn = document.query("#cancelAddStaff");
    cancelAddStaffBtn.onClick.listen((e) {
      document.queryAll(".debug-info").forEach((element) {
      	_view.toogleDisplayMode("display"); 
      });  
    });
    
    ButtonElement clearDebugBtn = document.query("#clearDebugBtn");
    clearDebugBtn.onClick.listen((e) {
      document.queryAll(".debug-info").forEach((element) {
      	element.innerHtml = ''; 
      });  
    });
    
    
  }
	
  // attatch ajax events of loading staffs information to DOM objects
  void attachEventLoadStaffs(EventTarget element, String eventType) {
    SelectElement numPerPage = document.query("#number-per-page"); 

    switch(eventType) {
      case "onLoad":    
    		element.onLoad.listen((e) {
    	      localData.start = 0;
              localData.count = int.parse(numPerPage.value);
              HttpRequest.request("/staffsInfo?start=${localData.start}&count=${localData.count}").then(
                (request) {
                document.query("#loadAnimation").remove();
  		        _view.updateView(request.responseText);
              });
            }); 
          break;
          
    	case "onChange": 
    		element.onChange.listen((e) {
    		  if( element == document.query("#number-per-page") ) {
       		localData.start = 0;
       	  }
            localData.count = int.parse(numPerPage.value);
              HttpRequest.request("/staffsInfo?start=${localData.start}&count=${localData.count}").then(
                (request) {               
  		        _view.updateView(request.responseText);
              });
          }); 
          break;
      
      case "onClick": 
    		element.onClick.listen((e) {
    		  if( element == document.query("#previous") ) {
       	    localData.start -= localData.count;
       	    localData.count = int.parse(numPerPage.value);
       	  }
       	  if( element == document.query("#next") ) {
       	    localData.start += localData.count;
       	    localData.count = int.parse(numPerPage.value);
       	  }
       	  if( element == document.query("#displayAll") ) {
       	    localData.start = 0;
       	    localData.count = int.parse(numPerPage.value);
       	  }
       	  if( element == document.query("#search") ) {
       	    localData.start = 0;
       	    localData.count = 0;
       	  }
            String uri = "/staffsInfo?start=${localData.start}&count=${localData.count}";
            if( element == document.query("#search") ) {
              InputElement searchBox = document.query("#searchBox");
              String keyword = encodeUriComponent(searchBox.value.trim());
     		    if( keyword.length == 0 ) {
     		      _view.toggleSearchWarning(isShown: true, message: "keyword can not be empty.");
        		  return;
      		}
       	    uri = "${uri}&keyword=${keyword}";
       	  }
       	  // Experimental codes for testing mongoDB in Dart
       	  // feel free to comment out if not needed
       	  if( element == document.query("#mongoDBbtn") ) 
       	   	 uri = "/staffsInfo?mongo=true";
          // end of mongoDB codes
  
            HttpRequest.request(uri).then(
              (request) {
                 _view.updateView(request.responseText);
                 
               });
          }); 
          break;
          
          case "onKeyPress": 
    		element.onKeyPress.listen((e) {   		  
       	  if( element == document.query("#searchBox") ) {
       	    if( e.keyCode == 13 ) {
       	        localData.start = 0;
                localData.count = 0;
              } else {
                  return;
              }               
       	  }
            String uri = "/staffsInfo?start=${localData.start}&count=${localData.count}";
            if( element == document.query("#searchBox") ) {
              String keyword = encodeUriComponent(element.value.trim());
     		    if( keyword.length == 0 ) {
     		      _view.toggleSearchWarning(isShown: true, message: "keyword can not be empty.");      		    
        		  return;
      		}
       	    uri = "${uri}&keyword=${keyword}";
       	  }      
            HttpRequest.request(uri).then(
              (request) {
                 _view.updateView(request.responseText);
               });
          }); 
          break;
          
    } // switch
  
  }
  
  // attatch ajax events of adding new staff to DOM objects
  void attachEventAddStaff(EventTarget element, String eventType) {

    switch(eventType) {
      case "onClick":    
    		element.onClick.listen((e) {	
    		 _view.cleartStaffInputWarning();
    		 bool isValid = true;
    		 String empNo = document.query("#staff-no").value.trim();
			 if( !FieldValidator.validateEmpNo(empNo) ) {
			 	document.query("#staff-no").parent.appendHtml("<span class='warning' id='new-staff-error'> ! employee no must be 3 digits and not start with 0.</span>");
			 	isValid = false;
			 }
    		 String name = document.query("#staff-name").value.trim();
    		 if( !FieldValidator.validateEmpName(name) ) {
			 	document.query("#staff-name").parent.appendHtml("<span class='warning' id='new-staff-error'> ! name must contain only letters and spaces.</span>");
			 	isValid = false;
			 }
			 name = encodeUriComponent(name);
    		 String position = document.query("#staff-position").value.trim();
    		 if( !FieldValidator.validateEmpName(position) ) {
			 	document.query("#staff-position").parent.appendHtml("<span class='warning' id='new-staff-error'> ! position must contain only letters and spaces.</span>");
			 	isValid = false;
			 }
			 position = encodeUriComponent(position);
    		 String year = document.query("#staff-yearjoin").value.trim();
    		 if( !FieldValidator.validateYear(year) ) {
			 	document.query("#staff-yearjoin").parent.appendHtml("<span class='warning' id='new-staff-error'> ! year join must be 4 digits.</span>");
			 	isValid = false;
			 }
			 if( !isValid) 
			 	return;
           	 String uri = "/addNewStaff?no=${empNo}&name=${name}&position=${position}&year=${year}";
			 
           	 HttpRequest.request(uri).then(
              (request) {                
					_view.updateView(request.responseText);
					_view.toggleSearchWarning(isShown: true, message: "New staff has been added.");      		    
               });
            }); 
          break;
          
    } // switch
  }
  
  // attatch ajax events of deleting staffs to DOM objects
  void attachEventDeleteStaffs(EventTarget element, String eventType) {

    switch(eventType) {
      case "onClick":    
    		element.onClick.listen((e) {
    		  if( localData.staff_ids.length == 0 )
    		    return;
    		  String ids = encodeUriComponent(localData.staff_ids.join(',').toString());
           	  String uri = "/deleteStaffsInfo?staff_ids=${ids}";
			
           	  HttpRequest.request(uri).then(
              (request) {                
                 _view.deleteRows(localData.staff_ids);
                 localData.staff_ids = new Set<String>();
                 _view.renderDebugInfo("json", request.responseText);
               });
            }); 
          break;
          
    } // switch
  }
  
  // attatch ajax events of recovering deleted staffs to DOM objects
  void attachEventRecoverStaffs(EventTarget element, String eventType) {
	SelectElement numPerPage = document.query("#number-per-page"); 
    
    switch(eventType) {
      case "onClick":    
    		element.onClick.listen((e) {
    		 localData.start = 0;
       	     localData.count = int.parse(numPerPage.value);
           	 String uri = "/recoverStaffsInfo?start=${localData.start}&count=${localData.count}";
			 
           	 HttpRequest.request(uri).then(
              (request) {                
					_view.updateView(request.responseText);
					_view.toggleSearchWarning(isShown: true, message: "Deleted staffs data has been recovered.");
               });
            }); 
          break;
          
    } // switch
  }
    

} // class



