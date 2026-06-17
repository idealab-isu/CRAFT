// Parameters
tooth_count = 10; //[5:40:1]
pitch_diameter_mm = 15; //[7.5:30:0.1]
pitch_radius_mm = 7.5; //[3.75:15:0.1]
belt_pitch_mm = 2; //[1:5:0.1]
pulley_width_mm = 10; //[5:30:0.5]
tooth_depth_mm = 0.8; //[0.4:1.6:0.05]
tooth_width_mm = 1.5; //[0.8:3:0.05]
tooth_profile_scale_mm = 1; //[0.5:2:0.05]
bore_diameter_mm = 5; //[2.5:10:0.1]
hub_diameter_mm = 18; //[10:36:0.5]
hub_length_mm = 12; //[6:24:0.5]
flange_diameter_mm = 22; //[12:44:0.5]
flange_thickness_mm = 1.5; //[0.8:4:0.1]
rim_outer_radius_mm = 8.3; //[6:16:0.1]
rim_inner_radius_mm = 6.7; //[4:14:0.1]
core_radius_mm = 6.6; //[3:14:0.1]
overlap_mm = 1; //[0.5:2:0.1]
tolerances_mm = 0.2; //[0:0.6:0.05]

// Pulley Core Body
module pulley_core_body() {
  color("Silver") {
    translate([0, 0, 0])
      cylinder(r=core_radius_mm, h=pulley_width_mm, center=true);
  }
}

// Toothed Rim
module toothed_rim() {
  color("Silver") {
    translate([0, 0, 0])
      cylinder(r=rim_outer_radius_mm, h=pulley_width_mm, center=true);
  }
}

// Printed Pulley Teeth From Profile
module printed_pulley_teeth_from_profile() {
  color("Silver") {
    linear_extrude(height=pulley_width_mm, center=true) {
      polygon(points=[
        [-tooth_width_mm/2*tooth_profile_scale_mm, 0],
        [tooth_width_mm/2*tooth_profile_scale_mm, 0],
        [tooth_width_mm/2*tooth_profile_scale_mm, tooth_depth_mm*tooth_profile_scale_mm],
        [0, tooth_depth_mm*1.25*tooth_profile_scale_mm],
        [-tooth_width_mm/2*tooth_profile_scale_mm, tooth_depth_mm*tooth_profile_scale_mm]
      ]);
    }
  }
}

// Printed Pulley GT2 Teeth
module printed_pulley_GT2_teeth() {
  color("Silver") {
    linear_extrude(height=pulley_width_mm, center=true) {
      polygon(points=[
        [-tooth_width_mm/2, 0],
        [tooth_width_mm/2, 0],
        [tooth_width_mm/2, tooth_depth_mm],
        [0, tooth_depth_mm*1.25],
        [-tooth_width_mm/2, tooth_depth_mm]
      ]);
    }
  }
}

// Printed Pulley Teeth
module printed_pulley_teeth() {
  union() {
    printed_pulley_GT2_teeth();
    printed_pulley_teeth_from_profile();
  }
}

// Hub
module hub() {
  color("Silver") {
    translate([0, 0, -pulley_width_mm/2 - hub_length_mm/2 + overlap_mm])
      cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true);
  }
}

// Flange Top
module flange_top() {
  color("Silver") {
    translate([0, 0, pulley_width_mm/2 + flange_thickness_mm/2 - overlap_mm])
      cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
  }
}

// Flange Bottom
module flange_bottom() {
  color("Silver") {
    translate([0, 0, -pulley_width_mm/2 - flange_thickness_mm/2 + overlap_mm])
      cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
  }
}

// Central Bore
module central_bore() {
  translate([0, 0, -hub_length_mm/2])
    cylinder(r=(bore_diameter_mm + tolerances_mm)/2, h=pulley_width_mm + hub_length_mm + 2*flange_thickness_mm + 4*overlap_mm, center=true);
}

// Pulley Assembly
module pulley() {
  difference() {
    union() {
      pulley_core_body();
      toothed_rim();
      hub();
      flange_top();
      flange_bottom();
      // Teeth array
      for (i = [0:tooth_count-1]) {
        rotate([0, 0, i*360/tooth_count])
          translate([rim_inner_radius_mm + tooth_depth_mm/2 - overlap_mm, 0, 0])
          printed_pulley_teeth();
      }
    }
    central_bore();
  }
}

// Final Assembly
module assembly() {
  pulley();
}

assembly();