// Parameters
L = 0.14; //[0.07:0.28:0.001]
W = 0.03; //[0.015:0.06:0.001]
H = 0.02; //[0.01:0.04:0.001]
cut_L = 0.09; //[0.045:0.18:0.001]
cut_W = 0.018; //[0.009:0.036:0.001]
cut_H = 0.014; //[0.007:0.028:0.001]
web_t = 0.003; //[0.0015:0.006:0.0005]
end_len = 0.025; //[0.0125:0.05:0.001]
hole_d = 0.006; //[0.003:0.012:0.0005]
hole_offset_L = 0.01; //[0.005:0.02:0.001]
hole_offset_W = 0.006; //[0.003:0.012:0.001]
cs_d = 0.01; //[0.005:0.02:0.0005]
cs_depth = 0.004; //[0.002:0.008:0.0005]
eps = 0.001; //[0.0005:0.002:0.0005]
chamfer = 0.001; //[0.0005:0.002:0.0005]
fillet_r = 0.001; //[0.0005:0.002:0.0005]

// Base Shapes
module outer_body() {
  cube([L, W, H], center=true);
}

module central_rectangular_cutout() {
  cube([cut_L, cut_W, cut_H + 2*eps], center=true);
}

module end_block_hole_left() {
  translate([-L/2 + hole_offset_L, W/2 - hole_offset_W, 0])
    cylinder(h=H + 2*eps, r=hole_d/2, center=true);
}

module end_block_hole_right() {
  translate([L/2 - hole_offset_L, W/2 - hole_offset_W, 0])
    cylinder(h=H + 2*eps, r=hole_d/2, center=true);
}

module hole_countersink_or_counterbore_left() {
  translate([-L/2 + hole_offset_L, W/2 - hole_offset_W, H/2 - (cs_depth + eps)/2])
    cylinder(h=cs_depth + eps, r=cs_d/2, center=true);
}

module hole_countersink_or_counterbore_right() {
  translate([L/2 - hole_offset_L, W/2 - hole_offset_W, H/2 - (cs_depth + eps)/2])
    cylinder(h=cs_depth + eps, r=cs_d/2, center=true);
}

module edge_chamfer_cut(position) {
  translate(position)
    rotate([0, 0, 45])
      cube([chamfer, chamfer, H + 2*eps], center=true);
}

module fillet_sphere() {
  sphere(r=fillet_r, center=true);
}

// Operations
module edge_chamfers() {
  union() {
    edge_chamfer_cut([-L/2 + chamfer/2, W/2 - chamfer/2, 0]);
    edge_chamfer_cut([L/2 - chamfer/2, W/2 - chamfer/2, 0]);
    edge_chamfer_cut([-L/2 + chamfer/2, -W/2 + chamfer/2, 0]);
    edge_chamfer_cut([L/2 - chamfer/2, -W/2 + chamfer/2, 0]);
  }
}

module u_bracket_no_holes() {
  difference() {
    outer_body();
    central_rectangular_cutout();
    edge_chamfers();
  }
}

module u_bracket_with_holes() {
  difference() {
    u_bracket_no_holes();
    end_block_hole_left();
    end_block_hole_right();
    hole_countersink_or_counterbore_left();
    hole_countersink_or_counterbore_right();
  }
}

module edge_fillets() {
  minkowski() {
    u_bracket_with_holes();
    fillet_sphere();
  }
}

// Final Output
edge_fillets();