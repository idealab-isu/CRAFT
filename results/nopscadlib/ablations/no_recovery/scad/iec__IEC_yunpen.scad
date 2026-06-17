// Parameters
overall_width = 40; //[20:80:1]
overall_height = 29; //[15:58:1]
flange_thickness = 2.5; //[1.2:5:0.1]
bezel_thickness = 2; //[1:4:0.1]
corner_radius = 2.5; //[1:5:0.1]
body_width = 28.5; //[14.25:57:0.1]
body_height = 20.5; //[10.25:41:0.1]
body_depth = 22; //[11:44:0.5]
filter_can_width = 32; //[16:64:0.5]
filter_can_height = 24; //[12:48:0.5]
filter_can_depth = 18; //[9:36:0.5]
panel_cutout_width = 27.5; //[13.75:55:0.1]
panel_cutout_height = 19.5; //[9.75:39:0.1]
panel_cutout_depth = 6; //[3:12:0.5]
cutout_clearance = 0.5; //[0.2:1.5:0.1]
mount_hole_count = 2; //[2:2:1]
mount_hole_diameter = 3.2; //[2.4:6.4:0.1]
hole_clearance = 0.2; //[0.1:0.6:0.05]
mount_hole_pitch = 32; //[16:64:0.5]
screw_head_diameter = 6.5; //[4:13:0.1]
screw_head_height = 2.5; //[1:6:0.1]
insertion_orifice_width = 24.5; //[12.25:49:0.1]
insertion_orifice_height = 16.5; //[8.25:33:0.1]
insertion_orifice_depth = 8; //[4:16:0.5]
terminal_spade_zone_width = 26; //[13:52:0.5]
terminal_spade_zone_height = 18; //[9:36:0.5]
terminal_spade_zone_depth = 12; //[6:24:0.5]
overlap = 1; //[0.5:2:0.1]
include_cutout = 1; //[0:1:1]
include_keepout_volumes = 1; //[0:1:1]

// IEC Module - Detailed Geometry
module iec() {
  color("Black") {
    // Front Flange Bezel
    translate([0, 0, (flange_thickness + bezel_thickness) / 2])
      cube([overall_width, overall_height, flange_thickness + bezel_thickness], center=true);
    
    // Main Connector Body
    translate([0, 0, -(body_depth / 2) + bezel_thickness - overlap])
      cube([body_width, body_height, body_depth], center=true);
  }
}

// Mod Module - Detailed Geometry
module mod() {
  color("DimGray") {
    // Rear Filter Can Volume
    translate([0, 0, -body_depth - filter_can_depth / 2 + bezel_thickness + overlap])
      cube([filter_can_width, filter_can_height, filter_can_depth], center=true);
    
    // Terminal Spade Clearance Zone
    translate([0, 0, -body_depth - terminal_spade_zone_depth / 2 + bezel_thickness + overlap])
      cube([terminal_spade_zone_width, terminal_spade_zone_height, terminal_spade_zone_depth], center=true);
  }
}

// Assembly
module assembly() {
  union() {
    iec();
    mod();
    
    // Panel Cutout Profile
    if (include_cutout) {
      translate([0, 0, panel_cutout_depth / 2 - overlap])
        cube([panel_cutout_width + 2 * cutout_clearance, panel_cutout_height + 2 * cutout_clearance, panel_cutout_depth], center=true);
    }
    
    // Insertion Orifice Profile
    translate([0, 0, insertion_orifice_depth / 2 - overlap])
      cube([insertion_orifice_width, insertion_orifice_height, insertion_orifice_depth], center=true);
  }
  
  // Mounting Screw Holes and Screw Head Clearance
  difference() {
    // Main Solids
    union() {
      iec();
      mod();
    }
    
    // Mounting Screw Holes
    for (i = [-1, 1]) {
      translate([i * mount_hole_pitch / 2, 0, (flange_thickness + bezel_thickness) / 2])
        rotate([90, 0, 0])
        cylinder(r=(mount_hole_diameter + hole_clearance) / 2, h=flange_thickness + bezel_thickness + panel_cutout_depth + 2 * overlap, center=true);
      
      // Screw Head Clearance
      translate([i * mount_hole_pitch / 2, 0, flange_thickness + screw_head_height / 2 - overlap])
        rotate([90, 0, 0])
        cylinder(r=screw_head_diameter / 2, h=screw_head_height, center=true);
    }
  }
}

assembly();