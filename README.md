<h3>Development Log</h3> 
<br>#02/04 Pagination with MongoDB implemented.
<br>#31/03 Experimental MongoDB support added.
<br>(can create initial database and load all documents in collection to client browser) 
<br>#30/03 Add functionality implemented
<br>#28/03 Rewrite server side codes to programme data operation to Data Access Object interface. 
Seperate business logic and data operation from "main.dart" into "dao.dart" in which XML dao has been implemented.
Plan to transit to MongoDB by implementing Database Dao. 
<br>#27/03 Issues in Dartium checked mode fixed. Multi-selection and data recovery have been added.
<br>#26/03 Codes improved to adopt clearer MVC pattern on client side
<br>#25/03 Deletion implemented
<br>#23/03 Pagination implemented
<br>#22/03 Ajax/Json data transfer implemented

<h3>Heroku Deployment:</h3>

<a href="http://michaelyu.herokuapp.com/">http://michaelyu.herokuapp.com/</a>
<br>"main.dart" deployed on Heroku specifies different host and port.

<h3>File Structure:</h3>

<br>--<b>web</b>
<br>----<b>staff.dart</b>    (client Dart application entry point)
<br>----<b>controller.dart</b>(process server response and handle client side ui events)
<br>----<b>view.dart</b>     (render client views)
<br>----<b>validation.dart</b>     (client side user input validation)
<br>----<b>index.html</b>    (client web interface) 
<br>----<b>main.css</b>      (style sheet)
<br>----<b>webapp</b>      (server side codes)
<br>------<b>main.dart</b>     (server management, handling client request and sending response back)
<br>------<b>dao.dart</b>    (data access object interface for business logic and data operation)
<br>------<b>daoXML.dart</b>    (concrete dao XML implementation)
<br>------<b>daoMongo.dart</b>    (concrete dao MongoDB implementation)
<br>------<b>config.dart</b>    (uri mapping configuration)
<br>------<b>utility.dart</b>    (unility classes and functions)
<br>------<b>data.xml</b>    (permanent data store)

