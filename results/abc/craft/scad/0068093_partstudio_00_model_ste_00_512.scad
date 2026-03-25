// Dimension-calibrated (target: 0.01 x 0.01 x 0.01 mm)
scale([1.036598, 0.876369, 0.744066])
{
// Parameters
bbox_x = 0.01; //[0.005:0.02:0.0001]
bbox_y = 0.01; //[0.005:0.02:0.0001]
bbox_z = 0.01; //[0.005:0.02:0.0001]
head_h = 0.0042; //[0.0021:0.0084:0.0001]
head_r_max = 0.0048; //[0.0024:0.0096:0.0001]
head_r_base = 0.0032; //[0.0016:0.0064:0.0001]
neck_h = 0.0006; //[0.0003:0.0012:0.00005]
neck_r = 0.0026; //[0.0013:0.0052:0.0001]
shank_h = 0.0052; //[0.0026:0.0104:0.0001]
shank_r = 0.0022; //[0.0011:0.0044:0.0001]
flange_r = 0.003; //[0.0015:0.006:0.0001]
flange_t = 0.00035; //[0.00015:0.0007:0.00001]
flange1_z = 0.0016; //[0.0008:0.0032:0.0001]
flange2_z = 0.0034; //[0.0017:0.0068:0.0001]
hole_r = 0.0007; //[0.00035:0.0014:0.00005]
hole_depth = 0.0065; //[0.00325:0.013:0.0001]
overlap = 0.0008; //[0.0005:0.002:0.0001]
facet_segments = 12; //[6:48:1]
micro_chamfer = 0.00025; //[0.0001:0.0005:0.00001]
tip_round_r = 0.00035; //[0.00015:0.0007:0.00001]

// Base Shapes
module faceted_tessellation_low_poly() {
  rotate_extrude($fn=facet_segments) {
    polygon(points=[
      [0, 0],
      [shank_r - micro_chamfer, 0],
      [shank_r, micro_chamfer],
      [shank_r, shank_h - micro_chamfer],
      [shank_r + (flange_r - shank_r) * 0.6, shank_h - flange2_z - flange_t/2],
      [flange_r, shank_h - flange2_z],
      [shank_r + (flange_r - shank_r) * 0.6, shank_h - flange2_z + flange_t/2],
      [shank_r, shank_h - flange2_z + flange_t/2 + micro_chamfer],
      [shank_r, shank_h - flange1_z - flange_t/2 - micro_chamfer],
      [shank_r + (flange_r - shank_r) * 0.6, shank_h - flange1_z - flange_t/2],
      [flange_r, shank_h - flange1_z],
      [shank_r + (flange_r - shank_r) * 0.6, shank_h - flange1_z + flange_t/2],
      [shank_r, shank_h - flange1_z + flange_t/2 + micro_chamfer],
      [shank_r, shank_h - micro_chamfer],
      [neck_r, shank_h],
      [head_r_base, shank_h + neck_h],
      [head_r_max, shank_h + neck_h + head_h * 0.55],
      [head_r_max - micro_chamfer, shank_h + neck_h + head_h - micro_chamfer],
      [0, shank_h + neck_h + head_h],
      [0, 0]
    ]);
  }
}

module shank_cylinder() {
  translate([0, 0, 0])
    cylinder(h=shank_h, r=shank_r, center=false);
}

module head_to_shank_transition_neck() {
  translate([0, 0, shank_h - overlap])
    cylinder(h=neck_h + overlap, r=neck_r, center=false);
}

module head_domed_conical() {
  translate([0, 0, shank_h + neck_h])
    cylinder(h=head_h, r1=head_r_max, r2=0, center=false);
}

module retaining_flange_1() {
  translate([0, 0, shank_h - flange1_z])
    cylinder(h=flange_t, r=flange_r, center=true);
}

module retaining_flange_2() {
  translate([0, 0, shank_h - flange2_z])
    cylinder(h=flange_t, r=flange_r, center=true);
}

module tiny_tip_rounding() {
  translate([0, 0, tip_round_r - overlap])
    sphere(r=tip_round_r);
}

module edge_chamfers_micro() {
  translate([0, 0, 0])
    cylinder(h=micro_chamfer + overlap, r1=shank_r, r2=0, center=false);
}

module internal_axial_hole() {
  translate([0, 0, 0])
    cylinder(h=hole_depth, r=hole_r, center=false);
}

// Operations
module union_main_parts() {
  union() {
    shank_cylinder();
    head_to_shank_transition_neck();
    head_domed_conical();
    retaining_flange_1();
    retaining_flange_2();
    tiny_tip_rounding();
    edge_chamfers_micro();
  }
}

module union_with_faceted_shell() {
  union() {
    union_main_parts();
    faceted_tessellation_low_poly();
  }
}

module difference_internal_relief() {
  difference() {
    union_with_faceted_shell();
    internal_axial_hole();
  }
}

// Final Output
difference_internal_relief();
}
