// Parameters
motor_frame_size_mm = 80; //[40:160:1]
body_length_mm = 110; //[60:220:1]
body_width_mm = 80; //[40:160:1]
body_height_mm = 80; //[40:160:1]
flange_outer_diameter_mm = 95; //[60:190:1]
flange_thickness_mm = 6; //[3:12:1]
pilot_diameter_mm = 60; //[30:120:1]
pilot_depth_mm = 2; //[1:6:1]
mount_hole_count = 4; //[4:4:1]
mount_hole_diameter_mm = 6.6; //[3:12:0.1]
mount_hole_pitch_mm = 65; //[40:120:1]
shaft_diameter_mm = 19; //[8:38:0.5]
shaft_length_mm = 40; //[15:80:1]
shaft_key_width_mm = 6; //[3:12:0.5]
shaft_key_depth_mm = 1.5; //[0.5:4:0.1]
rear_cap_length_mm = 18; //[8:40:1]
connector_width_mm = 28; //[14:56:1]
connector_height_mm = 18; //[9:36:1]
connector_depth_mm = 14; //[7:28:1]
overlap_mm = 1; //[0.5:2:0.5]
hole_depth_extra_mm = 2; //[1:6:1]

// Servo Motor - complete geometry
module servo_motor() {
  color([0.15, 0.2, 0.35]) {
    // Body
    translate([0, 0, 0])
      cube([body_width_mm, body_height_mm, body_length_mm], center=true);

    // Front Faceplate Flange
    translate([0, 0, body_length_mm/2 + flange_thickness_mm/2 - overlap_mm])
      difference() {
        cylinder(r=flange_outer_diameter_mm/2, h=flange_thickness_mm, center=true);
        // Mounting holes
        for (x = [-mount_hole_pitch_mm/2, mount_hole_pitch_mm/2])
          for (y = [-mount_hole_pitch_mm/2, mount_hole_pitch_mm/2])
            translate([x, y, 0])
              cylinder(r=mount_hole_diameter_mm/2, h=flange_thickness_mm + pilot_depth_mm + hole_depth_extra_mm, center=true);
      }

    // Pilot Boss
    translate([0, 0, body_length_mm/2 + flange_thickness_mm - overlap_mm + pilot_depth_mm/2])
      cylinder(r=pilot_diameter_mm/2, h=pilot_depth_mm, center=true);

    // Output Shaft
    translate([0, 0, body_length_mm/2 + flange_thickness_mm - overlap_mm + shaft_length_mm/2])
      difference() {
        cylinder(r=shaft_diameter_mm/2, h=shaft_length_mm, center=true);
        // Shaft Key
        translate([shaft_diameter_mm/2 - shaft_key_depth_mm, 0, 0])
          cube([shaft_diameter_mm + 2*overlap_mm, shaft_key_width_mm, shaft_length_mm + 2*overlap_mm], center=true);
      }

    // Rear Endcap
    translate([0, 0, -body_length_mm/2 - rear_cap_length_mm/2 + overlap_mm])
      cylinder(r=flange_outer_diameter_mm/2, h=rear_cap_length_mm, center=true);

    // Cable Connector Boss
    translate([0, body_height_mm/2 + connector_height_mm/2 - overlap_mm, -body_length_mm/2 - rear_cap_length_mm/2 + overlap_mm])
      cube([connector_width_mm, connector_height_mm, connector_depth_mm], center=true);
  }
}

// Assembly
module assembly() {
  servo_motor();
}

assembly();