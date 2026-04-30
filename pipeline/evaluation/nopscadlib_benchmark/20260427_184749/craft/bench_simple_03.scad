// Parameters
primary_dimension = 5; //[2.5:10:0.1]
tooth_count = 20; //[10:60:1]
pitch_mm = 2; //[1:5:0.1]
bore_diameter_mm = 5; //[2.5:10:0.1]
belt_width_mm = 3; //[1.5:6:0.1]
tooth_height_mm = 0.5; //[0.25:1:0.05]
tooth_tangential_width_mm = 0.5; //[0.25:1:0.05]
tooth_section_width_mm = 3; //[1.5:6:0.1]
hub_diameter_mm = 7.5; //[3.75:15:0.1]
hub_length_mm = 5; //[2.5:10:0.1]
flange_enabled = 1; //[0:1:1]
flange_diameter_mm = 10; //[5:20:0.1]
flange_thickness_mm = 0.5; //[0:1:0.05]
overlap_mm = 0.5; //[0.2:1:0.1]
pulley_pitch_diameter_mm = 12.732; //[6.366:25.464:0.001]
pulley_outer_diameter_mm = 13.732; //[6.866:27.464:0.001]

// Base Shapes
module hub_body_cyl() {
  color("Silver")
  cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true);
}

module toothed_outer_ring_cyl() {
  color("DimGray")
  cylinder(r=pulley_outer_diameter_mm/2, h=tooth_section_width_mm, center=true);
}

module tooth_box_raw() {
  color("Black")
  cube([tooth_height_mm, tooth_tangential_width_mm, tooth_section_width_mm], center=true);
}

module flange_disc_raw() {
  color("Silver")
  cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm*flange_enabled, center=true);
}

module center_bore_cyl() {
  cylinder(r=bore_diameter_mm/2, h=hub_length_mm + tooth_section_width_mm + 2*flange_thickness_mm + 4*overlap_mm, center=true);
}

// Operations
module tooth_box_pos() {
  translate([pulley_outer_diameter_mm/2 - tooth_height_mm/2 - overlap_mm, 0, 0])
    tooth_box_raw();
}

module printed_pulley_GT2_teeth() {
  for (i = [0:tooth_count-1]) {
    rotate([0, 0, i * 360/tooth_count])
      tooth_box_pos();
  }
}

module toothed_outer_profile() {
  union() {
    toothed_outer_ring_cyl();
    printed_pulley_GT2_teeth();
  }
}

module flange_top_pos() {
  translate([0, 0, tooth_section_width_mm/2 + (flange_thickness_mm*flange_enabled)/2 - overlap_mm])
    flange_disc_raw();
}

module flange_bottom_pos() {
  translate([0, 0, -tooth_section_width_mm/2 - (flange_thickness_mm*flange_enabled)/2 + overlap_mm])
    flange_disc_raw();
}

module belt_flanges() {
  union() {
    flange_top_pos();
    flange_bottom_pos();
  }
}

module pulley_solid_union() {
  union() {
    hub_body_cyl();
    toothed_outer_profile();
    belt_flanges();
  }
}

// Final Output
difference() {
  pulley_solid_union();
  center_bore_cyl();
}