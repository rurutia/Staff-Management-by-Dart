// Data Access Object Classes mapping application calls to the persistence layer
// persistence layer can be either XML or database
part of staff_management;

// Data Access Object interface
abstract class Dao {
   
   // read number of count staffs from data store from start index	
   String getStaffs(int start, int count);
   // search staffs by keyword from start index 
   String searchStaffs(int start, int count, String keyword);
   // add new staff to data store
   String addNewStaff(int employeeNo, String name, String position, int yearJoin);
   // delete staffs from data store
   String deleteStaffsByIDs(String ids);
   // recover original staffs data from deletion
   void recoverStaffs();
   
}
