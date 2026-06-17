// Parameters
total_length_mm = 62; //[31:124:0.5]
barrel_outer_diameter_mm = 3.7; //[1.85:7.4:0.05]
filament_diameter_mm = 1.75; //[1.5:3:0.05]
filament_bore_diameter_mm = 2; //[1.8:3:0.05]
origin_z_top_face = 0; //[0:0:1]
overlap_mm = 1; //[0.5:2:0.1]
placeholder_radial_scale = 3; //[1.5:6:0.1]
mounting_interface_length_mm = 8; //[4:16:0.5]
heater_block_length_mm = 12; //[6:24:0.5]
nozzle_length_mm = 6; //[3:12:0.5]

// Hot End - complete geometry
module hot_end() {
  color("DimGray") {
    // Main barrel
    translate([0, 0, -total_length_mm/2])
      cylinder(h=total_length_mm, r=barrel_outer_diameter_mm/2, center=true, $fn=64);
    
    // Filament bore
    translate([0, 0, -total_length_mm/2])
      cylinder(h=total_length_mm + 2*overlap_mm, r=filament_bore_diameter_mm/2, center=true, $fn=64);
  }
}

// E3D Hot End Assembly - complete geometry
module e3d_hot_end_assembly() {
  color("Black") {
    // Mounting interface placeholder
    translate([0, 0, -mounting_interface_length_mm/2 + overlap_mm/2])
      cylinder(h=mounting_interface_length_mm, r=(barrel_outer_diameter_mm*placeholder_radial_scale)/2, center=true, $fn=64);
    
    // Heater block placeholder
    translate([0, 0, -total_length_mm + heater_block_length_mm/2 - overlap_mm/2])
      cylinder(h=heater_block_length_mm, r=(barrel_outer_diameter_mm*placeholder_radial_scale)/2, center=true, $fn=64);
    
    // Nozzle placeholder
    translate([0, 0, -total_length_mm - nozzle_length_mm/2 + overlap_mm/2])
      cylinder(h=nozzle_length_mm, r1=(barrel_outer_diameter_mm*placeholder_radial_scale)/2, r2=0, center=true, $fn=64);
  }
}

// E3D Hot End - complete geometry
module e3d_hot_end() {
  e3d_hot_end_assembly();
}

// Jhead Hot End Assembly - complete geometry
module jhead_hot_end_assembly() {
  color("Silver") {
    // Mounting interface placeholder
    translate([0, 0, -mounting_interface_length_mm/2 + overlap_mm/2])
      cylinder(h=mounting_interface_length_mm, r=(barrel_outer_diameter_mm*placeholder_radial_scale)/2, center=true, $fn=64);
    
    // Heater block placeholder
    translate([0, 0, -total_length_mm + heater_block_length_mm/2 - overlap_mm/2])
      cylinder(h=heater_block_length_mm, r=(barrel_outer_diameter_mm*placeholder_radial_scale)/2, center=true, $fn=64);
    
    // Nozzle placeholder
    translate([0, 0, -total_length_mm - nozzle_length_mm/2 + overlap_mm/2])
      cylinder(h=nozzle_length_mm, r1=(barrel_outer_diameter_mm*placeholder_radial_scale)/2, r2=0, center=true, $fn=64);
  }
}

// Jhead Hot End - complete geometry
module jhead_hot_end() {
  jhead_hot_end_assembly();
}

// Assembly
module assembly() {
  hot_end();
  translate([0, 0, 0]) e3d_hot_end();
  translate([0, 0, 0]) jhead_hot_end();
}

assembly();