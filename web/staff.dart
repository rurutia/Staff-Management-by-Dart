//client side code

import "dart:html";
import "dart:json" as Json;

TableElement staffTable =  document.query("#staff-table");

void main() {
  document.query("#display").onClick.listen(
    (e) {
      HttpRequest.request("/staffsInfo?start=0&count=0").then(
        (request) {
          document.body.appendHtml(request.responseText);
		  renderTable(request.responseText);
        });
    }).catchError((e){
    	window.alert("error detected: ${e.toString()}");
    });
}

void renderTable(String jsonStaffs) {
   staffTable.innerHtml = "";
   staffTable.append(new Element.html('<tr><th>Name</th><th>Position</th><th>Year Join</th></tr>'));
 
   Map staffs = Json.parse(jsonStaffs);

   for(String key in staffs.keys) {
     Map staff = staffs[key];
     StringBuffer sb = new StringBuffer('<tr>');
     for(String key in staff.keys) {
       sb.write("<td>${staff[key]}</td>"); 
     }
     sb.write("</tr>");
     var row = new Element.html(sb.toString());
     staffTable.append(row);
   }
}