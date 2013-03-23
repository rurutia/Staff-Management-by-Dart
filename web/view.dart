// render view by processing jason response from server
part of staff_management_client;

// render staff records table
void renderTable(String jsonResponse) {
   TableElement staffTable =  document.query("#staff-table");
   staffTable.innerHtml = "";
   staffTable.append(new Element.html('<tr><th>Employee No</th><th>Name</th><th>Position</th><th>Year Join</th></tr>'));
   // parse server response json string to map
   Map staffs = Json.parse(jsonResponse);

   for(String key in staffs.keys) {
     if( key == "next" || key == "previous" ) break;
     Map staff = staffs[key];
     StringBuffer sb = new StringBuffer('<tr>');
     for(String key in staff.keys) {
       sb.write("<td>${staff[key]}</td>"); 
     }
     sb.write("</tr>");
     var row = new Element.html(sb.toString());
     staffTable.append(row);
   }
   
   setupPaginationControl(staffs.containsKey("previous"),
                          staffs.containsKey("next")
                         );    
}

// enable or disable pagination control buttons 
void setupPaginationControl(bool hasPrevious, bool hasNext) {
	ButtonElement previousBtn = document.query('#previous'); 
	ButtonElement nextBtn = document.query('#next');
	previousBtn.disabled = hasPrevious ? false : true;
	nextBtn.disabled = hasNext ? false : true; 
}