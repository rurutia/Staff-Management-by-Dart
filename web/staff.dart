//client side code
library staff_management_client;

import "dart:html";
import "dart:json" as Json;

part "view.dart";

// track index and number of records used for pagination
int start, count;

void main() {
  ButtonElement displayAllBtn = document.query('#displayAll');
  ButtonElement previousBtn = document.query('#previous'); 
  ButtonElement nextBtn = document.query('#next');
  SelectElement numPerPage = document.query("#number-per-page"); 
  
  // attach event to relevent DOM objects
  // read staffs information from server when triggered
  attachEventLoadStaffs(window, "onLoad");    
  attachEventLoadStaffs(displayAllBtn, "onClick");
  attachEventLoadStaffs(previousBtn, "onClick");
  attachEventLoadStaffs(nextBtn, "onClick");
  attachEventLoadStaffs(numPerPage, "onChange"); 
   
}

attachEventLoadStaffs(EventTarget element, String eventType) {
  SelectElement numPerPage = document.query("#number-per-page"); 
  
  switch(eventType) {
    case "onLoad": 
  		element.onLoad.listen((e) {
  	    start = 0;
        count = int.parse(numPerPage.value);
        HttpRequest.request("/staffsInfo?start=${start}&count=${count}").then(
          (request) {
            document.body.appendHtml("<br>start=${start}&count=${count} ${request.responseText}");
		    renderTable(request.responseText);
          });
        }); 
        break;
        
  	case "onChange": 
  		element.onChange.listen((e) {
  		  if( element == document.query("#number-per-page") ) {
     		start = 0;
     	  }
          count = int.parse(numPerPage.value);
            HttpRequest.request("/staffsInfo?start=${start}&count=${count}").then(
              (request) {
                document.body.appendHtml("<br>start=${start}&count=${count} ${request.responseText}");
		        renderTable(request.responseText);
            });
        }); 
        break;
    
    case "onClick": 
  		element.onClick.listen((e) {
  		  if( element == document.query("#previous") ) {
     	    start -= count;
     	  }
     	  if( element == document.query("#next") ) {
     	    start += count;
     	  }
     	  if( element == document.query("#displayAll") ) {
     	    start = 0;
     	  }
          count = int.parse(numPerPage.value);
          HttpRequest.request("/staffsInfo?start=${start}&count=${count}").then(
            (request) {
               document.body.appendHtml("<br>start=${start}&count=${count} ${request.responseText}");
		       renderTable(request.responseText);
             });
        }); 
        break;
  }

}
