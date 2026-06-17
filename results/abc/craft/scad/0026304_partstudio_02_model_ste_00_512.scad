// Dimension-calibrated (target: 0.93 x 0.35 x 1.43 mm)
scale([0.730470, 2.795051, 0.996890])
{
// Parameters
bbox_x = 0.93; //[0.465:1.86:0.01]
bbox_y = 0.35; //[0.175:0.7:0.01]
bbox_z = 1.43; //[0.715:2.86:0.01]
shaft_r = 0.12; //[0.06:0.24:0.005]
shaft_len = 1.43; //[0.715:2.86:0.01]
fin_r = 0.165; //[0.0825:0.33:0.005]
fin_thk = 0.03; //[0.015:0.06:0.001]
fin_pitch = 0.06; //[0.03:0.12:0.001]
fin_count = 12; //[6:24:1]
fin_section_len = 0.84; //[0.42:1.68:0.01]
cap_len = 0.18; //[0.09:0.36:0.005]
cap_flat_d = 0.33; //[0.165:0.35:0.005]
cap_sides = 6; //[6:8:1]
tab_len_radial = 0.045; //[0.02:0.09:0.001]
tab_thk_tangential = 0.05; //[0.02:0.1:0.001]
tab_h_axial = 0.03; //[0.015:0.06:0.001]
tab_count = 10; //[4:20:1]
tab_span_len = 0.9; //[0.45:1.2:0.01]
nub_r = 0.03; //[0.015:0.06:0.001]
nub_len_radial = 0.05; //[0.02:0.1:0.001]
nub_z_from_end = 0.12; //[0.06:0.24:0.005]
overlap = 0.001; //[0.0005:0.01:0.0005]
chamfer_len = 0.03; //[0.01:0.06:0.001]
chamfer_scale = 0.85; //[0.7:0.95:0.01]
fillet_r = 0.006; //[0.002:0.02:0.001]
texture_r = 0.002; //[0.001:0.006:0.0005]

// Main shaft
module main_shaft() {
  color("DimGray")
  cylinder(h=shaft_len, r=shaft_r, center=true);
}

// Fins
module fins() {
  color("Silver")
  for (i = [0:fin_count-1]) {
    translate([0, 0, (-fin_section_len/2) + (i*fin_pitch)])
      cylinder(h=fin_thk, r=fin_r, center=true);
  }
}

// End caps
module end_cap() {
  color("Silver")
  cylinder(h=cap_len, r=(cap_flat_d/2)/cos(180/cap_sides), center=true, $fn=cap_sides);
}

// Tabs
module tab() {
  color("Black")
  cube([tab_len_radial + shaft_r + overlap, tab_thk_tangential, tab_h_axial], center=true);
}

module tabs() {
  for (i = [0:tab_count-1]) {
    translate([(shaft_r + (tab_len_radial + shaft_r + overlap)/2) - overlap, 0, (-tab_span_len/2) + (i*(tab_span_len/(tab_count-1)))])
      tab();
  }
}

// Side nub
module side_nub() {
  color("Black")
  translate([(shaft_r + nub_len_radial/2) - overlap, 0, (shaft_len/2) - nub_z_from_end])
    rotate([0, 90, 0])
      cylinder(h=nub_len_radial, r=nub_r, center=true);
}

// Chamfer cuts
module chamfer_cut() {
  color("Silver")
  cylinder(h=chamfer_len, r=((cap_flat_d/2)/cos(180/cap_sides))*chamfer_scale, center=true);
}

// Fillet sphere
module fillet_sphere() {
  sphere(r=fillet_r, center=true);
}

// Texture sphere
module texture_sphere() {
  sphere(r=texture_r, center=true);
}

// Assemble component
module elongated_micro_rod() {
  difference() {
    union() {
      main_shaft();
      fins();
      translate([0, 0, (-shaft_len/2) + (cap_len/2) - overlap]) end_cap();
      translate([0, 0, (shaft_len/2) - (cap_len/2) + overlap]) end_cap();
      tabs();
      side_nub();
    }
    translate([0, 0, (-shaft_len/2) + chamfer_len/2]) chamfer_cut();
    translate([0, 0, (shaft_len/2) - chamfer_len/2]) chamfer_cut();
  }
}

// Final output with texture
minkowski() {
  elongated_micro_rod();
  texture_sphere();
}
}
