package hospitalmgt;

import java.sql.*;

public class staff {

    public int staffId;
    public String lastName;
    public String firstName;
    public String departmentName;
    public Time startTime;
    public Time endTime;
    public String contactNo;
    public String connection;

    public staff() {
        this.staffId = 0;
        this.lastName = "";
        this.firstName = "";
        this.departmentName = "";
        this.startTime = null;
        this.endTime = null;
        this.contactNo = "";
        this.connection = "jdbc:mysql://localhost:3306/hospitaldb?useTimezone=true&serverTimezone=UTC&user=root&password=1234";
    }

    private int checkStaff(int staffId) {
        try {
            Connection conn = DriverManager.getConnection(this.connection);
            System.out.println("Connection to DB Successful");

            PreparedStatement checkStmt = conn.prepareStatement("SELECT COUNT(*) FROM staff WHERE staff_id = ?");
            checkStmt.setInt(1, staffId);
            ResultSet rs = checkStmt.executeQuery();
            rs.next();
            int count = rs.getInt(1);
            rs.close();
            checkStmt.close();

            if (count == 0) {
                System.out.println("Staff ID does not exist: " + staffId);
                return 0; // Failure: Staff not found
            }
            return 1; // Staff exists
        } catch (Exception e) {
            System.out.println(e.getMessage());
            return 0;
        }
    }

    public int addStaff() {
        try {
            Connection conn = DriverManager.getConnection(this.connection);
            System.out.println("Connection to DB Successful");

            // Get next staff ID
            PreparedStatement pstmt = conn.prepareStatement("SELECT MAX(staff_id) + 1 AS newID FROM staff");
            ResultSet rst = pstmt.executeQuery();
            while (rst.next()) {
                this.staffId = rst.getInt("newID");
            }

            // Insert new staff record
            pstmt = conn.prepareStatement(
                "INSERT INTO staff (staff_id, last_name, first_name, department_id, start_time, end_time, contact_no) VALUES (?, ?, ?, ?, ?, ?, ?)"
            );
            pstmt.setInt(1, this.staffId);
            pstmt.setString(2, this.lastName);
            pstmt.setString(3, this.firstName);
            pstmt.setInt(4, this.getDepartmentId());
            pstmt.setTime(5, this.startTime);
            pstmt.setTime(6, this.endTime);
            pstmt.setString(7, this.contactNo);

            pstmt.executeUpdate();
            pstmt.close();
            conn.close();

            return 1;
        } catch (Exception e) {
            System.out.println(e.getMessage());
            return 0;
        }
    }

    public int updateStaff() {
        try {
            if (checkStaff(this.staffId) == 0) {
                return 0; // Staff not found
            }

            Connection conn = DriverManager.getConnection(this.connection);
            System.out.println("Connection to DB Successful");

            String query = "UPDATE staff SET last_name = ?, first_name = ?, department_id = ?, start_time = ?, end_time = ?, contact_no = ? WHERE staff_id = ?";
            PreparedStatement pstmt = conn.prepareStatement(query);

            pstmt.setString(1, this.lastName);
            pstmt.setString(2, this.firstName);
            pstmt.setInt(3, this.getDepartmentId());
            pstmt.setTime(4, this.startTime);
            pstmt.setTime(5, this.endTime);
            pstmt.setString(6, this.contactNo);
            pstmt.setInt(7, this.staffId);

            pstmt.executeUpdate();
            pstmt.close();
            conn.close();

            return 1;
        } catch (Exception e) {
            System.out.println(e.getMessage());
            return 0;
        }
    }

    public int deleteStaff() {
        try {
            if (checkStaff(this.staffId) == 0) {
                return 0; // Staff not found
            }

            Connection conn = DriverManager.getConnection(this.connection);
            System.out.println("Connection to DB Successful");

            // Step 1: Set doctor_id to NULL in appointments
            String updateAppointmentsQuery = "UPDATE appointments SET doctor_id = NULL WHERE doctor_id = (SELECT doctors_id FROM doctors WHERE staff_id = ?)";
            PreparedStatement updateAppointmentsStmt = conn.prepareStatement(updateAppointmentsQuery);
            updateAppointmentsStmt.setInt(1, this.staffId);
            updateAppointmentsStmt.executeUpdate();

            // Step 2: Delete from doctors table
            String deleteDoctorsQuery = "DELETE FROM doctors WHERE staff_id = ?";
            PreparedStatement deleteDoctorsStmt = conn.prepareStatement(deleteDoctorsQuery);
            deleteDoctorsStmt.setInt(1, this.staffId);
            deleteDoctorsStmt.executeUpdate();

            // Step 3: Delete from staff table
            String deleteStaffQuery = "DELETE FROM staff WHERE staff_id = ?";
            PreparedStatement deleteStaffStmt = conn.prepareStatement(deleteStaffQuery);
            deleteStaffStmt.setInt(1, this.staffId);
            deleteStaffStmt.executeUpdate();

            // Close all resources
            updateAppointmentsStmt.close();
            deleteDoctorsStmt.close();
            deleteStaffStmt.close();
            conn.close();

            return 1; // Success
        } catch (Exception e) {
            System.out.println("Error: " + e.getMessage());
            return 0; // Failure
        }
    }

    public int viewStaff() {
        try {
            if (checkStaff(this.staffId) == 0) {
                return 0; // Staff not found
            }

            Connection conn = DriverManager.getConnection(this.connection);
            System.out.println("Connection to DB Successful");

            PreparedStatement pstmt = conn.prepareStatement("SELECT * FROM staff WHERE staff_id = ?");
            pstmt.setInt(1, this.staffId);

            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                this.lastName = rs.getString("last_name");
                this.firstName = rs.getString("first_name");
                this.departmentName = getDepartmentName(rs.getInt("department_id"));
                this.startTime = rs.getTime("start_time");
                this.endTime = rs.getTime("end_time");
                this.contactNo = rs.getString("contact_no");

                // Debugging: Print details to console
                System.out.println("Staff Details:");
                System.out.println("Staff ID: " + this.staffId);
                System.out.println("Name: " + this.firstName + " " + this.lastName);
                System.out.println("Department: " + this.departmentName);
                System.out.println("Start Time: " + this.startTime);
                System.out.println("End Time: " + this.endTime);
                System.out.println("Contact Number: " + this.contactNo);
            }

            rs.close();
            pstmt.close();
            conn.close();

            return 1; // Success
        } catch (Exception e) {
            System.out.println(e.getMessage());
            return 0; // Failure
        }
    }

    // Helper method to get department ID based on department name
    private int getDepartmentId() {
        try {
            Connection conn = DriverManager.getConnection(this.connection);
            String query = "SELECT department_id FROM departments WHERE department_name = ?";
            PreparedStatement pstmt = conn.prepareStatement(query);
            pstmt.setString(1, this.departmentName);

            ResultSet rs = pstmt.executeQuery();
            int departmentId = 0;
            if (rs.next()) {
                departmentId = rs.getInt("department_id");
            }

            rs.close();
            pstmt.close();
            conn.close();

            return departmentId;
        } catch (Exception e) {
            System.out.println(e.getMessage());
            return 0;
        }
    }

    // Helper method to get department name based on department ID
    private String getDepartmentName(int departmentId) {
        try {
            Connection conn = DriverManager.getConnection(this.connection);
            String query = "SELECT department_name FROM departments WHERE department_id = ?";
            PreparedStatement pstmt = conn.prepareStatement(query);
            pstmt.setInt(1, departmentId);

            ResultSet rs = pstmt.executeQuery();
            String departmentName = "";
            if (rs.next()) {
                departmentName = rs.getString("department_name");
            }

            rs.close();
            pstmt.close();
            conn.close();

            return departmentName;
        } catch (Exception e) {
            System.out.println(e.getMessage());
            return "";
        }
    }
}
