// Parameters
bbox_x = 0.15; //[0.075:0.3:0.001]
bbox_y = 0.13; //[0.065:0.26:0.001]
bbox_z = 0.08; //[0.04:0.16:0.001]
curve_outer_r = 0.055; //[0.0275:0.11:0.001]
curve_inner_r = 0.03; //[0.015:0.06:0.001]
curve_thickness_z = 0.06; //[0.03:0.12:0.001]
large_block_x = 0.05; //[0.025:0.1:0.001]
large_block_y = 0.06; //[0.03:0.12:0.001]
large_block_z = 0.08; //[0.04:0.16:0.001]
tongue_x = 0.045; //[0.0225:0.09:0.001]
tongue_y = 0.03; //[0.015:0.06:0.001]
tongue_z = 0.04; //[0.02:0.08:0.001]
endcap_len = 0.03; //[0.015:0.06:0.001]
endcap_w = 0.028; //[0.014:0.056:0.001]
endcap_z = 0.04; //[0.02:0.08:0.001]
lug_x = 0.012; //[0.006:0.024:0.001]
lug_y = 0.01; //[0.005:0.02:0.001]
lug_z = 0.01; //[0.005:0.02:0.001]
lug_spacing_y = 0.014; //[0.007:0.028:0.001]
lug_offset_from_tip_x = 0.01; //[0.005:0.02:0.001]
overlap = 0.001; //[0.0005:0.002:0.0001]
fillet_r = 0.002; //[0.001:0.004:0.0005]
detail_mark_r = 0.0015; //[0.0008:0.003:0.0001]
detail_mark_h = 0.001; //[0.0005:0.002:0.0001]

// Base Shapes
module curved_main_body_outer_cyl() {
  translate([0, 0, 0])
    cylinder(r=curve_outer_r, h=curve_thickness_z, center=true);
}

module curved_main_body_inner_cyl() {
  translate([0, 0, 0])
    cylinder(r=curve_inner_r, h=curve_thickness_z + 2*overlap, center=true);
}

module curved_main_body_quadrant_keep() {
  translate([curve_outer_r/2, curve_outer_r/2, 0])
    cube([2*curve_outer_r + 2*overlap, 2*curve_outer_r + 2*overlap, curve_thickness_z + 2*overlap], center=true);
}

module large_end_block_interface() {
  translate([-(large_block_x/2) + overlap, curve_outer_r/2, 0])
    cube([large_block_x, large_block_y, large_block_z], center=true);
}

module small_end_tongue_interface() {
  translate([curve_outer_r - overlap + tongue_x/2, curve_outer_r/2, 0])
    cube([tongue_x, tongue_y, tongue_z], center=true);
}

module obround_end_cap_box() {
  translate([curve_outer_r - overlap + tongue_x - endcap_len/2, curve_outer_r/2, 0])
    cube([endcap_len - endcap_w, endcap_w, endcap_z], center=true);
}

module obround_end_cap_cyl_left() {
  translate([curve_outer_r - overlap + tongue_x - endcap_len/2 - (endcap_len - endcap_w)/2, curve_outer_r/2, 0])
    cylinder(r=endcap_w/2, h=endcap_z, center=true);
}

module obround_end_cap_cyl_right() {
  translate([curve_outer_r - overlap + tongue_x - endcap_len/2 + (endcap_len - endcap_w)/2, curve_outer_r/2, 0])
    cylinder(r=endcap_w/2, h=endcap_z, center=true);
}

module top_lug_1() {
  translate([curve_outer_r - overlap + tongue_x - lug_offset_from_tip_x - lug_x/2, curve_outer_r/2 + lug_spacing_y/2, tongue_z/2 + lug_z/2 - overlap])
    cube([lug_x, lug_y, lug_z], center=true);
}

module top_lug_2() {
  translate([curve_outer_r - overlap + tongue_x - lug_offset_from_tip_x - lug_x/2, curve_outer_r/2 - lug_spacing_y/2, tongue_z/2 + lug_z/2 - overlap])
    cube([lug_x, lug_y, lug_z], center=true);
}

module surface_detail_marks() {
  translate([curve_outer_r - overlap + tongue_x/2, curve_outer_r/2, tongue_z/2 + detail_mark_h/2 - overlap])
    cylinder(r=detail_mark_r, h=detail_mark_h, center=true);
}

module edge_fillets_kernel_sphere() {
  translate([0, 0, 0])
    sphere(r=fillet_r, center=true);
}

// Operations
module curved_main_body_ring() {
  difference() {
    curved_main_body_outer_cyl();
    curved_main_body_inner_cyl();
  }
}

module curved_main_body() {
  intersection() {
    curved_main_body_ring();
    curved_main_body_quadrant_keep();
  }
}

module obround_end_cap_feature() {
  union() {
    obround_end_cap_box();
    obround_end_cap_cyl_left();
    obround_end_cap_cyl_right();
  }
}

module main_union_raw() {
  union() {
    curved_main_body();
    large_end_block_interface();
    small_end_tongue_interface();
    obround_end_cap_feature();
    top_lug_1();
    top_lug_2();
    surface_detail_marks();
  }
}

// Final Output
minkowski() {
  main_union_raw();
  edge_fillets_kernel_sphere();
}