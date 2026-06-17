// Parameters
width_mm = 30; //[15:60:1]
depth_mm = 34; //[17:68:1]
height_mm = 30; //[15:60:1]
clearance_mm = 0.2; //[0:1:0.05]
nut_outer_diameter_mm = 22; //[11:44:0.5]
nut_length_mm = 18; //[9:36:0.5]
nut_flange_diameter_mm = 0; //[0:50:0.5]
nut_flange_thickness_mm = 0; //[0:10:0.25]
leadscrew_diameter_mm = 8; //[4:20:0.5]
edge_chamfer_mm = 0.5; //[0:3:0.1]
mount_hole_count = 4; //[0:8:1]
mount_hole_diameter_mm = 4.5; //[2:10:0.25]
mount_hole_spacing_x_mm = 20; //[10:40:0.5]
mount_hole_spacing_y_mm = 24; //[10:50:0.5]
anti_rotation_flat_depth_mm = 1.5; //[0:5:0.25]
anti_rotation_flat_width_mm = 18; //[8:40:0.5]
overlap_mm = 1; //[0.5:2:0.1]

// Leadscrew - complete geometry
module leadscrew() {
  color("Silver") {
    cylinder(r=leadscrew_diameter_mm/2, h=height_mm + 2*overlap_mm, center=true, $fn=64);
  }
}

// Main body block
module main_body_block() {
  color([0.85, 0.85, 0.8]) {
    cube([width_mm, depth_mm, height_mm], center=true);
  }
}

// Nut capture bore or pocket
module nut_capture_bore_or_pocket() {
  cylinder(r=(nut_outer_diameter_mm + 2*clearance_mm)/2, h=nut_length_mm + 2*overlap_mm, center=true, $fn=64);
}

// Nut flange pocket
module nut_flange_pocket() {
  if (nut_flange_diameter_mm > 0 && nut_flange_thickness_mm > 0) {
    cylinder(r=(nut_flange_diameter_mm + 2*clearance_mm)/2, h=nut_flange_thickness_mm + 2*overlap_mm, center=true, $fn=64);
  }
}

// Leadscrew bore
module leadscrew_bore() {
  cylinder(r=(leadscrew_diameter_mm + 2*clearance_mm)/2, h=height_mm + 2*overlap_mm, center=true, $fn=64);
}

// Anti-rotation flat cuts
module anti_rotation_flat_cut() {
  union() {
    translate([(nut_outer_diameter_mm + 2*clearance_mm)/2 - anti_rotation_flat_depth_mm, 0, 0])
      cube([2*anti_rotation_flat_depth_mm + 2*overlap_mm, anti_rotation_flat_width_mm, nut_length_mm + 2*overlap_mm], center=true);
    translate([-((nut_outer_diameter_mm + 2*clearance_mm)/2 - anti_rotation_flat_depth_mm), 0, 0])
      cube([2*anti_rotation_flat_depth_mm + 2*overlap_mm, anti_rotation_flat_width_mm, nut_length_mm + 2*overlap_mm], center=true);
  }
}

// Mounting holes
module mounting_holes() {
  if (mount_hole_count == 4) {
    union() {
      translate([mount_hole_spacing_x_mm/2, mount_hole_spacing_y_mm/2, 0])
        cylinder(r=mount_hole_diameter_mm/2, h=height_mm + 2*overlap_mm, center=true, $fn=32);
      translate([-mount_hole_spacing_x_mm/2, mount_hole_spacing_y_mm/2, 0])
        cylinder(r=mount_hole_diameter_mm/2, h=height_mm + 2*overlap_mm, center=true, $fn=32);
      translate([-mount_hole_spacing_x_mm/2, -mount_hole_spacing_y_mm/2, 0])
        cylinder(r=mount_hole_diameter_mm/2, h=height_mm + 2*overlap_mm, center=true, $fn=32);
      translate([mount_hole_spacing_x_mm/2, -mount_hole_spacing_y_mm/2, 0])
        cylinder(r=mount_hole_diameter_mm/2, h=height_mm + 2*overlap_mm, center=true, $fn=32);
    }
  }
}

// Lead-in chamfers
module lead_in_chamfers() {
  union() {
    translate([width_mm/2 - edge_chamfer_mm/2, depth_mm/2 - edge_chamfer_mm/2, 0])
      cube([edge_chamfer_mm, edge_chamfer_mm, height_mm + 2*overlap_mm], center=true);
    translate([-(width_mm/2 - edge_chamfer_mm/2), depth_mm/2 - edge_chamfer_mm/2, 0])
      cube([edge_chamfer_mm, edge_chamfer_mm, height_mm + 2*overlap_mm], center=true);
    translate([-(width_mm/2 - edge_chamfer_mm/2), -(depth_mm/2 - edge_chamfer_mm/2), 0])
      cube([edge_chamfer_mm, edge_chamfer_mm, height_mm + 2*overlap_mm], center=true);
    translate([width_mm/2 - edge_chamfer_mm/2, -(depth_mm/2 - edge_chamfer_mm/2), 0])
      cube([edge_chamfer_mm, edge_chamfer_mm, height_mm + 2*overlap_mm], center=true);
  }
}

// Assembly
module assembly() {
  difference() {
    main_body_block();
    union() {
      nut_capture_bore_or_pocket();
      if (nut_flange_diameter_mm > 0 && nut_flange_thickness_mm > 0) nut_flange_pocket();
      leadscrew_bore();
      anti_rotation_flat_cut();
      if (mount_hole_count == 4) mounting_holes();
      lead_in_chamfers();
    }
  }
  leadscrew();
}

assembly();