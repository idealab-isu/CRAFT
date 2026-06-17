// Parameters
overall_width_mm = 120; //[60:240:1]
overall_depth_mm = 88; //[44:176:1]
overall_height_mm = 120; //[60:240:1]
foot_thickness_mm = 3; //[1.5:6:0.5]
foot_corner_radius_mm = 2; //[0:6:0.5]
mount_hole_count = 4; //[2:8:1]
mount_hole_diameter_mm = 5; //[2:10:0.5]
mount_hole_edge_margin_mm = 10; //[5:25:1]
lamination_height_mm = 80; //[40:160:1]
lamination_width_mm = 110; //[55:220:1]
lamination_depth_mm = 78; //[39:156:1]
bobbin_width_mm = 90; //[45:180:1]
bobbin_depth_mm = 88; //[44:176:1]
bobbin_height_mm = 40; //[20:80:1]
bobbin_corner_radius_mm = 2; //[0:6:0.5]
terminal_height_mm = 0; //[0:40:1]
foot_width_mm = 120; //[60:240:1]
foot_depth_mm = 88; //[44:176:1]
connection_overlap_mm = 1; //[0.5:2:0.5]
hole_cut_extra_mm = 2; //[1:6:1]
terminal_width_mm = 60; //[30:120:1]
terminal_depth_mm = 30; //[15:80:1]

// Base shapes
module base_foot_blank() {
  color("Silver") {
    translate([0, 0, foot_thickness_mm / 2])
      cube([foot_width_mm, foot_depth_mm, foot_thickness_mm], center=true);
  }
}

module mount_hole_cyl(x, y) {
  translate([x, y, foot_thickness_mm / 2])
    cylinder(r=mount_hole_diameter_mm / 2, h=foot_thickness_mm + hole_cut_extra_mm, center=true);
}

module laminated_core_block() {
  color("DimGray") {
    translate([0, 0, foot_thickness_mm + lamination_height_mm / 2 - connection_overlap_mm])
      cube([lamination_width_mm, lamination_depth_mm, lamination_height_mm], center=true);
  }
}

module bobbin_coil_body() {
  color("Black") {
    translate([0, 0, foot_thickness_mm + lamination_height_mm / 2 + bobbin_height_mm / 2 - connection_overlap_mm])
      cube([bobbin_width_mm, bobbin_depth_mm, bobbin_height_mm], center=true);
  }
}

module terminal_block_volume() {
  color("Copper") {
    translate([0, 0, foot_thickness_mm + lamination_height_mm + terminal_height_mm / 2 - connection_overlap_mm])
      cube([terminal_width_mm, terminal_depth_mm, terminal_height_mm], center=true);
  }
}

// Operations
module mounting_holes() {
  union() {
    mount_hole_cyl(foot_width_mm / 2 - mount_hole_edge_margin_mm, foot_depth_mm / 2 - mount_hole_edge_margin_mm);
    mount_hole_cyl(-(foot_width_mm / 2 - mount_hole_edge_margin_mm), foot_depth_mm / 2 - mount_hole_edge_margin_mm);
    mount_hole_cyl(foot_width_mm / 2 - mount_hole_edge_margin_mm, -(foot_depth_mm / 2 - mount_hole_edge_margin_mm));
    mount_hole_cyl(-(foot_width_mm / 2 - mount_hole_edge_margin_mm), -(foot_depth_mm / 2 - mount_hole_edge_margin_mm));
  }
}

module base_foot() {
  difference() {
    base_foot_blank();
    mounting_holes();
  }
}

module transformer_no_terminals() {
  union() {
    base_foot();
    laminated_core_block();
    bobbin_coil_body();
  }
}

module transformer() {
  union() {
    transformer_no_terminals();
    terminal_block_volume();
  }
}

// Assembly
module assembly() {
  transformer();
}

assembly();