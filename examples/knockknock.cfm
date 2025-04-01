<!--- 
knockknock.cfm - Simple password form with IP logging 

This is a VERY SIMPLE EXAMPLE that works, but PLEASE consider the security implications of using hard-coded passwords and writing sensitive information to files.
This example is not secure and should not be used in production without proper security measures.

--->
<html>
<head>
    <title>Access</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background-color: #f5f5f5;
        }
        .container {
            padding: 20px;
            background-color: white;
            border-radius: 5px;
            width: 300px;
        }
        input[type="password"] {
            width: 100%;
            padding: 10px;
            margin: 10px 0;
            box-sizing: border-box;
        }
        input[type="submit"] {
            width: 100%;
            padding: 10px;
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        input[type="submit"]:hover {
            background-color: #45a049;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Knock, knock!</h1>
        <form method="post">
            <label for="password">Password:</label>
            <input type="password" id="password" name="password">
            <input type="submit" value="Who's there?">
        </form>
        
        <!--- Password verification and IP logging logic --->
        <cfif structKeyExists(form, "password")>
            <!--- Hard-coded password - change this to your desired password --->
            <cfset secretPassword = "thisIsAVerySecretPassword">
            
            <cfif form.password EQ secretPassword>
                <!--- Get visitor's IP address --->
                <cfset visitorIP = CGI.REMOTE_ADDR>
                
                <!--- Write IP to file --->
                <cffile action="write" 
                        file="/tmp/knock.txt" 
                        nameconflict="overwrite"
                        output="#visitorIP#">
                
                <p style="color: green;">Access granted.</p>
            <cfelse>
                <p style="color: red;">Incorrect password.</p>
            </cfif>
        </cfif>
    </div>
</body>
</html>