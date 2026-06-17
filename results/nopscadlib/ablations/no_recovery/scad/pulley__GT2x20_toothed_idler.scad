// Parameters
tooth_count = 20; //[10:60:1]
pitch_diameter_mm = 12.22; //[6.11:24.44:0.01]
pitch_radius_mm = 6.11; //[3.055:12.22:0.01]
belt_pitch_mm = 2; //[1:5:0.01]
outside_diameter_mm = 13.6; //[6.8:27.2:0.01]
root_diameter_mm = 10.8; //[5.4:21.6:0.01]
pulley_width_mm = 7; //[3.5:14:0.1]
bore_diameter_mm = 5; //[2:10:0.01]
hub_diameter_mm = 16; //[8:32:0.1]
hub_length_mm = 10; //[5:20:0.1]
flange_diameter_mm = 18; //[9:36:0.1]
flange_thickness_mm = 1.5; //[0.8:3:0.1]
overlap_mm = 1; //[0.5:2:0.1]
tooth_round_r_mm = 0.55; //[0.3:1.2:0.01]

// Pulley - complete geometry
module pulley() {
  color("Silver") {
    union() {
      // Toothed pulley body
      translate([0, 0, 0])
        cylinder(r=outside_diameter_mm/2, h=pulley_width_mm, center=true, $fn=100);
      
      // Hub
      translate([0, 0, -(pulley_width_mm/2 + hub_length_mm/2 - overlap_mm)])
        cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true, $fn=100);
      
      // Flange top
      translate([0, 0, pulley_width_mm/2 + flange_thickness_mm/2 - overlap_mm])
        cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true, $fn=100);
      
      // Flange bottom
      translate([0, 0, -(pulley_width_mm/2 + flange_thickness_mm/2 - overlap_mm)])
        cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true, $fn=100);
    }
  }
}

// Printed Pulley Teeth - complete geometry
module printed_pulley_teeth() {
  color("DimGray") {
    rotate_extrude($fn=tooth_count)
      polygon(points=[
        [root_diameter_mm/2, -pulley_width_mm/2],
        [outside_diameter_mm/2, -pulley_width_mm/2],
        [outside_diameter_mm/2, pulley_width_mm/2],
        [root_diameter_mm/2, pulley_width_mm/2]
      ]);
  }
}

// Printed Pulley Teeth From Profile - complete geometry
module printed_pulley_teeth_from_profile() {
  color("DimGray") {
    rotate_extrude($fn=tooth_count)
      polygon(points=[
        [root_diameter_mm/2, -pulley_width_mm/2],
        [outside_diameter_mm/2, -pulley_width_mm/2],
        [outside_diameter_mm/2, pulley_width_mm/2],
        [root_diameter_mm/2, pulley_width_mm/2]
      ]);
  }
}

// Printed Pulley GT2 Teeth - complete geometry
module printed_pulley_GT2_teeth() {
  color("DimGray") {
    rotate_extrude($fn=tooth_count)
      polygon(points=[
        [pitch_radius_mm - (pitch_diameter_mm*3.141592653589793/tooth_count)/4, -pulley_width_mm/2],
        [pitch_radius_mm + (pitch_diameter_mm*3.141592653589793/tooth_count)/4, -pulley_width_mm/2],
        [pitch_radius_mm + (pitch_diameter_mm*3.141592653589793/tooth_count)/4, pulley_width_mm/2],
        [pitch_radius_mm - (pitch_diameter_mm*3.141592653589793/tooth_count)/4, pulley_width_mm/2]
      ]);
  }
}

// Assembly
module assembly() {
  difference() {
    pulley();
    // Bore
    translate([0, 0, -(hub_length_mm/2 - overlap_mm)])
      cylinder(r=bore_diameter_mm/2, h=pulley_width_mm + hub_length_mm + 2*flange_thickness_mm + 4*overlap_mm, center=true, $fn=100);
  }
  printed_pulley_teeth();
  printed_pulley_teeth_from_profile();
  printed_pulley_GT2_teeth();
}

assembly();