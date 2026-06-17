// Parameters
frame_size_mm = 80; //[40:160:1]
body_length_mm = 120; //[60:240:1]
corner_radius_mm = 2; //[1:6:0.5]
flange_outer_diameter_mm = 90; //[60:140:1]
flange_thickness_mm = 6; //[3:15:0.5]
mount_hole_count = 4; //[4:4:1]
mount_hole_diameter_mm = 6.5; //[3:12:0.1]
mount_hole_pitch_mm = 70; //[40:120:1]
shaft_diameter_mm = 19; //[8:35:0.1]
shaft_length_mm = 35; //[10:80:1]
shaft_flat_depth_mm = 1.5; //[0.5:4:0.1]
shaft_flat_length_mm = 25; //[5:60:1]
shaft_center_to_face_mm = 0; //[0:10:0.5]
rear_cap_thickness_mm = 8; //[3:20:0.5]
connector_boss_width_mm = 30; //[15:60:1]
connector_boss_height_mm = 18; //[10:40:1]
connector_boss_depth_mm = 12; //[6:30:1]
connector_port_diameter_mm = 10; //[4:25:0.5]
connector_port_depth_mm = 8; //[3:25:1]
overlap_mm = 1; //[0.5:2:0.1]

// Servo Motor - complete geometry
module servo_motor() {
  color([0.15, 0.2, 0.35]) {
    // Body with rounded corners
    difference() {
      minkowski() {
        cube([frame_size_mm, frame_size_mm, body_length_mm], center=true);
        sphere(r=corner_radius_mm, center=true);
      }
      // Rear cap
      translate([0, 0, -body_length_mm/2 - rear_cap_thickness_mm/2 + overlap_mm])
        cylinder(r=frame_size_mm/2, h=rear_cap_thickness_mm, center=true);
    }
    
    // Front flange with mounting holes
    difference() {
      translate([0, 0, body_length_mm/2 + flange_thickness_mm/2 - overlap_mm])
        cylinder(r=flange_outer_diameter_mm/2, h=flange_thickness_mm, center=true);
      for (i = [0:3]) {
        rotate([0, 0, i*90])
          translate([mount_hole_pitch_mm/2, mount_hole_pitch_mm/2, 0])
            cylinder(r=mount_hole_diameter_mm/2, h=flange_thickness_mm + 2*overlap_mm, center=true);
      }
    }
    
    // Output shaft with flat
    difference() {
      translate([0, 0, body_length_mm/2 + flange_thickness_mm - overlap_mm + shaft_center_to_face_mm + shaft_length_mm/2])
        cylinder(r=shaft_diameter_mm/2, h=shaft_length_mm, center=true);
      translate([shaft_diameter_mm/2 - shaft_flat_depth_mm/2, 0, body_length_mm/2 + flange_thickness_mm - overlap_mm + shaft_center_to_face_mm + shaft_flat_length_mm/2])
        cube([shaft_diameter_mm, shaft_diameter_mm, shaft_flat_length_mm], center=true);
    }
    
    // Rear connector boss with port
    difference() {
      translate([0, 0, -body_length_mm/2 - rear_cap_thickness_mm - connector_boss_depth_mm/2 + overlap_mm])
        cube([connector_boss_width_mm, connector_boss_height_mm, connector_boss_depth_mm], center=true);
      translate([0, 0, -body_length_mm/2 - rear_cap_thickness_mm - connector_boss_depth_mm + connector_port_depth_mm/2 + overlap_mm])
        rotate([90, 0, 0])
          cylinder(r=connector_port_diameter_mm/2, h=connector_port_depth_mm + 2*overlap_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  servo_motor();
}

assembly();