// render view by processing jason response from server
part of staff_management_client;

class FieldValidator {

	static bool validateEmpNo(String empNo) {
		RegExp patt = new RegExp(r"^[1-9][0-9]{2}$");
		return patt.hasMatch(empNo);
	}
	
	static bool validateEmpName(String empName) {
		RegExp patt = new RegExp(r"^[a-zA-Z]{2}[a-zA-Z ]*$");
		return patt.hasMatch(empName);
	}
	
	static bool validateYear(String year) {
		RegExp patt = new RegExp(r"^[1-9][0-9]{3}$");
		return patt.hasMatch(year);
	}

}