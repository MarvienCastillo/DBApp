<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.*, java.sql.*, hospitalmgt.*"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Update Patient</title>
    <link rel="stylesheet" href="../styles.css">
</head>
<body>
    <div class="container">
        <jsp:useBean id="A" class="hospitalmgt.patients" scope="session" />
        <%
            String jsp_patientIdStr = request.getParameter("patientId");
            String jsp_firstName = request.getParameter("firstName");
            String jsp_lastName = request.getParameter("lastName");
            String jsp_dateOfBirthStr = request.getParameter("dateOfBirth");
            String jsp_ageStr = request.getParameter("age");
            String jsp_gender = request.getParameter("gender");
            String jsp_phoneNumber = request.getParameter("phoneNum");

            if (jsp_patientIdStr != null && !jsp_patientIdStr.isEmpty()) {
                A.patientId = Integer.parseInt(jsp_patientIdStr);

                if (jsp_firstName != null) A.firstName = jsp_firstName;
                if (jsp_lastName != null) A.lastName = jsp_lastName;
                if (jsp_dateOfBirthStr != null && !jsp_dateOfBirthStr.isEmpty()) {
                    A.dateOfBirth = java.sql.Date.valueOf(jsp_dateOfBirthStr);
                }
                if (jsp_ageStr != null && !jsp_ageStr.isEmpty()) {
                    A.age = Integer.parseInt(jsp_ageStr);
                }
                if (jsp_gender != null) A.gender = jsp_gender;
                if (jsp_phoneNumber != null) A.phoneNumber = jsp_phoneNumber;

                 try {
                    // Explicitly load the MySQL JDBC driver
                    Class.forName("com.mysql.cj.jdbc.Driver"); // Ensure JDBC driver is loaded
                    } catch (ClassNotFoundException e) {
                        out.println("Error loading MySQL driver: " + e.getMessage());
                    }
                
                
                int status = A.updatePatient();
                if (status == 1) {
        %>
                    <h1>Patient Updated Successfully</h1>
                <% } else { %>
                    <h1>Failed to Update Patient</h1>
                <% }
            } else { %>
                <h1>Patient ID is Required</h1>
            <% } %>
        <a href="../index.html">Return to Main Menu</a>
    </div>
</body>
</html>
