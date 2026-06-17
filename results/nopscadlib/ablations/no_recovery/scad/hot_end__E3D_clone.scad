// Parameters
total_length_mm = 66; //[33:132:1]
barrel_diameter_mm = 6.8; //[3.4:13.6:0.1]
filament_diameter_mm = 1.75; //[1:3:0.05]
filament_clearance_mm = 0.2; //[0:0.6:0.05]
overlap_mm = 1; //[0.5:2:0.1]
insulator_diameter_mm = 16; //[8:32:0.5]
insulator_length_mm = 30; //[15:60:1]
heater_block_size_x_mm = 20; //[10:40:1]
heater_block_size_y_mm = 16; //[8:32:1]
heater_block_size_z_mm = 12; //[6:24:1]
nozzle_tip_length_mm = 6; //[3:12:0.5]
nozzle_tip_diameter_mm = 8; //[4:16:0.5]
barrel_length_mm = 36; //[18:72:1]

// Hot End - complete geometry
module hot_end() {
  color("DimGray") {
    // Insulator Body
    translate([0, 0, total_length_mm/2 - insulator_length_mm/2])
      cylinder(r=insulator_diameter_mm/2, h=insulator_length_mm, center=true, $fn=64);
    
    // Barrel
    translate([0, 0, -(total_length_mm/2 - (total_length_mm - insulator_length_mm + overlap_mm)/2) + overlap_mm/2])
      cylinder(r=barrel_diameter_mm/2, h=total_length_mm - insulator_length_mm + overlap_mm, center=true, $fn=64);
    
    // Heater Block Interface
    translate([0, 0, -total_length_mm/2 + heater_block_size_z_mm/2 + overlap_mm])
      cube([heater_block_size_x_mm, heater_block_size_y_mm, heater_block_size_z_mm], center=true);
    
    // Nozzle Tip
    translate([0, 0, -total_length_mm/2 - nozzle_tip_length_mm/2 + overlap_mm])
      rotate([180, 0, 0])
      cylinder(r1=nozzle_tip_diameter_mm/2, r2=0, h=nozzle_tip_length_mm, center=true, $fn=64);
  }
}

// Jhead Hot End - complete geometry
module jhead_hot_end() {
  color("Black") {
    // Reuse hot_end geometry for simplicity
    hot_end();
  }
}

// E3D Hot End Assembly - complete geometry
module e3d_hot_end_assembly() {
  color("Silver") {
    // Reuse hot_end geometry for simplicity
    hot_end();
  }
}

// Jhead Hot End Assembly - complete geometry
module jhead_hot_end_assembly() {
  color("Black") {
    // Reuse jhead_hot_end geometry for simplicity
    jhead_hot_end();
  }
}

// E3D Hot End - complete geometry
module e3d_hot_end() {
  color("Silver") {
    // Reuse hot_end geometry for simplicity
    hot_end();
  }
}

// Assembly
module assembly() {
  difference() {
    union() {
      hot_end();
      jhead_hot_end();
      e3d_hot_end_assembly();
      jhead_hot_end_assembly();
      e3d_hot_end();
    }
    // Filament Bore
    translate([0, 0, 0])
      cylinder(r=(filament_diameter_mm + filament_clearance_mm)/2, h=total_length_mm + 2*overlap_mm, center=true, $fn=64);
  }
}

assembly();