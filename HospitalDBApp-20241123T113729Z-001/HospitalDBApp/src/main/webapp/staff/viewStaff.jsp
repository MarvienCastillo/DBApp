<%@ page import="hospitalmgt.staff" %>

<%
    staff staffToView = new staff();

    // Retrieve form input
    String staffIdStr = request.getParameter("staffId");

    if (staffIdStr != null) {
        staffToView.staffId = Integer.parseInt(staffIdStr);

        try {
            // Explicitly load the MySQL JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver"); // Ensure JDBC driver is loaded
        } catch (ClassNotFoundException e) {
            out.println("Error loading MySQL driver: " + e.getMessage());
        }

        // View the staff details
        int result = staffToView.viewStaff();
        if (result == 1) {
%>
            <h2>Staff Details</h2>
            <p><strong>Staff ID:</strong> <%= staffToView.staffId %></p>
            <p><strong>Name:</strong> <%= staffToView.firstName + " " + staffToView.lastName %></p>
            <p><strong>Department:</strong> <%= staffToView.departmentName %></p>
            <p><strong>Start Time:</strong> <%= staffToView.startTime %></p>
            <p><strong>End Time:</strong> <%= staffToView.endTime %></p>
            <p><strong>Contact Number:</strong> <%= staffToView.contactNo %></p>
<%
        } else {
            out.println("<h2>Error: Staff not found. Please try again.</h2>");
        }
    }
%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>View Staff</title>
        <link rel="stylesheet" href="../styles.css">
    </head>
<body>
    <h1>View Staff Details</h1>
    <form method="POST">
        <label for="staffId">Staff ID:</label>
        <input type="text" name="staffId" required><br><br>

        <input type="submit" value="View">
    </form>
</body>
</html>
