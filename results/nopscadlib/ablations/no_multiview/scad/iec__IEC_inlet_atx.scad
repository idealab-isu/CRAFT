// Parameters
cutout_width_mm = 40; //[20:80:0.1]
cutout_height_mm = 27; //[13.5:54:0.1]
panel_thickness_mm = 1.5; //[0.8:3:0.1]
flange_thickness_mm = 2; //[1:4:0.1]
bezel_thickness_mm = 2; //[1:4:0.1]
corner_radius_mm = 1; //[0:3:0.1]
mounting_holes_enabled = 1; //[0:1:1]
mounting_hole_diameter_mm = 3.2; //[2:6.5:0.1]
mounting_hole_pitch_mm = 36; //[18:72:0.1]
body_depth_mm = 30; //[15:60:0.5]
clearance_mm = 0.2; //[0:1:0.05]
overlap_mm = 1; //[0.5:2:0.1]
panel_margin_mm = 15; //[5:40:1]
flange_margin_mm = 6; //[3:15:0.5]
bezel_margin_mm = 3; //[1:10:0.5]
body_wall_mm = 2; //[1:4:0.1]
terminal_clearance_depth_mm = 18; //[10:35:0.5]
terminal_clearance_width_mm = 28; //[15:45:0.5]
terminal_clearance_height_mm = 22; //[12:40:0.5]

// IEC Inlet - complete geometry
module iec() {
  color("Black") {
    // Front Flange
    translate([0, 0, panel_thickness_mm/2 + flange_thickness_mm/2 - overlap_mm])
      cube([cutout_width_mm + 2*flange_margin_mm, cutout_height_mm + 2*flange_margin_mm, flange_thickness_mm], center=true);
    
    // Front Bezel
    translate([0, 0, panel_thickness_mm/2 + flange_thickness_mm + bezel_thickness_mm/2 - overlap_mm])
      cube([cutout_width_mm + 2*bezel_margin_mm, cutout_height_mm + 2*bezel_margin_mm, bezel_thickness_mm], center=true);
    
    // IEC Inlet Body
    translate([0, 0, -panel_thickness_mm/2 - body_depth_mm/2 + overlap_mm])
      cube([cutout_width_mm + 2*body_wall_mm, cutout_height_mm + 2*body_wall_mm, body_depth_mm], center=true);
  }
}

// Mod - complete geometry
module mod() {
  color("Silver") {
    // Rear Body Depth Clearance
    translate([0, 0, -panel_thickness_mm/2 - (body_depth_mm + clearance_mm)/2 + overlap_mm])
      cube([cutout_width_mm + 2*(body_wall_mm + clearance_mm), cutout_height_mm + 2*(body_wall_mm + clearance_mm), body_depth_mm + clearance_mm], center=true);
    
    // Terminal Spade Clearance
    translate([0, 0, -panel_thickness_mm/2 - body_depth_mm + terminal_clearance_depth_mm/2 + overlap_mm])
      cube([terminal_clearance_width_mm, terminal_clearance_height_mm, terminal_clearance_depth_mm], center=true);
  }
}

// Panel with cutout and mounting holes
module panel_with_cutout() {
  difference() {
    // Panel Slab
    color([0.85, 0.85, 0.8]) // Off-white for 3D printed PLA
    cube([cutout_width_mm + 2*panel_margin_mm, cutout_height_mm + 2*panel_margin_mm, panel_thickness_mm], center=true);
    
    // Panel Cutout
    cube([cutout_width_mm + 2*clearance_mm, cutout_height_mm + 2*clearance_mm, panel_thickness_mm + 2*overlap_mm], center=true);
    
    // Mounting Holes
    if (mounting_holes_enabled) {
      translate([-mounting_hole_pitch_mm/2, 0, 0])
        cylinder(h=panel_thickness_mm + 2*overlap_mm, r=mounting_hole_diameter_mm/2, center=true);
      translate([mounting_hole_pitch_mm/2, 0, 0])
        cylinder(h=panel_thickness_mm + 2*overlap_mm, r=mounting_hole_diameter_mm/2, center=true);
    }
  }
}

// Assembly
module assembly() {
  panel_with_cutout();
  iec();
  mod();
}

assembly();