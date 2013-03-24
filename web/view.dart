// render view by processing jason response from server
part of staff_management_client;

// render view 
void updateView(String jsonResponse) {
	renderTable(jsonResponse);
	// debug info will be removed in production mode
	renderDebugInfo("json", jsonResponse);
    renderDebugInfo("client", "start_index = ${start} & count_per_page = ${count}");
}

// render staff records table
void renderTable(String jsonResponse) {
   TableElement staffTable =  document.query("#staff-table");
   staffTable.innerHtml = "";
   staffTable.append(new Element.html('<tr><th>Employee No</th><th>Name</th><th>Position</th><th>Year Join</th></tr>'));
   // parse server response json string to map
   Map staffs = Json.parse(jsonResponse);

   for(String key in staffs.keys) {
     if( key == "total" || key == "next" || key == "previous" ) break;
     Map staff = staffs[key];
     StringBuffer sb = new StringBuffer('<tr>');
     for(String key in staff.keys) {
       sb.write("<td>${staff[key]}</td>"); 
     }
     sb.write("</tr>");
     var row = new Element.html(sb.toString());
     staffTable.append(row);
   }
                          
   if( staffs.containsKey("total") ) {
     total = staffs["total"];
     updatePagination(total);
     document.query("#total-count").text = "total records: ${total}";   
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
    if( start == i * count )
      pageLink.classes.add('page-link-highlight');
    document.query("#pagination-container").append(pageLink);
    // register click event to each link   
    pageLink.onClick.listen((e) {
    	 start = i * count;
         String uri = "/staffsInfo?start=${start}&count=${count}";
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