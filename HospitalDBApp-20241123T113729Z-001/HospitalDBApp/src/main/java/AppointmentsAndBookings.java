package hospitalmgt;

import java.sql.*;
import java.util.List;

public class AppointmentsAndBookings {

    public int appointmentId;
    public int doctorId;
    public int patientId;
    public int bookingId;
    public int roomId;
    public List<Integer> equipmentIds;
    public String connection;

    public AppointmentsAndBookings() {
        this.appointmentId = 0;
        this.doctorId = 0;
        this.patientId = 0;
        this.bookingId = 0;
        this.roomId = 0;
        this.connection = "jdbc:mysql://localhost:3306/hospitaldb?useTimezone=true&serverTimezone=UTC&user=root&password=1234";
    }

    public int addAppointment(Timestamp startTime, Timestamp endTime, int roomId, List<Integer> equipmentIds) {
        try {
            Connection conn = DriverManager.getConnection(this.connection);
            System.out.println("Connection to DB Successful");

            // Step 1: Get the next booking_id
            PreparedStatement pstmt = conn.prepareStatement("SELECT MAX(booking_id) + 1 AS newBookingId FROM bookings");
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                this.bookingId = rs.getInt("newBookingId");
            }
            rs.close();
            pstmt.close();

            // Insert into bookings
            String bookingQuery = "INSERT INTO bookings (booking_id, room_id, start_time, end_time) VALUES (?, ?, ?, ?)";
            PreparedStatement bookingStmt = conn.prepareStatement(bookingQuery);
            bookingStmt.setInt(1, this.bookingId); // Set the generated booking ID
            bookingStmt.setInt(2, roomId);
            bookingStmt.setTimestamp(3, startTime);
            bookingStmt.setTimestamp(4, endTime);
            bookingStmt.executeUpdate();
            bookingStmt.close();

            // Step 2: Get the next appointment_id
            pstmt = conn.prepareStatement("SELECT MAX(appointment_id) + 1 AS newAppointmentId FROM appointments");
            rs = pstmt.executeQuery();
            if (rs.next()) {
                this.appointmentId = rs.getInt("newAppointmentId");
            }
            rs.close();
            pstmt.close();

            // Insert into appointments
            String appointmentQuery = "INSERT INTO appointments (appointment_id, booking_id, doctor_id, patient_id, appointment_date, start_time, end_time) VALUES (?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement appointmentStmt = conn.prepareStatement(appointmentQuery);
            appointmentStmt.setInt(1, this.appointmentId); // Set the generated appointment ID
            appointmentStmt.setInt(2, this.bookingId);
            appointmentStmt.setInt(3, this.doctorId);
            appointmentStmt.setInt(4, this.patientId);
            appointmentStmt.setTimestamp(5, new Timestamp(System.currentTimeMillis())); // Current date
            appointmentStmt.setTimestamp(6, startTime);
            appointmentStmt.setTimestamp(7, endTime);
            appointmentStmt.executeUpdate();
            appointmentStmt.close();
            
        // Step 3: Get the next equipmentBookingID
        pstmt = conn.prepareStatement("SELECT MAX(equipmentBookingID) AS maxEquipmentBookingID FROM equipment_booking");
        rs = pstmt.executeQuery();
        int nextEquipmentBookingID = 1; // Default to 1 if table is empty
        if (rs.next()) {
            nextEquipmentBookingID = rs.getInt("maxEquipmentBookingID") + 1;
        }
        rs.close();
        pstmt.close();

        // Step 4: Insert into equipment_bookings
        if (equipmentIds != null && !equipmentIds.isEmpty()) {
            String equipmentQuery = "INSERT INTO equipment_booking (equipmentBookingID, equipmentID, booking_id) VALUES (?, ?, ?)";
            PreparedStatement equipmentStmt = conn.prepareStatement(equipmentQuery);

            for (int equipmentId : equipmentIds) {
                equipmentStmt.setInt(1, nextEquipmentBookingID++); // Increment ID for each equipment
                equipmentStmt.setInt(2, equipmentId);
                equipmentStmt.setInt(3, this.bookingId);
                equipmentStmt.addBatch();
            }

            equipmentStmt.executeBatch();
            equipmentStmt.close();
        }

        conn.close();
            return 1; // Success
        } catch (Exception e) {
            System.out.println("Error: " + e.getMessage());
            return 0; // Failure
        }
    }

    public int deleteAppointment(int appointmentId) {
        try {
            Connection conn = DriverManager.getConnection(this.connection);
            System.out.println("Connection to DB Successful");

            // Step 1: Find the booking_id and room_id associated with the appointment
            String findBookingQuery = "SELECT booking_id FROM appointments WHERE appointment_id = ?";
            PreparedStatement findBookingStmt = conn.prepareStatement(findBookingQuery);
            findBookingStmt.setInt(1, appointmentId);

            ResultSet rs = findBookingStmt.executeQuery();
            if (rs.next()) {
                this.bookingId = rs.getInt("booking_id");
            } else {
                System.out.println("Appointment not found.");
                return 0; // Failure
            }
            rs.close();
            findBookingStmt.close();

            // Step 2: Delete from equipment_bookings
            String deleteEquipmentQuery = "DELETE FROM equipment_booking WHERE booking_id = ?";
            PreparedStatement deleteEquipmentStmt = conn.prepareStatement(deleteEquipmentQuery);
            deleteEquipmentStmt.setInt(1, this.bookingId);
            deleteEquipmentStmt.executeUpdate();
            deleteEquipmentStmt.close();

            // Step 3: Delete from appointments
            String deleteAppointmentQuery = "DELETE FROM appointments WHERE appointment_id = ?";
            PreparedStatement deleteAppointmentStmt = conn.prepareStatement(deleteAppointmentQuery);
            deleteAppointmentStmt.setInt(1, appointmentId);
            deleteAppointmentStmt.executeUpdate();
            deleteAppointmentStmt.close();

            // Step 4: Delete from bookings
            String deleteBookingQuery = "DELETE FROM bookings WHERE booking_id = ?";
            PreparedStatement deleteBookingStmt = conn.prepareStatement(deleteBookingQuery);
            deleteBookingStmt.setInt(1, this.bookingId);
            deleteBookingStmt.executeUpdate();
            deleteBookingStmt.close();

            conn.close();
            return 1; // Success
        } catch (Exception e) {
            System.out.println("Error: " + e.getMessage());
            return 0; // Failure
        }
    }
}
