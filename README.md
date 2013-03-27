<h3>Development Log</h3> 
<br>#27/03 Issues in Dartium checked mode fixed
<br>#26/03 Code improved to adopt clearer MVC pattern on client side
<br>#25/03 Deletion implemented
<br>#23/03 Pagination implemented
<br>#22/03 Ajax/Json data transfer implemented

<h3>Heroku Deployment:</h3>

<a href="http://michaelyu.herokuapp.com/">http://michaelyu.herokuapp.com/</a>
<br>"main.dart" deployed on Heroku specifies different host and port.

<h3>File Structure:</h3>

<br>--<b>web</b>
<br>----<b>staff.dart</b>    (client Dart application entry point)
<br>----<b>controller.dart</b>(send Ajax request and setup events handlers)
<br>----<b>view.dart</b>     (update client views based on Json data from sever)
<br>----<b>index.html</b>    (client web interface) 
<br>----<b>main.css</b>      (style sheet)
<br>----<b>webapp</b>      (server side codes)
<br>------<b>main.dart</b>     (business logic and send data back to client)
<br>------<b>config.dart</b>    (uri mapping configuration)
<br>------<b>utility.dart</b>    (unility classes and functions)
<br>------<b>data.xml</b>    (permanent data store)

