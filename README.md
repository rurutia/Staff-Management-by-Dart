<h3>File Structure:</h3>

<br>--<b>web</b>
<br>----<b>index.html</b>    (client interface) 
<br>----<b>staff.dart</b>    (client Dart application entrance)
<br>----<b>view.dart</b>     (update client views based on Json response from sever)
<br>----<b>main.css</b>      (style sheet)
<br>----<b>webapp</b>      (server side codes)
<br>------<b>config.dart</b>    (uri mapping configuration)
<br>------<b>main.dart</b>    (server Dart applciation entrance)
<br>------<b>utility.dart</b>    (unility classes and functions)
<br>------<b>data.xml</b>    (permanent data store)

<h3>Heroku Deployment:</h3>

<a href="http://michaelyu.herokuapp.com/">http://michaelyu.herokuapp.com/</a>
<br>"main.dart" specifies different host and port on Heroku.