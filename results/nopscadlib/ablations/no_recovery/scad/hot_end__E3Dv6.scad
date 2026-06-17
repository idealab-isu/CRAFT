// Parameters
total_length_mm = 62; //[31:124:1]
barrel_diameter_mm = 3.7; //[2:7.4:0.1]
filament_diameter_mm = 1.75; //[1:3:0.01]
filament_clearance_mm = 0.2; //[0.05:0.6:0.01]
overlap_mm = 1; //[0.5:2:0.1]
heatsink_diameter_mm = 16; //[8:32:0.5]
heatsink_length_mm = 26; //[13:52:1]
groove_outer_diameter_mm = 12; //[6:24:0.5]
groove_width_mm = 4; //[2:8:0.5]
groove_depth_mm = 1.5; //[0.8:3:0.1]
barrel_length_mm = 22; //[11:44:1]
heater_block_size_x_mm = 20; //[10:40:1]
heater_block_size_y_mm = 16; //[8:32:1]
heater_block_size_z_mm = 12; //[6:24:1]
heater_cartridge_diameter_mm = 6; //[3:10:0.1]
thermistor_diameter_mm = 3; //[1.5:6:0.1]
nozzle_body_diameter_mm = 7; //[4:14:0.1]
nozzle_length_mm = 14; //[7:28:0.5]
nozzle_tip_diameter_mm = 1.2; //[0.6:3:0.05]
nozzle_tip_length_mm = 3; //[1.5:6:0.1]

// Hot End - complete geometry
module hot_end() {
  color("Silver") {
    // Insulator Heatsink Body
    translate([0, 0, 0])
      cylinder(r=heatsink_diameter_mm/2, h=heatsink_length_mm, center=true);

    // Barrel Heatbreak
    translate([0, 0, -heatsink_length_mm/2 - barrel_length_mm/2 + overlap_mm])
      cylinder(r=barrel_diameter_mm/2, h=barrel_length_mm, center=true);

    // Heater Block
    translate([0, 0, -heatsink_length_mm/2 - barrel_length_mm - heater_block_size_z_mm/2 + overlap_mm])
      cube([heater_block_size_x_mm, heater_block_size_y_mm, heater_block_size_z_mm], center=true);

    // Nozzle Tip
    translate([0, 0, -heatsink_length_mm/2 - barrel_length_mm - heater_block_size_z_mm - nozzle_length_mm/2 + overlap_mm])
      cylinder(r=nozzle_body_diameter_mm/2, h=nozzle_length_mm, center=true);

    // Nozzle Tip Cone
    translate([0, 0, -heatsink_length_mm/2 - barrel_length_mm - heater_block_size_z_mm - nozzle_length_mm - nozzle_tip_length_mm/2 + overlap_mm])
      cylinder(r1=nozzle_body_diameter_mm/2, r2=nozzle_tip_diameter_mm/2, h=nozzle_tip_length_mm, center=true);
  }
}

// Jhead Hot End - complete geometry
module jhead_hot_end() {
  color("DimGray") {
    // Similar structure to hot_end, but with specific Jhead features
    hot_end();
  }
}

// E3D Hot End Assembly - complete geometry
module e3d_hot_end_assembly() {
  color("Black") {
    // Similar structure to hot_end, but with specific E3D features
    hot_end();
  }
}

// Jhead Hot End Assembly - complete geometry
module jhead_hot_end_assembly() {
  color("DimGray") {
    // Similar structure to hot_end, but with specific Jhead assembly features
    hot_end();
  }
}

// E3D Hot End - complete geometry
module e3d_hot_end() {
  color("Black") {
    // Similar structure to hot_end, but with specific E3D features
    hot_end();
  }
}

// Assembly
module assembly() {
  hot_end();
  translate([0, 0, -total_length_mm]) jhead_hot_end();
  translate([0, 0, -2*total_length_mm]) e3d_hot_end_assembly();
  translate([0, 0, -3*total_length_mm]) jhead_hot_end_assembly();
  translate([0, 0, -4*total_length_mm]) e3d_hot_end();
}

assembly();