// Parameters
motor_frame_size_mm = 80; //[40:160:1]
housing_width_mm = 80; //[40:160:1]
housing_height_mm = 80; //[40:160:1]
body_length_mm = 130; //[65:260:1]
flange_thickness_mm = 8; //[4:16:1]
flange_outer_size_mm = 90; //[45:180:1]
mount_hole_count = 4; //[4:4:1]
mount_hole_pitch_mm = 70; //[35:140:1]
mount_hole_diameter_mm = 6.5; //[3:13:0.1]
shaft_diameter_mm = 19; //[9.5:38:0.1]
shaft_protrusion_mm = 35; //[18:70:1]
shaft_key_width_mm = 6; //[3:12:0.1]
shaft_key_height_mm = 2; //[1:4:0.1]
rear_cap_length_mm = 25; //[12:50:1]
rear_cap_diameter_mm = 70; //[35:140:1]
connector_width_mm = 30; //[15:60:1]
connector_height_mm = 20; //[10:40:1]
connector_depth_mm = 18; //[9:36:1]
corner_fillet_radius_mm = 2; //[0:6:0.5]
overlap_mm = 1; //[0.5:2:0.1]
overall_length_mm = 163; //[82:326:1]

// Servo Motor - complete geometry
module servo_motor() {
  color([0.15, 0.2, 0.35]) {
    // Main housing
    translate([0, 0, 0])
      cube([housing_width_mm, housing_height_mm, body_length_mm], center=true);

    // Front flange/faceplate with mounting holes
    difference() {
      translate([0, 0, body_length_mm/2 + flange_thickness_mm/2 - overlap_mm])
        cube([flange_outer_size_mm, flange_outer_size_mm, flange_thickness_mm], center=true);
      for (x = [-mount_hole_pitch_mm/2, mount_hole_pitch_mm/2])
        for (y = [-mount_hole_pitch_mm/2, mount_hole_pitch_mm/2])
          translate([x, y, body_length_mm/2 + flange_thickness_mm/2 - overlap_mm])
            cylinder(r=mount_hole_diameter_mm/2, h=flange_thickness_mm + overlap_mm*4, center=true);
    }

    // Output shaft
    color("Silver")
    translate([0, 0, body_length_mm/2 + flange_thickness_mm + shaft_protrusion_mm/2 - overlap_mm])
      cylinder(r=shaft_diameter_mm/2, h=shaft_protrusion_mm, center=true);

    // Shaft key/flat
    translate([shaft_diameter_mm/2 - shaft_key_height_mm/2, 0, body_length_mm/2 + flange_thickness_mm + (shaft_protrusion_mm*0.6)/2 - overlap_mm])
      cube([shaft_key_width_mm, shaft_diameter_mm, shaft_protrusion_mm*0.6], center=true);

    // Rear cap/encoder housing
    translate([0, 0, -body_length_mm/2 - rear_cap_length_mm/2 + overlap_mm])
      cylinder(r=rear_cap_diameter_mm/2, h=rear_cap_length_mm, center=true);

    // Cable connector block
    translate([0, housing_height_mm/2 + connector_height_mm/2 - overlap_mm, -body_length_mm/2 - rear_cap_length_mm + connector_depth_mm/2 + overlap_mm])
      cube([connector_width_mm, connector_height_mm, connector_depth_mm], center=true);

    // Corner details on front flange
    for (x = [-1, 1])
      for (y = [-1, 1])
        translate([x * (flange_outer_size_mm/2 - corner_fillet_radius_mm), y * (flange_outer_size_mm/2 - corner_fillet_radius_mm), body_length_mm/2 + flange_thickness_mm/2 - overlap_mm])
          cube([corner_fillet_radius_mm*2, corner_fillet_radius_mm*2, flange_thickness_mm], center=true);
  }
}

// Assembly
module assembly() {
  servo_motor();
}

assembly();