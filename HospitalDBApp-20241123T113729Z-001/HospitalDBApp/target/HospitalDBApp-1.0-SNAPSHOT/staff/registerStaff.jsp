<%@ page import="hospitalmgt.staff" %>
<%@ page import="java.sql.Time" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>

<%
    
    staff newStaff = new staff();
    String lastName = request.getParameter("lastName");
    String firstName = request.getParameter("firstName");
    String departmentName = request.getParameter("departmentName");
    String startTimeStr = request.getParameter("startTime");
    String endTimeStr = request.getParameter("endTime");
    String contactNo = request.getParameter("contactNo");

    if (lastName != null && firstName != null && departmentName != null &&
        startTimeStr != null && endTimeStr != null && contactNo != null) {

        newStaff.lastName = lastName;
        newStaff.firstName = firstName;
        newStaff.departmentName = departmentName;

        try {
            // Parse time strings into Time objects
            SimpleDateFormat sdf = new SimpleDateFormat("HH:mm");
            Date startDate = sdf.parse(startTimeStr);
            Date endDate = sdf.parse(endTimeStr);

            newStaff.startTime = new Time(startDate.getTime());
            newStaff.endTime = new Time(endDate.getTime());
        } catch (Exception e) {
            out.println("Error parsing times: " + e.getMessage());
        }

        newStaff.contactNo = contactNo;
        
        try {
            // Explicitly load the MySQL JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver"); // Ensure JDBC driver is loaded
            } catch (ClassNotFoundException e) {
                out.println("Error loading MySQL driver: " + e.getMessage());
            }
                
        
        // Add the staff member to the database
        int result = newStaff.addStaff();
        if (result == 1) {
            out.println("<h2>Staff registered successfully!</h2>");
        } else {
            out.println("<h2>Error registering staff. Please try again.</h2>");
        }
    }
%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title> Manage Patient </title>
        <link rel="stylesheet" href="../styles.css"> 
    </head>
<body>
    <div class="container">
    <h1>Register New Staff</h1>
    <form method="POST">
        <label for="firstName">First Name:</label>
        <input type="text" name="firstName" required><br><br>

        <label for="lastName">Last Name:</label>
        <input type="text" name="lastName" required><br><br>

        <label for="departmentName">Department:</label>
        <input type="text" name="departmentName" required><br><br>

        <label for="startTime">Start Time (HH:mm):</label>
        <input type="text" name="startTime" required><br><br>

        <label for="endTime">End Time (HH:mm):</label>
        <input type="text" name="endTime" required><br><br>

        <label for="contactNo">Contact Number:</label>
        <input type="text" name="contactNo" required><br><br>

        <input type="submit" value="Register">
    </form>
    </div>
</body>
</html>


