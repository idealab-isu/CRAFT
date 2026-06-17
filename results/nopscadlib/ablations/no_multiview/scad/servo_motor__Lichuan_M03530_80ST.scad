// Parameters
frame_size_mm = 80; //[40:160:1]
housing_length_mm = 110; //[55:220:1]
corner_radius_mm = 3; //[1:8:0.5]
flange_size_mm = 90; //[60:140:1]
flange_thickness_mm = 6; //[3:15:0.5]
pilot_diameter_mm = 55; //[30:90:0.5]
pilot_length_mm = 2.5; //[1:8:0.5]
mount_hole_count = 4; //[4:4:1]
mount_hole_diameter_mm = 6.6; //[3:12:0.1]
mount_hole_pitch_mm = 70; //[40:110:1]
shaft_diameter_mm = 19; //[8:35:0.5]
shaft_length_mm = 40; //[15:80:1]
shaft_flat_depth_mm = 1.0; //[0.2:3:0.1]
shaft_flat_length_mm = 28; //[10:60:1]
rear_endcap_thickness_mm = 6; //[3:15:0.5]
rear_endcap_diameter_mm = 78; //[50:120:1]
rear_connector_width_mm = 28; //[14:60:1]
rear_connector_height_mm = 18; //[10:40:1]
rear_connector_depth_mm = 16; //[8:40:1]
connector_offset_y_mm = 0; //[-20:20:1]
overlap_mm = 1; //[0.5:2:0.1]

// Servo Motor - complete geometry
module servo_motor() {
  // Main housing
  color([0.15, 0.2, 0.35]) {
    translate([0, 0, 0])
      cube([frame_size_mm, frame_size_mm, housing_length_mm], center=true);
  }
  
  // Front flange/faceplate
  color([0.15, 0.2, 0.35]) {
    translate([0, 0, housing_length_mm/2 + flange_thickness_mm/2 - overlap_mm])
      difference() {
        cube([flange_size_mm, flange_size_mm, flange_thickness_mm], center=true);
        // Mounting holes
        for (x = [-1, 1], y = [-1, 1]) {
          translate([x * mount_hole_pitch_mm/2, y * mount_hole_pitch_mm/2, 0])
            cylinder(r=mount_hole_diameter_mm/2, h=flange_thickness_mm + overlap_mm*2, center=true);
        }
      }
  }
  
  // Front pilot boss
  color([0.15, 0.2, 0.35]) {
    translate([0, 0, housing_length_mm/2 + flange_thickness_mm + pilot_length_mm/2 - overlap_mm])
      cylinder(r=pilot_diameter_mm/2, h=pilot_length_mm, center=true);
  }
  
  // Output shaft with flat
  color("Silver") {
    translate([0, 0, housing_length_mm/2 + flange_thickness_mm + pilot_length_mm + shaft_length_mm/2 - overlap_mm])
      difference() {
        cylinder(r=shaft_diameter_mm/2, h=shaft_length_mm, center=true);
        translate([shaft_diameter_mm/2 - shaft_flat_depth_mm + overlap_mm/2, 0, 0])
          cube([shaft_diameter_mm, shaft_diameter_mm*2, shaft_flat_length_mm], center=true);
      }
  }
  
  // Rear endcap
  color([0.15, 0.2, 0.35]) {
    translate([0, 0, -housing_length_mm/2 - rear_endcap_thickness_mm/2 + overlap_mm])
      cylinder(r=rear_endcap_diameter_mm/2, h=rear_endcap_thickness_mm, center=true);
  }
  
  // Cable connector block
  color([0.15, 0.2, 0.35]) {
    translate([0, connector_offset_y_mm, -housing_length_mm/2 - rear_endcap_thickness_mm + rear_connector_height_mm/2 + overlap_mm])
      cube([rear_connector_width_mm, rear_connector_depth_mm, rear_connector_height_mm], center=true);
  }
}

// Assembly
module assembly() {
  servo_motor();
}

assembly();