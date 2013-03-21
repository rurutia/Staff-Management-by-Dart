//client side code

import "dart:html";
import "dart:json" as Json;

void main() {
	
  document.query("#display").onClick.listen(
    (e) {
      HttpRequest.request("/staffsInfo").then(
        (request) {
          document.body.appendHtml(request.responseText);
        });
    }).catchError((e){
    	window.alert("error detected: ${e.toString()}");
    });
}