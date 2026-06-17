// Parameters
tooth_count = 12; //[6:24:1]
pitch_diameter_mm = 7.15; //[3.5:14.3:0.01]
pulley_width_mm = 8; //[4:20:0.5]
tooth_radial_height_mm = 1.2; //[0.6:2.4:0.05]
tooth_tangential_width_factor = 0.55; //[0.35:0.75:0.01]
tooth_overlap_mm = 0.8; //[0.3:2:0.05]
body_radial_thickness_mm = 1.6; //[0.8:3.2:0.05]
bore_diameter_mm = 3; //[1:6:0.1]
hub_diameter_mm = 10; //[5:20:0.1]
hub_length_mm = 6; //[0:20:0.5]
flange_diameter_mm = 12; //[7:24:0.1]
flange_thickness_mm = 1.2; //[0:3:0.1]
set_screw_count = 1; //[0:2:1]
set_screw_diameter_mm = 2; //[1:4:0.1]
set_screw_z_mm = 0; //[-10:10:0.5]
set_screw_radial_pos_factor = 0.75; //[0.55:0.95:0.01]
set_screw_length_mm = 30; //[10:80:1]

// Pulley Body
module pulley_body() {
  color("Silver") {
    cylinder(h=pulley_width_mm, r=(pitch_diameter_mm/2) - body_radial_thickness_mm, center=true);
  }
}

// Printed Pulley Teeth
module printed_pulley_teeth() {
  color("DimGray") {
    for (i = [0:tooth_count-1]) {
      rotate([0, 0, i*360/tooth_count]) {
        translate([(pitch_diameter_mm/2) + (tooth_radial_height_mm + tooth_overlap_mm)/2 - tooth_overlap_mm, 0, 0]) {
          cube([tooth_radial_height_mm + tooth_overlap_mm, (PI*pitch_diameter_mm/tooth_count) * tooth_tangential_width_factor, pulley_width_mm], center=true);
        }
      }
    }
  }
}

// Printed Pulley Teeth From Profile
module printed_pulley_teeth_from_profile() {
  printed_pulley_teeth();
}

// Printed Pulley GT2 Teeth
module printed_pulley_GT2_teeth() {
  printed_pulley_teeth_from_profile();
}

// Hub
module hub() {
  if (hub_length_mm > 0) {
    color("Silver") {
      translate([0, 0, -(pulley_width_mm/2) - (hub_length_mm/2) + 1]) {
        cylinder(h=hub_length_mm, r=hub_diameter_mm/2, center=true);
      }
    }
  }
}

// Flanges
module flanges() {
  if (flange_thickness_mm > 0) {
    color("Silver") {
      translate([0, 0, (pulley_width_mm/2) + (flange_thickness_mm/2) - 0.5]) {
        cylinder(h=flange_thickness_mm, r=flange_diameter_mm/2, center=true);
      }
      translate([0, 0, -(pulley_width_mm/2) - (flange_thickness_mm/2) + 0.5]) {
        cylinder(h=flange_thickness_mm, r=flange_diameter_mm/2, center=true);
      }
    }
  }
}

// Set Screw Holes
module set_screw_holes() {
  if (set_screw_count > 0) {
    color("Black") {
      translate([(hub_diameter_mm/2) * set_screw_radial_pos_factor, 0, set_screw_z_mm]) {
        rotate([0, 90, 0]) {
          cylinder(h=set_screw_length_mm, r=set_screw_diameter_mm/2, center=true);
        }
      }
      if (set_screw_count > 1) {
        rotate([0, 0, 90]) {
          translate([(hub_diameter_mm/2) * set_screw_radial_pos_factor, 0, set_screw_z_mm]) {
            rotate([0, 90, 0]) {
              cylinder(h=set_screw_length_mm, r=set_screw_diameter_mm/2, center=true);
            }
          }
        }
      }
    }
  }
}

// Pulley Assembly
module pulley() {
  difference() {
    union() {
      pulley_body();
      printed_pulley_GT2_teeth();
      hub();
      flanges();
    }
    cylinder(h=pulley_width_mm + 2*flange_thickness_mm + hub_length_mm + 2, r=bore_diameter_mm/2, center=true);
    set_screw_holes();
  }
}

// Final Assembly
module assembly() {
  pulley();
}

assembly();