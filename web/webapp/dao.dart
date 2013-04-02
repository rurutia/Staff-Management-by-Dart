// Data Access Object Classes mapping application calls to the persistence layer
// persistence layer can be either XML or database
part of staff_management;

// Data Access Object interface
abstract class Dao {

   String getStaffs(int start, int count);
   String searchStaffs(int start, int count, String keyword);
   String addNewStaff(int employeeNo, String name, String position, int yearJoin);
   String deleteStaffsByIDs(String ids);
   // recover original staffs data from delete operation
   void recoverStaffs();
   
}
