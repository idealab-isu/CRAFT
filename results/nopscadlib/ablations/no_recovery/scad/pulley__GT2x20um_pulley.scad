// Parameters
tooth_count = 20; //[10:60:1]
pitch_diameter_mm = 12.22; //[6.11:24.44:0.01]
belt_pitch_mm = 2; //[1:5:0.01]
belt_width_mm = 6; //[3:15:0.5]
tooth_depth_mm = 0.75; //[0.4:1.5:0.01]
tooth_tip_radius_mm = 0.55; //[0.3:1.0:0.01]
tooth_root_radius_mm = 0.35; //[0.2:0.8:0.01]
bore_diameter_mm = 5; //[2:10:0.01]
hub_diameter_mm = 16; //[10:32:0.1]
hub_length_mm = 12; //[6:24:0.1]
flange_diameter_mm = 18; //[12:36:0.1]
flange_thickness_mm = 1.5; //[0.8:4:0.1]
set_screw_count = 2; //[0:4:1]
set_screw_hole_diameter_mm = 2.8; //[2:6:0.01]
set_screw_z_mm = 6; //[1:20:0.1]
overlap_mm = 1; //[0.5:2:0.1]
radial_clearance_mm = 0.2; //[0:0.6:0.01]

// Pulley Body
module pulley_body() {
  color("Silver") {
    cylinder(h=belt_width_mm, r=pitch_diameter_mm/2 - tooth_depth_mm - radial_clearance_mm, center=true);
  }
}

// Hub
module hub() {
  color("Silver") {
    cylinder(h=hub_length_mm, r=hub_diameter_mm/2, center=true);
  }
}

// Flanges
module flange_bottom() {
  color("Silver") {
    translate([0, 0, -belt_width_mm/2 - flange_thickness_mm/2 + overlap_mm])
      cylinder(h=flange_thickness_mm, r=flange_diameter_mm/2, center=true);
  }
}

module flange_top() {
  color("Silver") {
    translate([0, 0, belt_width_mm/2 + flange_thickness_mm/2 - overlap_mm])
      cylinder(h=flange_thickness_mm, r=flange_diameter_mm/2, center=true);
  }
}

// Bore
module bore() {
  cylinder(h=hub_length_mm + 2*flange_thickness_mm + 2*overlap_mm, r=bore_diameter_mm/2, center=true);
}

// Printed Pulley GT2 Teeth
module printed_pulley_GT2_teeth() {
  hull() {
    translate([pitch_diameter_mm/2 - tooth_depth_mm + tooth_tip_radius_mm - overlap_mm, 0, 0])
      cylinder(h=belt_width_mm, r=tooth_tip_radius_mm, center=true);
    translate([pitch_diameter_mm/2 - tooth_depth_mm + 2*tooth_tip_radius_mm - overlap_mm, 0, 0])
      cube([2*tooth_tip_radius_mm, belt_pitch_mm/2, belt_width_mm], center=true);
  }
}

// Printed Pulley Teeth From Profile
module printed_pulley_teeth_from_profile() {
  hull() {
    translate([pitch_diameter_mm/2 - tooth_depth_mm - tooth_root_radius_mm + overlap_mm, 0, 0])
      cylinder(h=belt_width_mm, r=tooth_root_radius_mm, center=true);
    translate([pitch_diameter_mm/2 - tooth_depth_mm - 2*tooth_root_radius_mm + overlap_mm, 0, 0])
      cube([2*tooth_root_radius_mm, belt_pitch_mm/2, belt_width_mm], center=true);
  }
}

// Printed Pulley Teeth
module printed_pulley_teeth() {
  union() {
    printed_pulley_GT2_teeth();
    printed_pulley_teeth_from_profile();
  }
}

// Tooth Ring
module tooth_ring() {
  for (i = [0:tooth_count-1]) {
    rotate([0, 0, i*360/tooth_count])
      printed_pulley_teeth();
  }
}

// Set Screw Holes
module set_screw_holes() {
  if (set_screw_count > 0) {
    for (i = [0:set_screw_count-1]) {
      rotate([0, 0, i*360/set_screw_count])
        translate([0, 0, -hub_length_mm/2 + set_screw_z_mm])
          rotate([0, 90, 0])
            cylinder(h=hub_diameter_mm + 2*overlap_mm, r=set_screw_hole_diameter_mm/2, center=true);
    }
  }
}

// Pulley Assembly
module pulley() {
  difference() {
    union() {
      pulley_body();
      hub();
      flange_bottom();
      flange_top();
      tooth_ring();
    }
    bore();
    set_screw_holes();
  }
}

// Final Assembly
module assembly() {
  pulley();
}

assembly();