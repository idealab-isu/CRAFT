// Parameters
motor_frame_size_mm = 80; //[40:160:1]
body_length_mm = 120; //[60:240:1]
body_width_mm = 80; //[40:160:1]
body_height_mm = 80; //[40:160:1]
flange_thickness_mm = 8; //[4:16:1]
flange_outer_diameter_mm = 90; //[45:180:1]
pilot_diameter_mm = 60; //[30:120:1]
pilot_height_mm = 2.5; //[1:8:0.5]
shaft_diameter_mm = 19; //[9.5:38:0.5]
shaft_length_mm = 40; //[20:80:1]
mount_hole_count = 4; //[4:4:1]
mount_hole_diameter_mm = 6.6; //[3.3:13.2:0.1]
mount_hole_square_pitch_mm = 65; //[32.5:130:0.5]
rear_connector_boss_width_mm = 30; //[15:60:1]
rear_connector_boss_height_mm = 20; //[10:40:1]
rear_connector_boss_depth_mm = 15; //[7.5:30:1]
fillet_radius_mm = 2; //[0:6:0.5]
overlap_mm = 1; //[0.5:2:0.1]
hole_depth_extra_mm = 2; //[1:6:0.5]
shaft_flat_depth_mm = 1.0; //[0.5:3.0:0.1]
shaft_flat_length_mm = 25; //[10:60:1]

// Servo Motor - complete geometry
module servo_motor() {
  color([0.15, 0.2, 0.35]) {
    // Body
    translate([0, 0, 0])
      cube([body_width_mm, body_height_mm, body_length_mm], center=true);
    
    // Front Flange Faceplate
    translate([0, 0, body_length_mm/2 + flange_thickness_mm/2 - overlap_mm])
      cylinder(r=flange_outer_diameter_mm/2, h=flange_thickness_mm, center=true, $fn=64);
    
    // Front Pilot
    translate([0, 0, body_length_mm/2 + flange_thickness_mm - overlap_mm + pilot_height_mm/2])
      cylinder(r=pilot_diameter_mm/2, h=pilot_height_mm, center=true, $fn=64);
    
    // Output Shaft with Flat
    difference() {
      translate([0, 0, body_length_mm/2 + flange_thickness_mm - overlap_mm + shaft_length_mm/2])
        cylinder(r=shaft_diameter_mm/2, h=shaft_length_mm, center=true, $fn=64);
      translate([shaft_diameter_mm/2 - shaft_flat_depth_mm, 0, body_length_mm/2 + flange_thickness_mm - overlap_mm + shaft_flat_length_mm/2])
        cube([shaft_diameter_mm, shaft_diameter_mm, shaft_flat_length_mm + hole_depth_extra_mm], center=true);
    }
    
    // Rear Connector Boss
    translate([0, 0, -body_length_mm/2 - rear_connector_boss_depth_mm/2 + overlap_mm])
      cube([rear_connector_boss_width_mm, rear_connector_boss_height_mm, rear_connector_boss_depth_mm], center=true);
  }
  
  // Mounting Holes
  color("Black") {
    translate([mount_hole_square_pitch_mm/2, mount_hole_square_pitch_mm/2, body_length_mm/2 + flange_thickness_mm/2 - overlap_mm])
      cylinder(r=mount_hole_diameter_mm/2, h=flange_thickness_mm + hole_depth_extra_mm, center=true, $fn=32);
    translate([-mount_hole_square_pitch_mm/2, mount_hole_square_pitch_mm/2, body_length_mm/2 + flange_thickness_mm/2 - overlap_mm])
      cylinder(r=mount_hole_diameter_mm/2, h=flange_thickness_mm + hole_depth_extra_mm, center=true, $fn=32);
    translate([-mount_hole_square_pitch_mm/2, -mount_hole_square_pitch_mm/2, body_length_mm/2 + flange_thickness_mm/2 - overlap_mm])
      cylinder(r=mount_hole_diameter_mm/2, h=flange_thickness_mm + hole_depth_extra_mm, center=true, $fn=32);
    translate([mount_hole_square_pitch_mm/2, -mount_hole_square_pitch_mm/2, body_length_mm/2 + flange_thickness_mm/2 - overlap_mm])
      cylinder(r=mount_hole_diameter_mm/2, h=flange_thickness_mm + hole_depth_extra_mm, center=true, $fn=32);
  }
}

// Assembly
module assembly() {
  servo_motor();
}

assembly();