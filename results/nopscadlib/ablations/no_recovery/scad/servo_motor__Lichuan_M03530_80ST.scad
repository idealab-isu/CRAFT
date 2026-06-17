// Parameters
motor_frame_size_mm = 80; //[40:160:1]
body_length_mm = 110; //[55:220:1]
body_corner_radius_mm = 2; //[1:6:1]
faceplate_thickness_mm = 8; //[4:16:1]
faceplate_size_mm = 80; //[40:160:1]
mount_hole_pattern_mm = 65; //[40:120:1]
mount_hole_diameter_mm = 6.5; //[3:12:0.1]
mount_hole_depth_mm = 12; //[6:30:1]
pilot_diameter_mm = 50; //[25:100:1]
pilot_length_mm = 2.5; //[1:8:0.1]
shaft_diameter_mm = 19; //[6:40:0.1]
shaft_length_mm = 35; //[10:80:1]
rear_cap_diameter_mm = 72; //[36:140:1]
rear_cap_length_mm = 12; //[6:30:1]
rear_connector_width_mm = 30; //[15:60:1]
rear_connector_height_mm = 20; //[10:50:1]
rear_connector_length_mm = 18; //[8:40:1]
overlap_mm = 1; //[0.5:2:0.1]
hole_clearance_mm = 0.2; //[0:0.6:0.05]

// Servo Motor - complete geometry
module servo_motor() {
  color([0.15, 0.2, 0.35]) {
    // Motor Body
    translate([0, 0, 0])
      cube([motor_frame_size_mm, body_length_mm, motor_frame_size_mm], center=true);

    // Front Faceplate
    translate([0, (body_length_mm/2) + (faceplate_thickness_mm/2) - overlap_mm, 0])
      cube([faceplate_size_mm, faceplate_thickness_mm, faceplate_size_mm], center=true);

    // Shaft Boss/Flange
    translate([0, (body_length_mm/2) + faceplate_thickness_mm - overlap_mm + (pilot_length_mm/2), 0])
      cylinder(r=pilot_diameter_mm/2, h=pilot_length_mm, center=true, $fn=64);

    // Output Shaft
    color("Silver")
    translate([0, (body_length_mm/2) + faceplate_thickness_mm + pilot_length_mm - overlap_mm + (shaft_length_mm/2), 0])
      cylinder(r=shaft_diameter_mm/2, h=shaft_length_mm, center=true, $fn=64);

    // Rear Cap
    translate([0, -(body_length_mm/2) - (rear_cap_length_mm/2) + overlap_mm, 0])
      cylinder(r=rear_cap_diameter_mm/2, h=rear_cap_length_mm, center=true, $fn=64);

    // Rear Connector Block
    translate([0, -(body_length_mm/2) - rear_cap_length_mm + overlap_mm - (rear_connector_length_mm/2), 0])
      cube([rear_connector_width_mm, rear_connector_length_mm, rear_connector_height_mm], center=true);
  }

  // Mounting Holes
  color("Black")
  difference() {
    union() {
      translate([mount_hole_pattern_mm/2, (body_length_mm/2) + (faceplate_thickness_mm/2) - overlap_mm - (mount_hole_depth_mm/2), mount_hole_pattern_mm/2])
        cylinder(r=(mount_hole_diameter_mm + hole_clearance_mm)/2, h=faceplate_thickness_mm + mount_hole_depth_mm + overlap_mm*2, center=true, $fn=32);
      translate([-mount_hole_pattern_mm/2, (body_length_mm/2) + (faceplate_thickness_mm/2) - overlap_mm - (mount_hole_depth_mm/2), mount_hole_pattern_mm/2])
        cylinder(r=(mount_hole_diameter_mm + hole_clearance_mm)/2, h=faceplate_thickness_mm + mount_hole_depth_mm + overlap_mm*2, center=true, $fn=32);
      translate([-mount_hole_pattern_mm/2, (body_length_mm/2) + (faceplate_thickness_mm/2) - overlap_mm - (mount_hole_depth_mm/2), -mount_hole_pattern_mm/2])
        cylinder(r=(mount_hole_diameter_mm + hole_clearance_mm)/2, h=faceplate_thickness_mm + mount_hole_depth_mm + overlap_mm*2, center=true, $fn=32);
      translate([mount_hole_pattern_mm/2, (body_length_mm/2) + (faceplate_thickness_mm/2) - overlap_mm - (mount_hole_depth_mm/2), -mount_hole_pattern_mm/2])
        cylinder(r=(mount_hole_diameter_mm + hole_clearance_mm)/2, h=faceplate_thickness_mm + mount_hole_depth_mm + overlap_mm*2, center=true, $fn=32);
    }
  }
}

// Assembly
module assembly() {
  servo_motor();
}

assembly();