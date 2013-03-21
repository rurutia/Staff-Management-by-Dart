// Server side code
library staff_management;

import "dart:json" as Json;
import "dart:io";
import "package:stream/stream.dart";
import "package:xml/xml.dart";

part "config.dart";

// XML Contents
List<String> contents = [];

void loadStaffsInfo(HttpConnect connect) {
   // Send back to client
   StringBuffer sb = new StringBuffer();
  
   XmlElement xmlDoc = XML.parse( contents.join(' ') );
	
    Map allNodes = xmlDoc.queryAll("staff").asMap();
    allNodes.forEach((k,XmlElement v) {
      sb.write(k.toString());   
      sb.write(v.children[0].toString());  
      sb.write(v.children[1].toString());
      sb.write("<br>");   
    });


  connect.response
    ..headers.contentType = contentTypes["text"]
    ..write(sb.toString());
  connect.close();
}

void main() {
  new StreamServer(uriMapping: _mapping).start();
  processXML();
}

void processXML() {
  File file = new File('webapp/data.xml');
  file.readAsString().then((content) {
		contents.add(content);
  });	
}


