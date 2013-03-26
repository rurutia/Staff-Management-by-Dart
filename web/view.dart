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
    renderDebugInfo("client", "start_index = ${controller.localData.start} & count_per_page = ${controller.localData.count}");
  }

  // render staff records table
  void renderTable(String jsonResponse) {
   TableElement staffTable =  document.query("#staff-table");
   staffTable.innerHtml = "";
   staffTable.append(new Element.html("<tr><th>Employee No</th><th>Name</th><th>Position</th><th>Year Join</th><th>multiselection to be implemented</th></tr>"));
   // parse server response json string to map
   Map staffs = Json.parse(jsonResponse);

   for(String key in staffs.keys) {
     if( key == "total" || key == "next" || key == "previous" ) break;
     Map staff = staffs[key];
     StringBuffer sb = new StringBuffer('<tr>');
     for(String attrKey in staff.keys) {
       sb.write("<td class='id${key}'>${staff[attrKey]}</td>"); 
     }
     sb.write("<td class='id${key}'><input type='checkbox' class='staffCheckBox' value='${key}' /></td></tr>");
     var row = new Element.html(sb.toString());
     staffTable.append(row);
 
      
   }
     // toggle line-through when checkbox clicked       
     document.queryAll(".staffCheckBox").forEach((checkBox){
     	checkBox.onClick.listen((e) { 
     		toggleSearchWarning(isShown: false);
            int staff_id = int.parse(checkBox.parent.classes.toString().substring("id".length, 3));  	
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
                          
   if( staffs.containsKey("total") ) {
     controller.localData.total = staffs["total"];
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
   
   updatePaginationLeftRight(staffs.containsKey("previous"),
                             staffs.containsKey("next")
   );    
 }

  // update pagination links 
  void updatePagination(int total) {
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
           String uri = "/staffsInfo?start=${controller.localData.start}&count=${count}";
           HttpRequest.request(uri).then(
             (request) {
                updateView(request.responseText);
           });
  
      }); 
    } // iterate page links
  }

  // enable or disable pagination control buttons 
  void updatePaginationLeftRight(bool hasPrevious, bool hasNext) {
	ButtonElement previousBtn = document.query('#previous'); 
	ButtonElement nextBtn = document.query('#next');
	previousBtn.disabled = hasPrevious ? false : true;
	nextBtn.disabled = hasNext ? false : true; 
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