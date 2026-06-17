// Parameters
body_width_mm = 80; //[40:160:1]
body_height_mm = 80; //[40:160:1]
body_length_mm = 130; //[65:260:1]
flange_diameter_mm = 90; //[45:180:1]
flange_thickness_mm = 6; //[3:12:1]
mount_hole_count = 4; //[4:4:1]
mount_hole_diameter_mm = 6.5; //[3.25:13:0.1]
mount_hole_square_pitch_mm = 70; //[35:140:1]
shaft_diameter_mm = 19; //[9.5:38:0.5]
shaft_length_mm = 40; //[20:80:1]
shaft_key_width_mm = 6; //[3:12:0.5]
shaft_key_depth_mm = 2.8; //[1.4:5.6:0.1]
rear_cap_length_mm = 20; //[10:40:1]
encoder_bulge_diameter_mm = 70; //[35:140:1]
encoder_bulge_length_mm = 25; //[12.5:50:1]
connector_width_mm = 25; //[12.5:50:1]
connector_height_mm = 18; //[9:36:1]
connector_depth_mm = 20; //[10:40:1]
overlap_mm = 1; //[0.5:2:0.1]
hole_extra_mm = 2; //[1:6:0.5]

// Servo Motor - complete geometry
module servo_motor() {
  color([0.15, 0.2, 0.35]) {
    // Motor Housing
    translate([0, 0, 0])
      cube([body_width_mm, body_height_mm, body_length_mm], center=true);

    // Front Mounting Flange with Holes
    difference() {
      translate([0, 0, body_length_mm/2 + flange_thickness_mm/2 - overlap_mm])
        cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true, $fn=64);
      for (x = [-1, 1], y = [-1, 1]) {
        translate([x * mount_hole_square_pitch_mm/2, y * mount_hole_square_pitch_mm/2, body_length_mm/2 + flange_thickness_mm/2 - overlap_mm])
          cylinder(r=mount_hole_diameter_mm/2, h=flange_thickness_mm + hole_extra_mm, center=true, $fn=32);
      }
    }

    // Output Shaft
    color("Silver")
    translate([0, 0, body_length_mm/2 + flange_thickness_mm - overlap_mm + shaft_length_mm/2])
      cylinder(r=shaft_diameter_mm/2, h=shaft_length_mm, center=true, $fn=32);

    // Shaft Key or Flat
    translate([shaft_diameter_mm/2 - shaft_key_depth_mm/2, 0, body_length_mm/2 + flange_thickness_mm - overlap_mm + shaft_length_mm/2])
      cube([shaft_diameter_mm, shaft_key_width_mm, shaft_length_mm], center=true);

    // Rear Endcap
    translate([0, 0, -body_length_mm/2 - rear_cap_length_mm/2 + overlap_mm])
      cylinder(r=flange_diameter_mm/2, h=rear_cap_length_mm, center=true, $fn=64);

    // Encoder or Brake Bulge
    translate([0, 0, -body_length_mm/2 - rear_cap_length_mm + overlap_mm + encoder_bulge_length_mm/2])
      cylinder(r=encoder_bulge_diameter_mm/2, h=encoder_bulge_length_mm, center=true, $fn=64);

    // Cable Connector Block
    translate([0, 0, -body_length_mm/2 - rear_cap_length_mm - encoder_bulge_length_mm + overlap_mm + connector_depth_mm/2])
      cube([connector_width_mm, connector_height_mm, connector_depth_mm], center=true);
  }
}

// Assembly
module assembly() {
  servo_motor();
}

assembly();