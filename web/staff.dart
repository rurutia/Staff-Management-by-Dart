//client side code
library staff_management_client;

import "dart:html";
import "dart:json" as Json;
import "dart:uri";

part "view.dart";

// track index and number of records used for pagination
int start, count;

void main() {
  ButtonElement displayAllBtn = document.query('#displayAll');
  ButtonElement previousBtn = document.query('#previous'); 
  ButtonElement nextBtn = document.query('#next');
  SelectElement numPerPage = document.query("#number-per-page");
  ButtonElement searchBtn = document.query("#search");
  InputElement searchBox = document.query("#searchBox");
   
  attachEventsClientSide(); 
  
  // attach event to relevent DOM objects
  // read staffs information from server when triggered
  attachEventLoadStaffs(window, "onLoad");    
  attachEventLoadStaffs(displayAllBtn, "onClick");
  attachEventLoadStaffs(previousBtn, "onClick");
  attachEventLoadStaffs(nextBtn, "onClick");
  attachEventLoadStaffs(numPerPage, "onChange");
  attachEventLoadStaffs(searchBtn, "onClick"); 
  attachEventLoadStaffs(searchBox, "onKeyPress"); 
   
}

void attachEventsClientSide() {
  InputElement searchBox = document.query("#searchBox");
  searchBox.onClick.listen((e) {
    searchBox.value = '';
    toggleSearchWarning(isShown: false);
  });
  
  InputElement clearDebugBtn = document.query("#clearDebugBtn");
  clearDebugBtn.onClick.listen((e) {
    document.queryAll(".debug-info").forEach((element) {
    	element.innerHtml = ''; 
    });  
  });
}

void attachEventLoadStaffs(EventTarget element, String eventType) {
  SelectElement numPerPage = document.query("#number-per-page"); 
  
  switch(eventType) {
    case "onLoad": 
  		element.onLoad.listen((e) {
  	    start = 0;
        count = int.parse(numPerPage.value);
        HttpRequest.request("/staffsInfo?start=${start}&count=${count}").then(
          (request) {
		    updateView(request.responseText);
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
		        updateView(request.responseText);
            });
        }); 
        break;
    
    case "onClick": 
  		element.onClick.listen((e) {
  		  if( element == document.query("#previous") ) {
     	    start -= count;
     	    count = int.parse(numPerPage.value);
     	  }
     	  if( element == document.query("#next") ) {
     	    start += count;
     	    count = int.parse(numPerPage.value);
     	  }
     	  if( element == document.query("#displayAll") ) {
     	    start = 0;
     	    count = int.parse(numPerPage.value);
     	  }
     	  if( element == document.query("#search") ) {
     	    start = 0;
     	    count = 0;
     	  }
          String uri = "/staffsInfo?start=${start}&count=${count}";
          if( element == document.query("#search") ) {
            InputElement searchBox = document.query("#searchBox");
            String keyword = encodeUriComponent(searchBox.value.trim());
   		    if( keyword.length == 0 ) {
   		      toggleSearchWarning(isShown: true, message: "keyword can not be empty.");
      		  return;
    		}
     	    uri = "${uri}&keyword=${keyword}";
     	  }
          
          HttpRequest.request(uri).then(
            (request) {
               updateView(request.responseText);
             });
        }); 
        break;
        
        case "onKeyPress": 
  		element.onKeyPress.listen((e) {   		  
     	  if( element == document.query("#searchBox") ) {
     	    if( e.keyCode == 13 ) {
     	      start = 0;
              count = 0;
            } else {
                return;
            }               
     	  }
          String uri = "/staffsInfo?start=${start}&count=${count}";
          if( element == document.query("#searchBox") ) {
            String keyword = encodeUriComponent(element.value.trim());
   		    if( keyword.length == 0 ) {
   		      toggleSearchWarning(isShown: true, message: "keyword can not be empty.");      		    
      		  return;
    		}
     	    uri = "${uri}&keyword=${keyword}";
     	  }      
          HttpRequest.request(uri).then(
            (request) {
               updateView(request.responseText);
             });
        }); 
        break;
        
  } // switch

}


