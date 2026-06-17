// Parameters
screw_thread_diameter_mm = 5.0; //[2.5:10.0:0.1]
across_flats_mm = 6.0; //[3.0:12.0:0.1]
thickness_mm = 3.7; //[1.85:7.4:0.1]
thread_pitch_mm = 0.8; //[0.5:1.5:0.05]
t_slot_channel_width_mm = 8.0; //[4.0:16.0:0.1]
t_slot_channel_height_mm = 6.0; //[3.0:12.0:0.1]
t_slot_lip_opening_mm = 6.0; //[3.0:12.0:0.1]
t_slot_lip_thickness_mm = 1.5; //[0.75:3.0:0.1]
nut_length_mm = 12.0; //[6.0:24.0:0.5]
corner_chamfer_mm = 0.2; //[0.0:1.0:0.05]
edge_fillet_radius_mm = 0.0; //[0.0:1.5:0.05]
print_tolerance_mm = 0.2; //[0.0:0.6:0.05]
thread_clearance_mode = 0; //[0:1:1]
overlap_mm = 1.0; //[0.5:2.0:0.1]
retention_depth_mm = 0.8; //[0.4:1.6:0.1]
retention_height_mm = 1.2; //[0.6:2.4:0.1]
anti_rotation_flat_depth_mm = 0.6; //[0.3:1.2:0.1]
lead_in_length_mm = 1.2; //[0.6:3.0:0.1]

// Nut and Washer - detailed geometry
module nut_and_washer() {
  color("Silver") {
    // Nut body
    translate([0, 0, thickness_mm/2])
      cube([nut_length_mm, across_flats_mm, thickness_mm], center=true);
    
    // Washer representation
    translate([0, 0, thickness_mm/2 + overlap_mm/2])
      cylinder(r=screw_thread_diameter_mm/2, h=overlap_mm, center=true, $fn=32);
  }
}

// T-slot nut assembly
module assembly() {
  difference() {
    union() {
      // Nut body with retention profile
      translate([0, 0, 0])
        union() {
          translate([0, 0, 0])
            cube([nut_length_mm, across_flats_mm, thickness_mm], center=true);
          translate([0, 0, -thickness_mm/2 + retention_height_mm/2 - overlap_mm])
            cube([nut_length_mm, across_flats_mm + 2*retention_depth_mm, retention_height_mm], center=true);
        }
    }
    // Anti-rotation flats
    translate([0, across_flats_mm/2 - anti_rotation_flat_depth_mm/2 + overlap_mm, 0])
      cube([nut_length_mm + 2*overlap_mm, anti_rotation_flat_depth_mm, thickness_mm + 2*overlap_mm], center=true);
    translate([0, -across_flats_mm/2 + anti_rotation_flat_depth_mm/2 - overlap_mm, 0])
      cube([nut_length_mm + 2*overlap_mm, anti_rotation_flat_depth_mm, thickness_mm + 2*overlap_mm], center=true);
    
    // Lead-in chamfers
    translate([nut_length_mm/2 - lead_in_length_mm/2 + overlap_mm, 0, 0])
      rotate([0, 45, 0])
      cube([lead_in_length_mm, across_flats_mm + 2*retention_depth_mm + 2*overlap_mm, thickness_mm + 2*overlap_mm], center=true);
    translate([-nut_length_mm/2 + lead_in_length_mm/2 - overlap_mm, 0, 0])
      rotate([0, -45, 0])
      cube([lead_in_length_mm, across_flats_mm + 2*retention_depth_mm + 2*overlap_mm, thickness_mm + 2*overlap_mm], center=true);
    
    // Threaded hole
    translate([0, 0, 0])
      cylinder(r=(screw_thread_diameter_mm + print_tolerance_mm + thread_clearance_mode*print_tolerance_mm)/2, h=thickness_mm + 2*overlap_mm, center=true, $fn=32);
  }
  // Nut and washer
  nut_and_washer();
}

assembly();