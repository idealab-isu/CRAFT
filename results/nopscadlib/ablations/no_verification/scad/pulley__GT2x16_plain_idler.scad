// Parameters
pulley_type = 0; //[0:1:1]
teeth_count = 20; //[10:60:1]
outer_diameter_mm = 16; //[8:32:0.5]
belt_width_mm = 6; //[3:20:0.5]
bore_diameter_mm = 5; //[2:12:0.1]
hub_diameter_mm = 12; //[6:24:0.5]
hub_length_mm = 10; //[5:25:0.5]
flange_diameter_mm = 18; //[10:40:0.5]
flange_thickness_mm = 1; //[0.5:3:0.1]
set_screw_count = 0; //[0:2:1]
set_screw_diameter_mm = 3; //[2:6:0.1]
set_screw_z_offset_mm = 0; //[-5:5:0.5]
overlap_mm = 1; //[0.5:2:0.1]
clearance_mm = 0.2; //[0:0.6:0.05]
tooth_radial_height_mm = 1; //[0.5:2.5:0.1]
tooth_tangential_width_factor = 0.45; //[0.2:0.8:0.05]

// Pulley module
module pulley() {
  color("Silver") {
    // Pulley body
    union() {
      cylinder(r=outer_diameter_mm/2, h=belt_width_mm, center=true);
      if (pulley_type == 1) {
        for (i = [0:teeth_count-1]) {
          rotate([0, 0, i*360/teeth_count])
          translate([outer_diameter_mm/2 + tooth_radial_height_mm/2 - overlap_mm, 0, 0])
          cube([tooth_radial_height_mm, (PI*outer_diameter_mm/teeth_count)*tooth_tangential_width_factor, belt_width_mm], center=true);
        }
      }
    }
    
    // Hub
    translate([0, 0, 0])
    cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true);
    
    // Flanges
    translate([0, 0, belt_width_mm/2 + flange_thickness_mm/2 - overlap_mm])
    cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
    
    translate([0, 0, -(belt_width_mm/2 + flange_thickness_mm/2 - overlap_mm)])
    cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
  }
  
  // Bore
  difference() {
    cylinder(r=(bore_diameter_mm + clearance_mm)/2, h=hub_length_mm + 2*flange_thickness_mm + 2*overlap_mm, center=true);
    
    // Set screw holes
    if (set_screw_count > 0) {
      translate([0, 0, set_screw_z_offset_mm])
      rotate([0, 90, 0])
      cylinder(r=(set_screw_diameter_mm + clearance_mm)/2, h=hub_diameter_mm + 2*overlap_mm, center=true);
      
      if (set_screw_count == 2) {
        translate([0, 0, set_screw_z_offset_mm])
        rotate([90, 0, 0])
        cylinder(r=(set_screw_diameter_mm + clearance_mm)/2, h=hub_diameter_mm + 2*overlap_mm, center=true);
      }
    }
  }
}

// Assembly
module assembly() {
  pulley();
}

assembly();