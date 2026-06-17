// Parameters
motor_frame_size_mm = 80; //[40:160:1]
body_length_mm = 120; //[60:240:1]
body_corner_radius_mm = 2; //[1:6:1]
flange_size_mm = 90; //[60:140:1]
flange_thickness_mm = 6; //[3:15:1]
pilot_diameter_mm = 50; //[25:100:1]
pilot_depth_mm = 2; //[1:8:1]
mount_hole_pitch_mm = 70; //[40:120:1]
mount_hole_diameter_mm = 6.5; //[3:12:0.1]
mount_hole_through_extra_mm = 2; //[1:10:1]
shaft_diameter_mm = 19; //[8:40:0.5]
shaft_length_mm = 40; //[15:100:1]
shaft_flat_depth_mm = 1.0; //[0.5:4:0.1]
shaft_flat_length_mm = 25; //[10:80:1]
rear_cap_diameter_mm = 60; //[30:120:1]
rear_cap_length_mm = 10; //[5:30:1]
rear_connector_width_mm = 30; //[15:60:1]
rear_connector_height_mm = 18; //[10:40:1]
rear_connector_length_mm = 12; //[6:40:1]
overlap_mm = 1; //[0.5:2:0.5]

// Servo Motor - complete geometry
module servo_motor() {
  color([0.15, 0.2, 0.35]) {
    // Motor Body with rounded corners
    difference() {
      minkowski() {
        translate([0, 0, -(body_length_mm/2)])
          cube([motor_frame_size_mm, motor_frame_size_mm, body_length_mm], center=true);
        sphere(r=body_corner_radius_mm, center=true);
      }
      // Rear Cap
      translate([0, 0, -body_length_mm - rear_cap_length_mm/2 + overlap_mm])
        cylinder(r=rear_cap_diameter_mm/2, h=rear_cap_length_mm, center=true);
      // Rear Connector Boss
      translate([0, 0, -body_length_mm - rear_cap_length_mm + rear_connector_length_mm/2 + overlap_mm])
        cube([rear_connector_width_mm, rear_connector_height_mm, rear_connector_length_mm], center=true);
    }
    
    // Front Flange with Pilot
    translate([0, 0, flange_thickness_mm/2 - overlap_mm])
      difference() {
        union() {
          cube([flange_size_mm, flange_size_mm, flange_thickness_mm], center=true);
          translate([0, 0, flange_thickness_mm - overlap_mm + pilot_depth_mm/2])
            cylinder(r=pilot_diameter_mm/2, h=pilot_depth_mm, center=true);
        }
        // Mounting Holes
        for (x = [-1, 1], y = [-1, 1]) {
          translate([x * mount_hole_pitch_mm/2, y * mount_hole_pitch_mm/2, flange_thickness_mm/2 - overlap_mm])
            cylinder(r=mount_hole_diameter_mm/2, h=flange_thickness_mm + mount_hole_through_extra_mm, center=true);
        }
      }
    
    // Output Shaft with Flat
    translate([0, 0, flange_thickness_mm + shaft_length_mm/2 - overlap_mm])
      difference() {
        cylinder(r=shaft_diameter_mm/2, h=shaft_length_mm, center=true);
        translate([(shaft_diameter_mm/2 - shaft_flat_depth_mm) + (shaft_diameter_mm*2)/2, 0, flange_thickness_mm + shaft_length_mm - shaft_flat_length_mm/2])
          cube([shaft_diameter_mm*2, shaft_diameter_mm*2, shaft_flat_length_mm], center=true);
      }
  }
}

// Assembly
module assembly() {
  servo_motor();
}

assembly();