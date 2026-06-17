// Parameters
tooth_count = 20; //[10:60:1]
pitch_diameter_mm = 12.22; //[6.11:24.44:0.01]
pitch_radius_mm = 6.11; //[3.055:12.22:0.01]
belt_pitch_mm = 2; //[1:10:0.01]
tooth_depth_mm = 0.8; //[0.4:1.6:0.01]
tooth_width_mm = 1.5; //[0.8:3:0.01]
pulley_width_mm = 7; //[3.5:14:0.1]
bore_diameter_mm = 5; //[2.5:10:0.01]
hub_diameter_mm = 12; //[6:24:0.1]
hub_length_mm = 10; //[5:20:0.1]
flange_enabled = 1; //[0:1:1]
flange_diameter_mm = 16; //[8:32:0.1]
flange_thickness_mm = 1.2; //[0.6:2.4:0.05]
set_screw_count = 1; //[0:2:1]
set_screw_thread_diameter_mm = 3; //[2:5:0.1]
set_screw_z_mm = 5; //[0:20:0.1]
tolerances_mm = 0.2; //[0.05:0.5:0.01]
overlap_mm = 1; //[0.5:2:0.1]

// Pulley - complete geometry
module pulley() {
  color("Silver") {
    // Toothed pulley body
    difference() {
      translate([0, 0, hub_length_mm/2 + flange_thickness_mm*flange_enabled + pulley_width_mm/2 - overlap_mm])
        cylinder(r=pitch_radius_mm + tooth_depth_mm, h=pulley_width_mm, center=true);
      // Tooth notches
      for (i = [0:tooth_count-1]) {
        rotate([0, 0, i*360/tooth_count])
          translate([pitch_radius_mm + tooth_depth_mm/2, 0, hub_length_mm/2 + flange_thickness_mm*flange_enabled + pulley_width_mm/2 - overlap_mm])
            cube([tooth_depth_mm + overlap_mm, tooth_width_mm, pulley_width_mm + 2*overlap_mm], center=true);
      }
    }
    // Hub
    translate([0, 0, hub_length_mm/2])
      cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true);
    // Flanges
    if (flange_enabled) {
      translate([0, 0, hub_length_mm + (flange_thickness_mm*flange_enabled)/2 - overlap_mm])
        cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
      translate([0, 0, hub_length_mm + flange_thickness_mm*flange_enabled + pulley_width_mm - overlap_mm + (flange_thickness_mm*flange_enabled)/2])
        cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
    }
    // Bore
    translate([0, 0, hub_length_mm + flange_thickness_mm*flange_enabled + pulley_width_mm/2])
      cylinder(r=(bore_diameter_mm + 2*tolerances_mm)/2, h=hub_length_mm + pulley_width_mm + 2*flange_thickness_mm*flange_enabled + 4*overlap_mm, center=true);
    // Set screw holes
    if (set_screw_count > 0) {
      for (i = [0:set_screw_count-1]) {
        rotate([0, 0, i*90])
          translate([hub_diameter_mm/2 - overlap_mm, 0, set_screw_z_mm])
            rotate([0, 90, 0])
              cylinder(r=set_screw_thread_diameter_mm/2, h=hub_diameter_mm + 4*overlap_mm, center=true);
      }
    }
  }
}

// Printed Pulley Teeth From Profile - detailed geometry
module printed_pulley_teeth_from_profile() {
  color("Gray") {
    // Example geometry for printed pulley teeth from profile
    translate([0, 0, hub_length_mm + flange_thickness_mm*flange_enabled + pulley_width_mm/2])
      cylinder(r=pitch_radius_mm, h=pulley_width_mm, center=true);
  }
}

// Printed Pulley GT2 Teeth - detailed geometry
module printed_pulley_GT2_teeth() {
  color("Gray") {
    // Example geometry for printed GT2 teeth
    translate([0, 0, hub_length_mm + flange_thickness_mm*flange_enabled + pulley_width_mm/2])
      cylinder(r=pitch_radius_mm - tooth_depth_mm, h=pulley_width_mm, center=true);
  }
}

// Printed Pulley Teeth - detailed geometry
module printed_pulley_teeth() {
  color("Gray") {
    // Example geometry for printed pulley teeth
    translate([0, 0, hub_length_mm + flange_thickness_mm*flange_enabled + pulley_width_mm/2])
      cylinder(r=pitch_radius_mm - tooth_depth_mm/2, h=pulley_width_mm, center=true);
  }
}

// Assembly
module assembly() {
  pulley();
  printed_pulley_teeth_from_profile();
  printed_pulley_GT2_teeth();
  printed_pulley_teeth();
}

assembly();