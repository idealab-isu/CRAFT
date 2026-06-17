// Parameters
pulley_type_is_toothed = 1; //[0:1:1]
tooth_count = 20; //[10:60:1]
outer_diameter_mm = 20; //[10:40:1]
belt_width_mm = 6; //[3:20:1]
bore_diameter_mm = 5; //[2.5:10:0.5]
hub_length_mm = 10; //[5:25:1]
hub_diameter_mm = 12; //[6:24:1]
flange_diameter_mm = 22; //[11:44:1]
flange_thickness_mm = 1.5; //[0.8:4:0.1]
flange_enabled = 1; //[0:1:1]
set_screw_count = 0; //[0:4:1]
set_screw_diameter_mm = 3; //[2:6:0.5]
set_screw_z_offset_mm = 5; //[0:20:0.5]
rim_thickness_mm = 3; //[1.5:8:0.5]
tooth_radial_height_mm = 1.2; //[0.6:3:0.1]
tooth_tangential_width_factor = 0.55; //[0.3:0.8:0.05]
connection_overlap_mm = 1; //[0.5:2:0.1]
set_screw_length_mm = 50; //[20:120:1]

// Pulley module
module pulley() {
  color("Silver") {
    // Pulley wheel body
    difference() {
      cylinder(r=outer_diameter_mm/2, h=belt_width_mm, center=true);
      if (pulley_type_is_toothed == 0) {
        // Smooth rim inner cut
        cylinder(r=outer_diameter_mm/2 - rim_thickness_mm, h=belt_width_mm + 2*connection_overlap_mm, center=true);
      }
    }
    
    // Hub
    translate([0, 0, 0])
      cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true);
    
    // Flanges
    if (flange_enabled) {
      translate([0, 0, -(belt_width_mm/2 + flange_thickness_mm/2 - connection_overlap_mm)])
        cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
      translate([0, 0, (belt_width_mm/2 + flange_thickness_mm/2 - connection_overlap_mm)])
        cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
    }
    
    // Central bore
    translate([0, 0, 0])
      cylinder(r=bore_diameter_mm/2, h=hub_length_mm + belt_width_mm + 2*flange_thickness_mm + 4*connection_overlap_mm, center=true);
    
    // Teeth
    if (pulley_type_is_toothed == 1) {
      for (i = [0:tooth_count-1]) {
        rotate([0, 0, i*360/tooth_count]) {
          translate([(outer_diameter_mm/2) + (tooth_radial_height_mm/2) - connection_overlap_mm, 0, 0])
            cube([tooth_radial_height_mm, (outer_diameter_mm*3.141592653589793/tooth_count)*tooth_tangential_width_factor, belt_width_mm], center=true);
        }
      }
    }
    
    // Set screw holes
    if (set_screw_count > 0) {
      for (i = [0:set_screw_count-1]) {
        rotate([0, 0, i*360/set_screw_count]) {
          translate([0, 0, -hub_length_mm/2 + set_screw_z_offset_mm])
            rotate([0, 90, 0])
              cylinder(r=set_screw_diameter_mm/2, h=set_screw_length_mm, center=true);
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