<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, hospitalmgt.patients" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>View Patient</title>
        <link rel="stylesheet" href="../styles.css"> 
    </head>
    <body>
        <%
            String patientIdStr = request.getParameter("patientId");
            int patientId = Integer.parseInt(patientIdStr);
            
            System.out.println(patientId);
                    
            try {
                // Explicitly load the MySQL JDBC driver
                Class.forName("com.mysql.cj.jdbc.Driver"); // Ensure JDBC driver is loaded
                } catch (ClassNotFoundException e) {
                    out.println("Error loading MySQL driver: " + e.getMessage());
                }

            patients patient = new patients();
            patient.patientId = patientId;
            int status = patient.viewPatient();
            

            
            if (status == 1) {%>
                <h1>Patient Details</h1>
                <p>ID: <%= patient.patientId %></p>
                <p>Name: <%= patient.firstName %> <%= patient.lastName %></p>
                <p>Age: <%= patient.age %></p>
                <p>Gender: <%= patient.gender %></p>
                <p>Phone: <%= patient.phoneNumber %></p>
        <%} else { %>
                <h1>Patient Not Found</h1>
        <% } %>
            <form action="../index.html">
            <input type="submit" value="Return to Main Menu">
        </form>
    </body>
</html>
