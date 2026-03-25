// Dimension-calibrated (target: 0.01 x 0.04 x 0.01 mm)
scale([1.216318, 0.958757, 1.435801])
{
// Parameters
L = 0.04; //[0.02:0.08:0.001]
W = 0.01; //[0.005:0.02:0.0005]
H = 0.01; //[0.005:0.02:0.0005]
outer_r_max = 0.005; //[0.0025:0.01:0.0001]
outer_r_min = 0.0046; //[0.0023:0.0092:0.0001]
facet_sides = 10; //[6:24:1]
hex_af = 0.0022; //[0.0011:0.0044:0.00005]
bore_clearance = 0.00005; //[0.0:0.0002:0.00001]
boss_L = 0.006; //[0.003:0.012:0.0005]
boss_r = 0.0036; //[0.0018:0.0072:0.0001]
round_end_L = 0.003; //[0.0015:0.006:0.0005]
round_end_r = 0.0048; //[0.0024:0.0096:0.0001]
overlap = 0.0008; //[0.0002:0.002:0.0001]
flat_depth = 0.00035; //[0.0001:0.001:0.00005]
micro_facet_depth = 0.00012; //[0.00005:0.0003:0.00001]
chamfer_L = 0.0012; //[0.0005:0.003:0.0001]

// Base Shapes
module sleeve_main_body() {
  translate([0, (boss_L - round_end_L) / 2, 0])
    cylinder(r=outer_r_max, h=L - boss_L - round_end_L, center=true);
}

module outer_taper() {
  translate([0, (boss_L - round_end_L) / 2, 0])
    rotate([90, 0, 0])
      cylinder(r1=outer_r_max, r2=outer_r_min, h=L - boss_L - round_end_L, center=true);
}

module stepped_boss_end() {
  translate([0, -L/2 + boss_L/2, 0])
    rotate([90, 0, 0])
      cylinder(r=boss_r, h=boss_L + overlap, center=true);
}

module flush_rounded_end() {
  translate([0, L/2 - round_end_L + overlap, 0])
    sphere(r=round_end_r, center=true);
}

module edge_chamfers_fillets() {
  translate([0, -L/2 + boss_L + (chamfer_L/2), 0])
    rotate([90, 0, 0])
      cylinder(r1=outer_r_max, r2=outer_r_max - (outer_r_max - outer_r_min) * 0.6, h=chamfer_L + overlap, center=true);
}

module irregular_flat_variation() {
  translate([0, 0, outer_r_max - flat_depth])
    cube([outer_r_max * 2, L, flat_depth * 2], center=true);
}

module surface_micro_faceting_detail() {
  translate([0, 0, -outer_r_max + micro_facet_depth])
    cube([outer_r_max * 2, L, micro_facet_depth * 2], center=true);
}

module hex_through_bore() {
  translate([0, 0, 0])
    rotate([90, 0, 0])
      linear_extrude(height=L + overlap * 2, center=true)
        polygon(points=[
          [(hex_af/2 + bore_clearance), 0],
          [(hex_af/4 + bore_clearance/2), (hex_af*0.4330127019 + bore_clearance)],
          [(-hex_af/4 - bore_clearance/2), (hex_af*0.4330127019 + bore_clearance)],
          [(-hex_af/2 - bore_clearance), 0],
          [(-hex_af/4 - bore_clearance/2), (-hex_af*0.4330127019 - bore_clearance)],
          [(hex_af/4 + bore_clearance/2), (-hex_af*0.4330127019 - bore_clearance)]
        ]);
}

// Operations
module outer_shell_union() {
  union() {
    outer_taper();
    stepped_boss_end();
    flush_rounded_end();
    edge_chamfers_fillets();
  }
}

module outer_shell_with_flats() {
  difference() {
    outer_shell_union();
    irregular_flat_variation();
    surface_micro_faceting_detail();
  }
}

module final_sleeve_model() {
  difference() {
    outer_shell_with_flats();
    hex_through_bore();
  }
}

// Final Output
final_sleeve_model();
}
