<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.*, java.sql.*, hospitalmgt.*"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Delete Patient</title>
    <link rel="stylesheet" href="../styles.css">
</head>
<body>
    <div class="container">
        <jsp:useBean id="A" class="hospitalmgt.patients" scope="session" />
        <%
            String jsp_patientIdStr = request.getParameter("patientId");

            A.patientId = Integer.parseInt(jsp_patientIdStr);
                
            try {
                // Explicitly load the MySQL JDBC driver
                Class.forName("com.mysql.cj.jdbc.Driver"); // Ensure JDBC driver is loaded
                } catch (ClassNotFoundException e) {
                    out.println("Error loading MySQL driver: " + e.getMessage());
                }
                

            int status = A.deletePatient();
            if (status == 1) {  %>
                <h1>Patient Deleted Successfully</h1>
            <% } else { %>
                <h1>Failed to Delete Patient</h1><%}%>
        <a href="../index.html">Return to Main Menu</a>
    </div>
</body>
</html>
