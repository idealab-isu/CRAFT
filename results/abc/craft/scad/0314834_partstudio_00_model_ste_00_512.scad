// Parameters
L = 0.1; //[0.05:0.2:0.001]
W = 0.08; //[0.04:0.16:0.001]
T = 0.03; //[0.015:0.06:0.001]
frame_wall = 0.012; //[0.006:0.024:0.001]
opening_L = 0.07; //[0.035:0.09:0.001]
opening_W = 0.05; //[0.025:0.07:0.001]
end_block_L = 0.02; //[0.01:0.04:0.001]
end_block_extra_T = 0.01; //[0.005:0.02:0.001]
tab_L = 0.018; //[0.009:0.036:0.001]
tab_W = 0.02; //[0.01:0.04:0.001]
tab_T = 0.018; //[0.009:0.03:0.001]
tab_angle_deg = 20; //[0:45:1]
step_drop = 0.006; //[0.003:0.012:0.001]
gap_H = 0.008; //[0.004:0.016:0.001]
gap_L = 0.01; //[0.005:0.02:0.001]
overlap = 0.001; //[0.0005:0.002:0.0005]
chamfer = 0.001; //[0.0005:0.003:0.0005]
fillet_r = 0.0008; //[0.0004:0.002:0.0002]

// Base Shapes
module outer_frame_plate() {
  cube([L, W, T], center=true);
}

module central_through_opening() {
  cube([opening_L, opening_W, T + 2*overlap], center=true);
}

module end_block_thick_region() {
  translate([L/2 - end_block_L/2, 0, T/2 + end_block_extra_T/2 - overlap])
    cube([end_block_L, W, end_block_extra_T], center=true);
}

module cantilever_hook_tab_raw() {
  translate([opening_L/2 - tab_L/2 + overlap, 0, T/2 - tab_T/2 + overlap])
    cube([tab_L, tab_W, tab_T], center=true);
}

module hook_step_raw() {
  translate([opening_L/2 - (tab_L*0.35)/2 + overlap, 0, T/2 - tab_T/2 - step_drop/2 + overlap])
    cube([tab_L*0.35, tab_W, step_drop], center=true);
}

module undercut_gap_raw() {
  translate([opening_L/2 - gap_L/2 + overlap, 0, T/2 - tab_T/2 + gap_H/2])
    cube([gap_L, tab_W*0.8, gap_H], center=true);
}

module chamfer_wedge_xp() {
  translate([L/2 - chamfer/2, 0, end_block_extra_T/2])
    rotate([0, 45, 0])
    cube([chamfer, W + 2*overlap, T + end_block_extra_T + 2*overlap], center=true);
}

module chamfer_wedge_xn() {
  translate([-L/2 + chamfer/2, 0, 0])
    rotate([0, -45, 0])
    cube([chamfer, W + 2*overlap, T + 2*overlap], center=true);
}

module chamfer_wedge_yp() {
  translate([0, W/2 - chamfer/2, end_block_extra_T/2])
    rotate([45, 0, 0])
    cube([L + 2*overlap, chamfer, T + end_block_extra_T + 2*overlap], center=true);
}

module chamfer_wedge_yn() {
  translate([0, -W/2 + chamfer/2, end_block_extra_T/2])
    rotate([-45, 0, 0])
    cube([L + 2*overlap, chamfer, T + end_block_extra_T + 2*overlap], center=true);
}

module small_fillet_rounding_sphere() {
  sphere(r=fillet_r, center=true);
}

// Operations
module frame_minus_opening() {
  difference() {
    outer_frame_plate();
    central_through_opening();
  }
}

module frame_with_end_block() {
  union() {
    frame_minus_opening();
    end_block_thick_region();
  }
}

module hook_tab_with_step() {
  union() {
    cantilever_hook_tab_raw();
    hook_step_raw();
  }
}

module hook_tab_angled() {
  rotate([0, -tab_angle_deg, 0])
    hook_tab_with_step();
}

module frame_with_hook_tab() {
  union() {
    frame_with_end_block();
    hook_tab_angled();
  }
}

module frame_hook_with_undercut_gap() {
  difference() {
    frame_with_hook_tab();
    undercut_gap_raw();
  }
}

module edge_chamfers() {
  difference() {
    frame_hook_with_undercut_gap();
    chamfer_wedge_xp();
    chamfer_wedge_xn();
    chamfer_wedge_yp();
    chamfer_wedge_yn();
  }
}

module small_fillet_rounding() {
  minkowski() {
    edge_chamfers();
    small_fillet_rounding_sphere();
  }
}

// Final Output
small_fillet_rounding();