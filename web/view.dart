// render view by processing jason response from server
part of staff_management_client;

class AppViewRenderer {

  // contains client side variables
  AppController _controller;
  
  AppController get controller => _controller;
  set controller(controller) => this._controller = controller;
  
  AppViewRenderer(this._controller) {
  }

	// render view 
  void updateView(String jsonResponse) {
	renderTable(jsonResponse);
	// debug info will be removed in production mode
	renderDebugInfo("json", jsonResponse);
    // renderDebugInfo("client", "start_index = ${controller.localData.start} & count_per_page = ${controller.localData.count}");
    renderDebugInfo("client", "${controller.localData.toString()}");
  }

  // render staff records table
  void renderTable(String jsonResponse) {
   toogleDisplayMode("display");
   TableElement staffTable =  document.query("#staff-table");
   staffTable.innerHtml = ""; 
   staffTable.append(new Element.html("<tr><th>Employee No</th><th>Name</th><th>Position</th><th>Year Join</th><th><input type='checkbox' id='multiSelectStaffs' /></th></tr>"));
   // parse server response json string to map
   Map staffs = Json.parse(jsonResponse);

   for(String key in staffs.keys) {
     if( key == "total" || key == "next" || key == "previous" || key == "mongoDB" ) break;
     Map staff = staffs[key];
     StringBuffer sb = new StringBuffer('<tr>');
     for(String attrKey in staff.keys) {
       sb.write("<td class='id${key}'>${staff[attrKey]}</td>"); 
     }
     sb.write("<td class='id${key}'><input type='checkbox' class='staffCheckBox' value='${key}' /></td></tr>");
     var row = new Element.html(sb.toString());
     staffTable.append(row);  
   }
   
   toggleStaffSelection();
   
   toggleStaffsMultiSelection();
                           
   if( staffs.containsKey("total") ) {
     controller.localData.total = staffs["total"];
     if( staffs.containsKey("mongoDB") )
       updatePagination(controller.localData.total, isMongoDB: true);
     else
       updatePagination(controller.localData.total);
     document.query("#total-count").text = "total records: ${controller.localData.total}";
     if( controller.localData.total !=0) {
     	toggleSearchWarning(isShown: false);
     }   
   }   
   
   if( staffs.containsKey("search") ) {
     if( controller.localData.total == 0 ) {
     	toggleSearchWarning(isShown: true, message: "Sorry, no match found."); 
     }
     document.query("#pagination-container").innerHtml = '';     
     document.query("#total-count").text = "total records: ${controller.localData.total}";   
   }
   
   ButtonElement deleteBtn = document.query("#delete");
   if( staffs.containsKey("mongoDB") ) {
	   updatePaginationLeftRight(staffs.containsKey("previous"),
								 staffs.containsKey("next"),
								 isMongoDB: true
	   ); 
	   deleteBtn.classes.add("mongoDB"); 
   }  
   else {
		updatePaginationLeftRight(staffs.containsKey("previous"),
								 staffs.containsKey("next")
	   ); 
	   deleteBtn.classes.remove("mongoDB");  
   }
   if( staffs.containsKey("mongoDB"))
     toggleSearchWarning(isShown: true, message: "data read from MongoDB");
 }

  // update pagination links 
  void updatePagination(int total, {bool isMongoDB: false}) {
    document.query("#pagination-container").innerHtml = '';
    SelectElement numPerPage = document.query("#number-per-page"); 
    var count = int.parse(numPerPage.value);
    var pageCount = (total/count).ceil().toInt();
    for(var i = 0; i < pageCount; i++) {
      AnchorElement pageLink = new Element.html('<a class="page-link" href="#">${i+1}</a>');
      // highlight link to current page
      if( controller.localData.start == i * count )
        pageLink.classes.add('page-link-highlight');
      document.query("#pagination-container").append(pageLink);
      // register click event to each link   
      pageLink.onClick.listen((e) {
      	 controller.localData.start = i * count;
      	 String uri;
      	 if( isMongoDB )
           uri = "/staffsInfo?start=${controller.localData.start}&count=${count}&mongo=true";
         else
           uri = "/staffsInfo?start=${controller.localData.start}&count=${count}";

         
           HttpRequest.request(uri).then(
             (request) {
                updateView(request.responseText);
           });
  
      }); 
    } // iterate page links
  }

  // enable or disable pagination control buttons 
  void updatePaginationLeftRight(bool hasPrevious, bool hasNext, {bool isMongoDB: false}) {
	ButtonElement previousBtn = document.query('#previous'); 
	ButtonElement nextBtn = document.query('#next');
	if( isMongoDB ) {
	  previousBtn.classes.add("mongoDB");
	  nextBtn.classes.add("mongoDB");
	}
	else {
      previousBtn.classes.remove("mongoDB");
	  nextBtn.classes.remove("mongoDB");
	}
	previousBtn.disabled = hasPrevious ? false : true;
	nextBtn.disabled = hasNext ? false : true; 
  }
  
  // toggle line-through when checkbox clicked
  void toggleStaffSelection() {       
     document.queryAll(".staffCheckBox").forEach((checkBox){
     	checkBox.onClick.listen((e) { 
     		toggleSearchWarning(isShown: false);
     		RegExp staff_id_patt = new RegExp(r"\d+");
     		String td_class = checkBox.parent.classes.toString();
     		int staff_id;
     		for(var match in staff_id_patt.allMatches(td_class)) {
      		  staff_id = int.parse(match.group(0));
    		}
    		Set<String> staff_ids_set = controller.localData.staff_ids;
     		if( !checkBox.checked ) {	    
     			checkBox.parent.classes.remove("line-through");
				staff_ids_set.remove(staff_id.toString());			
     		} 
     		else {
     		    staff_ids_set.add(staff_id.toString());
     		}
     		String rowClass = checkBox.parent.classes.toString();
     		document.queryAll(".${rowClass}").forEach((td){
     			if( !checkBox.checked )
     				td.classes.remove("line-through");
     			else {
     				td.classes.add("line-through");
     			}
     		});    	
     			
     	});
     }); 
   }
   
  // toggle line-through when multi-checkbox clicked 
  void toggleStaffsMultiSelection() {
    CheckboxInputElement multiSelectCbx = document.query("#multiSelectStaffs");
   multiSelectCbx.onClick.listen((e) {
     toggleSearchWarning(isShown: false);
     controller.localData.staff_ids = new Set<String>();
     Set<String> staff_ids_set = controller.localData.staff_ids;	
 
   	 document.queryAll(".staffCheckBox").forEach((checkBox){		 		
     		if( !multiSelectCbx.checked ) {	    
     			checkBox.parent.classes.remove("line-through");		
     		} 
     		else {
				RegExp staff_id_patt = new RegExp(r"\d+");
				String td_class = checkBox.parent.classes.toString();
				int staff_id;
				for(var match in staff_id_patt.allMatches(td_class)) {
				  staff_id = int.parse(match.group(0));
    		    }
     		    staff_ids_set.add(staff_id.toString());
     		}
     		String rowClass = checkBox.parent.classes.toString();

     		document.queryAll(".${rowClass}").forEach((td){   	        		   
     			if( !multiSelectCbx.checked ) {
     				checkBox.checked = false;
     				td.classes.remove("line-through");
     			}
     			else {
     			    checkBox.checked = true;
     				td.classes.add("line-through");
     			}
     		});    	     		
     }); 
   });
  } 
  
  // toggle search warning message
  void toggleSearchWarning({bool isShown: false , String message: null}) {
    if( document.query(".warning") != null) {
        document.query(".warning").remove();
     }
    if( isShown ) {
      document.query("#search-container")
        .appendHtml('<span class="warning">${message}</span>');   
    }
  }
  
  // reset staff input field
  void resetStaffInputFields() {
  	document.queryAll(".staff-input").forEach((input) { 
   		input.value = "";
   	});
  }
  
  // clear new staff input validation warning
  void cleartStaffInputWarning() {
  	if(document.query("#new-staff-error") != null ) {
  	  document.queryAll("#new-staff-error").forEach((element) { 
   		element.remove();
   	  });
    }
  }
  
  // switch display mode between "display" and "add" (more in future)
  void toogleDisplayMode(String mode){
  	TableElement staffTable = document.query("#staff-table");
  	DivElement addStaffContainer = document.query("#add-staff-container");    	  
    var controlSection = document.query("#control");
    ButtonElement deleteBtn = document.query("#delete");
    
  	switch(mode) {
  		case "display": 
  			staffTable.style.display = "block";
  			controlSection.style.display = "block";
  			deleteBtn.style.display = "block";
  			addStaffContainer.style.display = "none";
  			break;
  		
  		case "add":
  			staffTable.style.display = "none";
  			controlSection.style.display = "none";
  			deleteBtn.style.display = "none";
  			addStaffContainer.style.display = "block";
  			break;
  			
  	} // switch
  }

  // render debug information (will not be displayed in production mode)
  void renderDebugInfo(String debugType, String message) {
	document.query("#debug-${debugType}").appendHtml("${message}<br><br>");
  }
  
  // delete selected staff rows from view
  void deleteRows(Set<String> staff_ids) {
	staff_ids.forEach( (id)  {
      document.queryAll(".id${id}").forEach((td) {
      	td.remove();
      });
    });
    controller.localData.total = controller.localData.total - staff_ids.length;
    document.query("#total-count").text = "total records: ${controller.localData.total}";
  }

}