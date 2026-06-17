// Dimension-calibrated (target: 0.01 x 0.01 x 0.01 mm)
scale([0.900000, 0.841170, 0.740741])
{
// Parameters
bbox_x = 0.01; //[0.005:0.02:0.0005]
bbox_y = 0.01; //[0.005:0.02:0.0005]
bbox_z = 0.01; //[0.005:0.02:0.0005]
max_r = 0.005; //[0.0025:0.01:0.0005]
head_h = 0.0042; //[0.0021:0.0084:0.0001]
head_r = 0.005; //[0.0025:0.01:0.0005]
shank_h = 0.0058; //[0.0029:0.0116:0.0001]
shank_r = 0.0018; //[0.0009:0.0036:0.0001]
neck_h = 0.0006; //[0.0003:0.0012:0.00005]
neck_r = 0.0022; //[0.0011:0.0044:0.0001]
flange_thk = 0.00045; //[0.0002:0.0009:0.00005]
flange_r = 0.0032; //[0.0016:0.0064:0.0001]
flange1_z = 0.002; //[0.001:0.004:0.0001]
flange2_z = 0.0036; //[0.0018:0.0072:0.0001]
overlap = 0.0002; //[0.00005:0.0005:0.00005]
micro_chamfer_h = 0.00025; //[0.0001:0.0005:0.00005]
micro_chamfer_r_delta = 0.00025; //[0.0001:0.0006:0.00005]
facet_sides = 10; //[6:24:1]

// Geometry
module head_domed_conical() {
  translate([0, 0, bbox_z/2 - head_h/2])
    rotate([0, 0, 0])
      cylinder(h = head_h, r1 = min(head_r, max_r), r2 = 0, center = true, $fn = facet_sides);
}

module head_to_shank_transition_neck() {
  translate([0, 0, bbox_z/2 - head_h - neck_h/2 + overlap])
    rotate([0, 0, 0])
      cylinder(h = neck_h, r = min(neck_r, max_r), center = true, $fn = facet_sides);
}

module shank_cylinder() {
  translate([0, 0, bbox_z/2 - head_h - neck_h - shank_h/2 + overlap])
    rotate([0, 0, 0])
      cylinder(h = shank_h, r = shank_r, center = true, $fn = facet_sides);
}

module retaining_flange_1() {
  translate([0, 0, bbox_z/2 - head_h - neck_h - flange1_z + overlap])
    rotate([0, 0, 0])
      cylinder(h = flange_thk, r = min(flange_r, max_r), center = true, $fn = facet_sides);
}

module retaining_flange_2() {
  translate([0, 0, bbox_z/2 - head_h - neck_h - flange2_z + overlap])
    rotate([0, 0, 0])
      cylinder(h = flange_thk, r = min(flange_r, max_r), center = true, $fn = facet_sides);
}

module micro_chamfer_head_top() {
  translate([0, 0, bbox_z/2 - micro_chamfer_h/2])
    rotate([180, 0, 0])
      cylinder(h = micro_chamfer_h, r1 = min(head_r, max_r), r2 = min(head_r, max_r) - micro_chamfer_r_delta, center = true, $fn = facet_sides);
}

module micro_chamfer_shank_tip() {
  translate([0, 0, bbox_z/2 - head_h - neck_h - shank_h + micro_chamfer_h/2 - overlap])
    rotate([0, 0, 0])
      cylinder(h = micro_chamfer_h, r1 = shank_r, r2 = shank_r - micro_chamfer_r_delta, center = true, $fn = facet_sides);
}

module extra_faceting_control() {
  translate([0, 0, bbox_z/2 - head_h - neck_h - micro_chamfer_h/2 + overlap])
    rotate([0, 0, 0])
      cylinder(h = micro_chamfer_h, r = shank_r, center = true, $fn = facet_sides);
}

// Final Union
union() {
  head_domed_conical();
  head_to_shank_transition_neck();
  shank_cylinder();
  retaining_flange_1();
  retaining_flange_2();
  micro_chamfer_head_top();
  micro_chamfer_shank_tip();
  extra_faceting_control();
}
}
