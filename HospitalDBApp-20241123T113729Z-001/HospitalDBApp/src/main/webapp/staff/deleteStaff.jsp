<%@ page import="hospitalmgt.staff" %>

<%
    staff staffToDelete = new staff();

    // Retrieve form input
    String staffIdStr = request.getParameter("staffId");

    if (staffIdStr != null) {
        staffToDelete.staffId = Integer.parseInt(staffIdStr);
        
        try {
            // Explicitly load the MySQL JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver"); // Ensure JDBC driver is loaded
            } catch (ClassNotFoundException e) {
                out.println("Error loading MySQL driver: " + e.getMessage());
            }
                
        
        // Delete the staff member
        int result = staffToDelete.deleteStaff();
        if (result == 1) {
            out.println("<h2>Staff deleted successfully!</h2>");
        } else {
            out.println("<h2>Error deleting staff. Please try again.</h2>");
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
    <h1>Delete Staff</h1>
    <form method="POST">
        <label for="staffId">Staff ID:</label>
        <input type="text" name="staffId" required><br><br>

        <input type="submit" value="Delete">
    </form>
</body>
</html>
