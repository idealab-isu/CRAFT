// Parameters
L = 36.0; //[18.0:72.0:0.5]
W = 19.0; //[9.5:38.0:0.5]
H = 21.0; //[10.5:42.0:0.5]
cutout_depth = 6.0; //[3.0:12.0:0.5]
cutout_height = 13.0; //[6.5:19.0:0.5]
cutout_length = 26.0; //[13.0:34.0:0.5]
web_thickness = 7.0; //[3.5:14.0:0.5]
end_margin = 5.0; //[2.5:10.0:0.5]
fillet_r = 2.0; //[0.5:4.0:0.25]
edge_break_r = 0.4; //[0.2:1.0:0.1]
chamfer_inset = 0.6; //[0.2:1.5:0.1]
overlap = 1.0; //[0.5:2.0:0.1]

// Main Prismatic Body
module main_prismatic_body() {
  cube([L, W, H], center=true);
}

// Side Cutouts
module side_cutout_left() {
  translate([0, -(W/2) + (cutout_depth + overlap)/2, 0])
    cube([cutout_length, cutout_depth + overlap, cutout_height], center=true);
}

module side_cutout_right() {
  translate([0, (W/2) - (cutout_depth + overlap)/2, 0])
    cube([cutout_length, cutout_depth + overlap, cutout_height], center=true);
}

// Central Web Remaining Solid
module central_web_remaining_solid() {
  cube([L, web_thickness, H], center=true);
}

// Fillet Kernel Sphere
module fillet_kernel_sphere() {
  sphere(r=fillet_r, center=true);
}

// Edge Break Kernel Sphere
module edge_break_kernel_sphere() {
  sphere(r=edge_break_r, center=true);
}

// Cutout Chamfer Tools
module cutout_left_chamfer_tool() {
  translate([0, -(W/2) + (cutout_depth + overlap)/2, 0])
    cube([cutout_length + 2*chamfer_inset, cutout_depth + overlap + chamfer_inset, cutout_height + 2*chamfer_inset], center=true);
}

module cutout_right_chamfer_tool() {
  translate([0, (W/2) - (cutout_depth + overlap)/2, 0])
    cube([cutout_length + 2*chamfer_inset, cutout_depth + overlap + chamfer_inset, cutout_height + 2*chamfer_inset], center=true);
}

// Operations
module op_cutouts_difference() {
  difference() {
    main_prismatic_body();
    side_cutout_left();
    side_cutout_right();
  }
}

module op_small_chamfers_on_cutout_edges() {
  difference() {
    op_cutouts_difference();
    cutout_left_chamfer_tool();
    cutout_right_chamfer_tool();
  }
}

module long_edge_fillets_rounding() {
  minkowski() {
    op_small_chamfers_on_cutout_edges();
    fillet_kernel_sphere();
  }
}

module cosmetic_edge_breaks() {
  minkowski() {
    long_edge_fillets_rounding();
    edge_break_kernel_sphere();
  }
}

module op_bounding_box_trim() {
  intersection() {
    cosmetic_edge_breaks();
    main_prismatic_body();
  }
}

module op_final_union_all_parts() {
  union() {
    op_bounding_box_trim();
    central_web_remaining_solid();
  }
}

// Final Output
op_final_union_all_parts();