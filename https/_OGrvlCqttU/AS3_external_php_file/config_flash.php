<?php
// Only run this script if the sendRequest is from our flash application
if ($_POST['sendRequest'] == "parse") {
// Access the value of the dynamic text field variable sent from flash
$uname = $_POST['uname'];
// Print  two vars back to flash, you can also use "echo" in place of print
print "var1=The name field with a variable of $uname has been sent to PHP and is back.";
print "&var2=$uname is also set in variable 2 from PHP.";

}

?>