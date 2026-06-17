// Parameters
pulley_type = 1; //[0:1:1]
tooth_profile = 0; //[0:4:1]
tooth_count = 20; //[10:60:1]
outer_diameter_mm = 16; //[8:32:0.5]
belt_width_mm = 6; //[3:20:0.5]
bore_diameter_mm = 5; //[2:12:0.1]
hub_diameter_mm = 12; //[6:24:0.5]
hub_length_mm = 10; //[5:25:0.5]
flange_diameter_mm = 18; //[10:40:0.5]
flange_thickness_mm = 1; //[0:4:0.25]
set_screw_count = 0; //[0:2:1]
set_screw_size = 3; //[2:6:1]
set_screw_z_offset_mm = 5; //[0:20:0.5]
tolerances_mm = 0.2; //[0:0.6:0.05]
overlap_mm = 1; //[0.5:2:0.1]
rim_wall_radial_mm = 2; //[1:6:0.25]
tooth_height_mm = 1.2; //[0.5:3:0.1]
tooth_width_mm = 1.6; //[0.8:4:0.1]

// Pulley - complete geometry
module pulley() {
  color("Silver") {
    // Pulley body
    union() {
      translate([0, 0, 0])
        cylinder(r=outer_diameter_mm/2, h=belt_width_mm + 2*flange_thickness_mm, center=true);
      
      // Hub
      translate([0, 0, 0])
        cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true);
      
      // Outer rim
      translate([0, 0, 0])
        cylinder(r=outer_diameter_mm/2, h=belt_width_mm, center=true);
      
      // Flanges
      if (flange_thickness_mm > 0) {
        translate([0, 0, belt_width_mm/2 + flange_thickness_mm/2 - overlap_mm/2])
          cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
        translate([0, 0, -(belt_width_mm/2 + flange_thickness_mm/2 - overlap_mm/2)])
          cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
      }
      
      // Teeth or smooth crown
      if (pulley_type == 1) {
        for (i = [0:tooth_count-1]) {
          rotate([0, 0, i*360/tooth_count])
            translate([outer_diameter_mm/2 - tooth_height_mm/2, 0, 0])
              cube([tooth_height_mm, tooth_width_mm, belt_width_mm], center=true);
        }
      }
    }
    
    // Bore
    difference() {
      translate([0, 0, 0])
        cylinder(r=(bore_diameter_mm + 2*tolerances_mm)/2, h=hub_length_mm + 2*overlap_mm, center=true);
      
      // Set screw holes
      if (set_screw_count > 0) {
        for (i = [0:set_screw_count-1]) {
          rotate([0, 0, i*90])
            translate([0, 0, (-hub_length_mm/2) + set_screw_z_offset_mm])
              cylinder(r=(set_screw_size + tolerances_mm)/2, h=hub_diameter_mm + 2*overlap_mm, center=true);
        }
      }
    }
  }
}

// Assembly
module assembly() {
  pulley();
}

assembly();