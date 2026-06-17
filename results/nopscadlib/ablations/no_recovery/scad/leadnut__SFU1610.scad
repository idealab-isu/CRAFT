// Parameters
block_width_mm = 16; //[8:32:0.5]
block_height_mm = 28; //[14:56:0.5]
block_length_mm = 42.5; //[21.25:85:0.5]
eps_mm = 0.8; //[0.2:2:0.1]
edge_chamfer_mm = 1.2; //[0.5:3:0.1]
leadscrew_diameter_mm = 8; //[4:16:0.5]
leadscrew_length_mm = 70; //[42.5:140:1]
nut_outer_diameter_or_profile_mm = 14; //[8:24:0.5]
nut_length_mm = 18; //[10:30:0.5]
nut_pocket_clearance_mm = 0.4; //[0.1:1.2:0.1]
retention_screw_diameter_mm = 3; //[2:6:0.5]
retention_screw_offset_z_mm = 6; //[3:12:0.5]
mounting_hole_diameter_mm = 4; //[2.5:8:0.5]
mounting_hole_spacing_y_mm = 26; //[14:38:0.5]
mounting_hole_spacing_x_mm = 10; //[6:14:0.5]
access_slot_width_mm = 10; //[6:14:0.5]
access_slot_height_mm = 12; //[6:20:0.5]
access_slot_depth_mm = 10; //[5:20:0.5]

// Leadscrew - complete geometry
module leadscrew() {
  color("Silver") {
    cylinder(r=leadscrew_diameter_mm/2, h=leadscrew_length_mm, center=true, $fn=32);
  }
}

// Main housing with internal features
module housing_with_internal_features() {
  difference() {
    // Main body block
    cube([block_width_mm, block_length_mm, block_height_mm], center=true);
    
    // Leadscrew nut cavity or bore
    rotate([90, 0, 0])
      translate([0, 0, 0])
      cylinder(r=(nut_outer_diameter_or_profile_mm/2) + nut_pocket_clearance_mm, 
               h=nut_length_mm + 2*eps_mm, center=true, $fn=32);
    
    // Leadscrew bore
    rotate([90, 0, 0])
      translate([0, 0, 0])
      cylinder(r=(leadscrew_diameter_mm/2) + nut_pocket_clearance_mm, 
               h=block_length_mm + 2*eps_mm, center=true, $fn=32);
    
    // Nut retention features holes
    rotate([0, 90, 0])
      translate([0, 0, retention_screw_offset_z_mm])
      cylinder(r=retention_screw_diameter_mm/2, 
               h=block_width_mm + 2*eps_mm, center=true, $fn=32);
    rotate([0, 90, 0])
      translate([0, 0, -retention_screw_offset_z_mm])
      cylinder(r=retention_screw_diameter_mm/2, 
               h=block_width_mm + 2*eps_mm, center=true, $fn=32);
    
    // Mounting holes
    for (x = [-1, 1], y = [-1, 1]) {
      translate([x * mounting_hole_spacing_x_mm/2, y * mounting_hole_spacing_y_mm/2, 0])
        cylinder(r=mounting_hole_diameter_mm/2, 
                 h=block_height_mm + 2*eps_mm, center=true, $fn=32);
    }
    
    // Access clearance cutouts
    translate([-(block_width_mm/2) + (access_slot_depth_mm/2) - eps_mm, 0, 0])
      cube([access_slot_depth_mm + 2*eps_mm, nut_length_mm + 2*eps_mm, access_slot_height_mm], center=true);
    translate([(block_width_mm/2) - (access_slot_depth_mm/2) + eps_mm, 0, 0])
      cube([access_slot_depth_mm + 2*eps_mm, nut_length_mm + 2*eps_mm, access_slot_height_mm], center=true);
    
    // Chamfers or fillets
    for (x = [-1, 1], y = [-1, 1]) {
      rotate([0, 0, 45])
        translate([x * (block_width_mm/2 - edge_chamfer_mm/2), y * (block_length_mm/2 - edge_chamfer_mm/2), 0])
        cube([edge_chamfer_mm, edge_chamfer_mm, block_height_mm + 2*eps_mm], center=true);
    }
  }
}

// Assembly
module assembly() {
  union() {
    housing_with_internal_features();
    translate([0, 0, 0]) leadscrew();
  }
}

assembly();