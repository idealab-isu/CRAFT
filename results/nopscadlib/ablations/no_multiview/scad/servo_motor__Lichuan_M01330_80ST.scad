// Parameters
motor_frame_size_mm = 80; //[40:160:1]
body_length_mm = 120; //[60:240:1]
corner_radius_mm = 2; //[1:6:1]
faceplate_thickness_mm = 8; //[4:16:1]
faceplate_size_mm = 90; //[70:140:1]
pilot_diameter_mm = 60; //[40:100:1]
pilot_length_mm = 2; //[1:6:1]
mount_hole_pitch_mm = 70; //[50:110:1]
mount_hole_diameter_mm = 6.6; //[4:10:0.1]
shaft_diameter_mm = 19; //[10:30:0.1]
shaft_length_mm = 40; //[15:80:1]
shaft_flat_depth_mm = 1; //[0.5:3:0.1]
shaft_flat_length_mm = 25; //[10:60:1]
rear_cap_length_mm = 20; //[10:50:1]
rear_cap_diameter_mm = 78; //[50:140:1]
connector_width_mm = 30; //[15:60:1]
connector_height_mm = 18; //[10:40:1]
connector_length_mm = 16; //[8:40:1]
tolerances_mm = 0.2; //[0.1:0.6:0.05]
overlap_mm = 1; //[0.5:2:0.1]

// Servo Motor - complete geometry
module servo_motor() {
  // Motor Housing
  color([0.15, 0.2, 0.35]) {
    cube([motor_frame_size_mm, motor_frame_size_mm, body_length_mm], center=true);
  }
  
  // Front Faceplate
  translate([0, 0, body_length_mm/2 + faceplate_thickness_mm/2 - overlap_mm]) {
    color([0.15, 0.2, 0.35]) {
      cube([faceplate_size_mm, faceplate_size_mm, faceplate_thickness_mm], center=true);
    }
    // Front Pilot
    color("Silver") {
      translate([0, 0, faceplate_thickness_mm/2 + pilot_length_mm/2]) {
        cylinder(r=pilot_diameter_mm/2, h=pilot_length_mm, center=true);
      }
    }
    // Output Shaft
    color("Silver") {
      translate([0, 0, faceplate_thickness_mm/2 + shaft_length_mm/2]) {
        difference() {
          cylinder(r=shaft_diameter_mm/2, h=shaft_length_mm, center=true);
          translate([shaft_diameter_mm/2 - shaft_flat_depth_mm/2, 0, shaft_length_mm/2 - shaft_flat_length_mm/2]) {
            cube([shaft_diameter_mm, shaft_diameter_mm, shaft_flat_length_mm], center=true);
          }
        }
      }
    }
  }
  
  // Rear Cap
  translate([0, 0, -body_length_mm/2 - rear_cap_length_mm/2 + overlap_mm]) {
    color([0.15, 0.2, 0.35]) {
      cylinder(r=rear_cap_diameter_mm/2, h=rear_cap_length_mm, center=true);
    }
    // Cable Connector Boss
    translate([0, motor_frame_size_mm/2 + connector_length_mm/2 - overlap_mm, 0]) {
      color([0.15, 0.2, 0.35]) {
        cube([connector_width_mm, connector_length_mm, connector_height_mm], center=true);
      }
    }
  }
  
  // Mounting Holes
  color("Black") {
    for (x = [-1, 1], y = [-1, 1]) {
      translate([x * mount_hole_pitch_mm/2, y * mount_hole_pitch_mm/2, body_length_mm/2 + faceplate_thickness_mm/2 - overlap_mm]) {
        cylinder(r=mount_hole_diameter_mm/2, h=faceplate_thickness_mm + 2*overlap_mm, center=true);
      }
    }
  }
}

// Assembly
module assembly() {
  servo_motor();
}

assembly();