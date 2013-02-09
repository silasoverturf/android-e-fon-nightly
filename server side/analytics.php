<?php
$to = "silasoverturf@gmail.com";
$subject = ($_POST['email']);
$message = ($_POST['senderMsg']);
$message .= "\n\n---------------------------\n";
$message .= "E-mail Sent From: " . $_POST['email'] . " <" . $_POST['senderEmail'] . ">\n";
$headers = "From: " . $_POST['email'] . " <" . $_POST['senderEmail'] . ">\n";
if(@mail($to, $subject, $message, $headers))
{
echo "answer=ok";
} 
else 
{
echo "answer=error";
}
?>