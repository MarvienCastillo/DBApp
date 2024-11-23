<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="hospitalmgt.AppointmentsAndBookings" %>

<%
    // Variables to hold database connection and results
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet doctorRs = null, patientRs = null, roomRs = null, equipmentRs = null;

    try {
        // Load the database driver and establish connection
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/hospitaldb?useTimezone=true&serverTimezone=UTC&user=root&password=1234");

        // Fetch available doctors
        String doctorQuery = "SELECT d.doctors_id, s.first_name, s.last_name " +
                             "FROM doctors d " +
                             "JOIN staff s ON d.staff_id = s.staff_id";
        pstmt = conn.prepareStatement(doctorQuery);
        doctorRs = pstmt.executeQuery();

        // Fetch patients
        String patientQuery = "SELECT patient_id, first_name, last_name FROM patients";
        pstmt = conn.prepareStatement(patientQuery);
        patientRs = pstmt.executeQuery();

        // Fetch rooms
        String roomQuery = "SELECT room_id, room_type FROM rooms";
        pstmt = conn.prepareStatement(roomQuery);
        roomRs = pstmt.executeQuery();

        // Fetch equipment
        String equipmentQuery = "SELECT equipment_id, name FROM hospital_equipments";
        pstmt = conn.prepareStatement(equipmentQuery);
        equipmentRs = pstmt.executeQuery();
%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Add Appointment</title>
        <link rel="stylesheet" href="../styles.css">
    </head>
<body>
    <h1>Add Appointment</h1>
    <form method="POST" action="addAppointment.jsp">
        <!-- Appointment Date -->
        <label for="appointmentDate">Date:</label>
        <input type="date" name="appointmentDate" required><br><br>

        <!-- Appointment Start Time -->
        <label for="startTime">Start Time:</label>
        <input type="time" name="startTime" required><br><br>

        <!-- Appointment End Time -->
        <label for="endTime">End Time:</label>
        <input type="time" name="endTime" required><br><br>

        <!-- Select Doctor -->
        <label for="doctorId">Doctor:</label>
        <select name="doctorId" required>
            <option value="">Select a Doctor</option>
            <%
                while (doctorRs.next()) {
                    int doctorId = doctorRs.getInt("doctors_id");
                    String doctorName = doctorRs.getString("first_name") + " " + doctorRs.getString("last_name");
                    out.println("<option value='" + doctorId + "'>" + doctorName + "</option>");
                }
            %>
        </select><br><br>

        <!-- Select Patient -->
        <label for="patientId">Patient:</label>
        <select name="patientId" required>
            <option value="">Select a Patient</option>
            <%
                while (patientRs.next()) {
                    int patientId = patientRs.getInt("patient_id");
                    String patientName = patientRs.getString("first_name") + " " + patientRs.getString("last_name");
                    out.println("<option value='" + patientId + "'>" + patientName + "</option>");
                }
            %>
        </select><br><br>

        <!-- Select Room -->
        <label for="roomId">Room:</label>
        <select name="roomId" required>
            <option value="">Select a Room</option>
            <%
                while (roomRs.next()) {
                    int roomId = roomRs.getInt("room_id");
                    String roomName = roomRs.getString("room_type");
                    out.println("<option value='" + roomId + "'>" + roomName + "</option>");
                }
            %>
        </select><br><br>

        <!-- Select Equipment (Multiple) -->
        <label for="equipmentIds">Equipment:</label>
        <select name="equipmentIds" multiple>
            <%
                while (equipmentRs.next()) {
                    int equipmentId = equipmentRs.getInt("equipment_id");
                    String equipmentName = equipmentRs.getString("name");
                    out.println("<option value='" + equipmentId + "'>" + equipmentName + "</option>");
                }
            %>
        </select><br><br>
        <!-- Submit Button -->
        <input type="submit" value="Add Appointment">
    </form>
</body>
</html>

<%
           // Process form submission
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        // Fetch form inputs
        String appointmentDate = request.getParameter("appointmentDate");
        String startTime = request.getParameter("startTime");
        String endTime = request.getParameter("endTime");
        int doctorId = Integer.parseInt(request.getParameter("doctorId"));
        int patientId = Integer.parseInt(request.getParameter("patientId"));
        int roomId = Integer.parseInt(request.getParameter("roomId"));
        String[] equipmentIdsArray = request.getParameterValues("equipmentIds");

        // Convert equipment IDs to List<Integer>
        List<Integer> equipmentIds = new ArrayList<>();
        if (equipmentIdsArray != null) {
            for (String equipmentId : equipmentIdsArray) {
                equipmentIds.add(Integer.parseInt(equipmentId));
            }
        }

        // Parse start and end times
        Timestamp startTimestamp = Timestamp.valueOf(appointmentDate + " " + startTime + ":00");
        Timestamp endTimestamp = Timestamp.valueOf(appointmentDate + " " + endTime + ":00");

        // Create a new instance of AppointmentsAndBookings and set values
        AppointmentsAndBookings appointment = new AppointmentsAndBookings();
        appointment.doctorId = doctorId;
        appointment.patientId = patientId;

        // Call addAppointment and check success
        int successful = appointment.addAppointment(startTimestamp, endTimestamp, roomId, equipmentIds);
        if (successful == 1) {
            out.println("<h2>Appointment added successfully!</h2>");
        } else {
            out.println("<h2>Failed to add appointment. Please try again.</h2>");
        }
    }
    // Close resources
    doctorRs.close();
    patientRs.close();
    roomRs.close();
    equipmentRs.close();
    pstmt.close();
    conn.close();
    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
}
%>

