// Parameters
tooth_count = 16; //[8:64:1]
pitch_diameter_mm = 12.16; //[6.08:24.32:0.01]
pulley_width_mm = 10; //[5:30:1]
tooth_radial_height_mm = 1.2; //[0.6:2.4:0.1]
tooth_tangential_width_factor = 0.55; //[0.35:0.8:0.01]
core_radial_thickness_mm = 1.6; //[0.8:3.2:0.1]
bore_diameter_mm = 5; //[2:10:0.1]
hub_diameter_mm = 14; //[7:28:0.1]
hub_length_mm = 14; //[7:28:1]
flange_enabled = 1; //[0:1:1]
flange_diameter_mm = 18; //[9:36:0.1]
flange_thickness_mm = 1.5; //[0.8:3:0.1]
set_screw_count = 1; //[0:2:1]
set_screw_hole_diameter_mm = 2.5; //[1.5:5:0.1]
set_screw_z_offset_mm = 0; //[-10:10:0.5]
overlap_mm = 0.8; //[0.3:2:0.1]

// Derived parameters
pitch_radius = pitch_diameter_mm / 2;
core_radius = pitch_radius - core_radial_thickness_mm;
tooth_pitch_mm = pitch_diameter_mm * PI / tooth_count;
tooth_width = tooth_pitch_mm * tooth_tangential_width_factor;

// Pulley Core Body
module pulley_core_body() {
  color("Silver") {
    cylinder(r=core_radius, h=pulley_width_mm, center=true);
  }
}

// Hub
module hub() {
  color("Silver") {
    cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true);
  }
}

// Flanges
module flange_top() {
  color("Silver") {
    cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm*flange_enabled, center=true);
  }
}

module flange_bottom() {
  color("Silver") {
    cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm*flange_enabled, center=true);
  }
}

// Center Bore
module center_bore() {
  cylinder(r=bore_diameter_mm/2, h=hub_length_mm + 2*flange_thickness_mm + 2*overlap_mm, center=true);
}

// Teeth
module tooth() {
  translate([pitch_radius + (tooth_radial_height_mm + overlap_mm)/2 - overlap_mm, 0, 0])
    cube([tooth_radial_height_mm + overlap_mm, tooth_width, pulley_width_mm], center=true);
}

module printed_pulley_teeth() {
  for (i = [0:tooth_count-1]) {
    rotate([0, 0, i*360/tooth_count]) tooth();
  }
}

// Set Screw Holes
module set_screw_hole_0() {
  rotate([0, 90, 0])
    cylinder(r=set_screw_hole_diameter_mm/2, h=hub_diameter_mm + 2*tooth_radial_height_mm + 2*overlap_mm, center=true);
}

module set_screw_hole_1() {
  rotate([0, 90, 90])
    cylinder(r=set_screw_hole_diameter_mm/2, h=hub_diameter_mm + 2*tooth_radial_height_mm + 2*overlap_mm, center=true);
}

// Assembly
module pulley() {
  difference() {
    union() {
      pulley_core_body();
      printed_pulley_teeth();
      hub();
      translate([0, 0, pulley_width_mm/2 + (flange_thickness_mm*flange_enabled)/2 - overlap_mm]) flange_top();
      translate([0, 0, -pulley_width_mm/2 - (flange_thickness_mm*flange_enabled)/2 + overlap_mm]) flange_bottom();
    }
    center_bore();
    if (set_screw_count > 0) {
      set_screw_hole_0();
    }
    if (set_screw_count > 1) {
      set_screw_hole_1();
    }
  }
}

module assembly() {
  pulley();
}

assembly();