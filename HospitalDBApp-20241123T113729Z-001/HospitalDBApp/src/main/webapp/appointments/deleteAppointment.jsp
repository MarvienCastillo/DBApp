<%@ page import="java.sql.*" %>
<%@ page import="hospitalmgt.AppointmentsAndBookings" %>

<%
    // Database connection and result variables
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        // Establish database connection
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/hospitaldb?useTimezone=true&serverTimezone=UTC&user=root&password=1234");

        // Fetch all appointments
        String appointmentQuery = "SELECT a.appointment_id, a.start_time, a.end_time, a.appointment_date, " +
                                  "s.first_name AS doctor_first_name, s.last_name AS doctor_last_name, " +
                                  "p.first_name AS patient_first_name, p.last_name AS patient_last_name " +
                                  "FROM appointments a " +
                                  "JOIN doctors d ON a.doctor_id = d.doctors_id " +
                                  "JOIN staff s  ON s.staff_id  = d.staff_id " +
                                  "JOIN patients p ON a.patient_id = p.patient_id";
        pstmt = conn.prepareStatement(appointmentQuery);
        rs = pstmt.executeQuery();
%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Delete Appointment</title>
        <link rel="stylesheet" href="../styles.css">
    </head>
<body>
    <h1>Delete Appointment</h1>
    <form method="POST" action="">
        <label for="appointmentId">Appointment:</label>
        <select name="appointmentId" required>
            <option value="">Select an Appointment</option>
            <%
                while (rs.next()) {
                    int appointmentId = rs.getInt("appointment_id");
                    String doctorName = rs.getString("doctor_first_name") + " " + rs.getString("doctor_last_name");
                    String patientName = rs.getString("patient_first_name") + " " + rs.getString("patient_last_name");
                    String dateTime = rs.getDate("appointment_date") + " " + rs.getTime("start_time");
                    out.println("<option value='" + appointmentId + "'>" + appointmentId + " - " + dateTime + " - Doctor: " + doctorName + " - Patient: " + patientName + "</option>");
                }
            %>
        </select><br><br>

        <input type="submit" value="Delete Appointment">
    </form>

    <%
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            int appointmentId = Integer.parseInt(request.getParameter("appointmentId"));

            // Use AppointmentsAndBookings class to delete the appointment
            AppointmentsAndBookings appointmentManager = new AppointmentsAndBookings();
            int success = appointmentManager.deleteAppointment(appointmentId);

            if (success == 1) {
                out.println("<h2>Appointment deleted successfully!</h2>");
            } else {
                out.println("<h2>Failed to delete appointment. Please try again.</h2>");
            }
        }
    %>
</body>
</html>

<%
    // Close database resources
    if (rs != null) rs.close();
    if (pstmt != null) pstmt.close();
    if (conn != null) conn.close();
    } catch (Exception e) {
        out.println("<h2>Error: " + e.getMessage() + "</h2>");
    }
%>
