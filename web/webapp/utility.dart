// Utility classes and functions
part of staff_management;

class UriParamParser {
  static final String TYPE_INT = "int";
  static final String TYPE_LIST_STRING = "list_string";
  
  Map<String, String> _params;
  
  UriParamParser(HttpRequest request) {
  	_params = request.queryParameters;
  }
    
  dynamic getParamValue(String param, {String type: "string", RegExp pattern}) {
    switch(type) {
      case "int":
        return _params[param];
        
      case "list_string":
        return _params[param].split(pattern);
        
      default:
    	return _params[param];
    }   
  }
  
  bool containsParam(String param) {
  	return _params.containsKey(param);
  }
 
}
