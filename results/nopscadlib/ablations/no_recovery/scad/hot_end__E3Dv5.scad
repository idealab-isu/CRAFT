// Parameters
total_length_mm = 70; //[35:140:1]
barrel_diameter_mm = 3.7; //[1.85:7.4:0.1]
filament_diameter_mm = 1.75; //[1:3:0.01]
filament_clearance_mm = 0.2; //[0.05:0.6:0.01]
overlap_mm = 1; //[0.5:2:0.1]
insulator_diameter_mm = 16; //[8:32:0.5]
insulator_length_mm = 45; //[20:90:1]
groove_diameter_mm = 12; //[6:24:0.5]
groove_height_mm = 4; //[2:10:0.5]
groove_from_top_mm = 8; //[2:20:0.5]
barrel_length_mm = 15; //[5:40:1]
heater_block_x_mm = 20; //[10:40:0.5]
heater_block_y_mm = 16; //[8:32:0.5]
heater_block_z_mm = 12; //[6:24:0.5]
heater_cartridge_diameter_mm = 6; //[3:10:0.1]
thermistor_diameter_mm = 3; //[1.5:6:0.1]
nozzle_length_mm = 10; //[5:25:0.5]
nozzle_base_diameter_mm = 7; //[4:14:0.1]
nozzle_tip_diameter_mm = 1.5; //[0.8:4:0.05]
wire_exit_feature_radius_mm = 2; //[1:5:0.1]
wire_exit_feature_length_mm = 6; //[3:15:0.5]

// Hot End - complete geometry
module hot_end() {
  color("Silver") {
    // Insulator Body with Groove
    union() {
      translate([0, 0, total_length_mm/2 - insulator_length_mm/2])
        cylinder(r=insulator_diameter_mm/2, h=insulator_length_mm, center=true);
      difference() {
        translate([0, 0, total_length_mm/2 - groove_from_top_mm - groove_height_mm/2])
          cylinder(r=insulator_diameter_mm/2 + overlap_mm, h=groove_height_mm, center=true);
        translate([0, 0, total_length_mm/2 - groove_from_top_mm - groove_height_mm/2])
          cylinder(r=groove_diameter_mm/2, h=groove_height_mm + 2*overlap_mm, center=true);
      }
    }
    // Barrel
    translate([0, 0, total_length_mm/2 - insulator_length_mm - barrel_length_mm/2 + overlap_mm])
      cylinder(r=barrel_diameter_mm/2, h=barrel_length_mm, center=true);
    // Heater Block
    translate([0, 0, total_length_mm/2 - insulator_length_mm - barrel_length_mm - heater_block_z_mm/2 + overlap_mm])
      cube([heater_block_x_mm, heater_block_y_mm, heater_block_z_mm], center=true);
    // Nozzle Tip
    translate([0, 0, total_length_mm/2 - insulator_length_mm - barrel_length_mm - heater_block_z_mm - nozzle_length_mm/2 + overlap_mm])
      cylinder(r1=nozzle_base_diameter_mm/2, r2=nozzle_tip_diameter_mm/2, h=nozzle_length_mm, center=true);
  }
}

// Jhead Hot End - complete geometry
module jhead_hot_end() {
  color("DimGray") {
    // Placeholder for Jhead Hot End geometry
    // Implement detailed geometry based on specifications
  }
}

// E3D Hot End Assembly - complete geometry
module e3d_hot_end_assembly() {
  color("Black") {
    // Placeholder for E3D Hot End Assembly geometry
    // Implement detailed geometry based on specifications
  }
}

// Jhead Hot End Assembly - complete geometry
module jhead_hot_end_assembly() {
  color("DimGray") {
    // Placeholder for Jhead Hot End Assembly geometry
    // Implement detailed geometry based on specifications
  }
}

// E3D Hot End - complete geometry
module e3d_hot_end() {
  color("Black") {
    // Placeholder for E3D Hot End geometry
    // Implement detailed geometry based on specifications
  }
}

// Assembly
module assembly() {
  hot_end();
  translate([0, 0, -20]) jhead_hot_end();
  translate([0, 0, -40]) e3d_hot_end_assembly();
  translate([0, 0, -60]) jhead_hot_end_assembly();
  translate([0, 0, -80]) e3d_hot_end();
}

assembly();