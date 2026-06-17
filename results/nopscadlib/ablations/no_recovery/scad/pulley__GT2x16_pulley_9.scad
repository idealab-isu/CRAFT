// Parameters
tooth_count = 16; //[8:64:1]
pitch_diameter_mm = 9.65; //[4.825:19.3:0.01]
pitch_radius_mm = 4.825; //[2.4125:9.65:0.01]
pulley_width_mm = 10; //[5:30:1]
bore_diameter_mm = 5; //[2:10:0.1]
hub_diameter_mm = 12; //[6:24:0.1]
hub_length_mm = 6; //[0:20:0.5]
flange_diameter_mm = 14; //[8:30:0.1]
flange_thickness_mm = 1.5; //[0:5:0.1]
set_screw_count = 1; //[0:2:1]
set_screw_size = 3; //[2:6:0.5]
set_screw_z_offset_mm = 0; //[-10:10:0.5]
tooth_radial_height_mm = 1.2; //[0.6:2.4:0.1]
tooth_tangential_width_factor = 0.55; //[0.3:0.9:0.01]
tooth_overlap_mm = 0.8; //[0.5:2:0.1]
body_wall_to_pitch_mm = 0.8; //[0.3:2:0.1]
eps_mm = 0.2; //[0.05:0.5:0.05]

// Pulley Body
module pulley_body() {
  color("Silver") {
    cylinder(r=pitch_radius_mm - body_wall_to_pitch_mm, h=pulley_width_mm, center=true);
  }
}

// Tooth Prototype
module tooth_proto() {
  translate([pitch_radius_mm + (tooth_radial_height_mm + tooth_overlap_mm)/2 - tooth_overlap_mm, 0, 0])
  cube([tooth_radial_height_mm + tooth_overlap_mm, 
        (PI * pitch_diameter_mm / tooth_count) * tooth_tangential_width_factor, 
        pulley_width_mm], center=true);
}

// Printed Pulley Teeth
module printed_pulley_teeth() {
  for (i = [0:tooth_count-1]) {
    rotate([0, 0, i * 360 / tooth_count]) tooth_proto();
  }
}

// Hub
module hub() {
  if (hub_length_mm > 0) {
    color("Silver") {
      translate([0, 0, -pulley_width_mm/2 - hub_length_mm/2 + eps_mm])
      cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true);
    }
  }
}

// Flanges
module flanges() {
  if (flange_thickness_mm > 0) {
    color("Silver") {
      translate([0, 0, pulley_width_mm/2 + flange_thickness_mm/2 - eps_mm])
      cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
      translate([0, 0, -pulley_width_mm/2 - flange_thickness_mm/2 + eps_mm])
      cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
    }
  }
}

// Center Bore
module center_bore() {
  cylinder(r=bore_diameter_mm/2, 
           h=pulley_width_mm + hub_length_mm + 2*flange_thickness_mm + 4*eps_mm, 
           center=true);
}

// Set Screw Holes
module set_screw_holes() {
  if (set_screw_count > 0) {
    translate([0, hub_diameter_mm/2 - set_screw_size/2 - eps_mm, 
               -pulley_width_mm/2 - hub_length_mm/2 + eps_mm + set_screw_z_offset_mm])
    rotate([0, 90, 0])
    cylinder(r=set_screw_size/2, h=hub_diameter_mm + 2*eps_mm, center=true);
    
    if (set_screw_count > 1) {
      rotate([0, 0, 90])
      translate([0, hub_diameter_mm/2 - set_screw_size/2 - eps_mm, 
                 -pulley_width_mm/2 - hub_length_mm/2 + eps_mm + set_screw_z_offset_mm])
      rotate([0, 90, 0])
      cylinder(r=set_screw_size/2, h=hub_diameter_mm + 2*eps_mm, center=true);
    }
  }
}

// Pulley Assembly
module pulley() {
  difference() {
    union() {
      pulley_body();
      printed_pulley_teeth();
      hub();
      flanges();
    }
    center_bore();
    set_screw_holes();
  }
}

// Final Assembly
module assembly() {
  pulley();
}

assembly();