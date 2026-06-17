// Parameters
tooth_count = 20; //[10:60:1]
pitch_diameter_mm = 12.22; //[6.11:24.44:0.01]
pitch_radius_mm = 6.11; //[3.055:12.22:0.01]
pulley_width_mm = 10; //[5:30:1]
tooth_pitch_mm_derived = 1.919513102640804; //[0.959756551320402:3.839026205281608:0.0001]
tooth_radial_height_mm = 1.2; //[0.6:2.4:0.05]
tooth_tangential_width_mm = 1.2; //[0.6:2.4:0.05]
tooth_overlap_mm = 0.8; //[0.3:1.5:0.05]
root_clearance_mm = 0.6; //[0.2:1.5:0.05]
hub_diameter_mm = 18; //[9:36:0.5]
hub_length_mm = 14; //[7:28:1]
bore_diameter_mm = 5; //[2:12:0.1]
flange_diameter_mm = 22; //[12:44:0.5]
flange_thickness_mm = 1.5; //[0.8:4:0.1]
eps_mm = 0.8; //[0.2:2:0.1]

// Pulley - complete geometry
module pulley() {
  color("Silver") {
    union() {
      // Toothed pulley body
      cylinder(r=pitch_radius_mm - root_clearance_mm, h=pulley_width_mm, center=true);
      
      // Hub
      cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true);
      
      // Flanges
      translate([0, 0, pulley_width_mm/2 + flange_thickness_mm/2 - eps_mm])
        cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
      translate([0, 0, -pulley_width_mm/2 - flange_thickness_mm/2 + eps_mm])
        cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
    }
  }
}

// Printed Pulley Teeth - complete geometry
module printed_pulley_teeth() {
  for (i = [0:tooth_count-1]) {
    rotate([0, 0, i*360/tooth_count]) {
      translate([pitch_radius_mm - root_clearance_mm + (tooth_radial_height_mm + tooth_overlap_mm)/2 - tooth_overlap_mm, 0, 0])
        cube([tooth_radial_height_mm + tooth_overlap_mm, tooth_tangential_width_mm, pulley_width_mm], center=true);
    }
  }
}

// Printed Pulley GT2 Teeth - complete geometry
module printed_pulley_GT2_teeth() {
  union() {
    printed_pulley_teeth();
    cylinder(r=pitch_radius_mm, h=eps_mm, center=true);
  }
}

// Printed Pulley Teeth From Profile - complete geometry
module printed_pulley_teeth_from_profile() {
  union() {
    printed_pulley_GT2_teeth();
    cylinder(r=pitch_radius_mm - root_clearance_mm, h=pulley_width_mm, center=true);
  }
}

// Assembly
module assembly() {
  difference() {
    union() {
      printed_pulley_teeth_from_profile();
      pulley();
    }
    // Bore hole
    cylinder(r=bore_diameter_mm/2, h=hub_length_mm + 2*flange_thickness_mm + pulley_width_mm + 4*eps_mm, center=true);
  }
}

assembly();