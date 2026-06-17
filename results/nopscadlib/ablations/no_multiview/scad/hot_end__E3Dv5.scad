// Parameters
total_length_mm = 70; //[35:140:1]
barrel_diameter_mm = 3.7; //[1.85:7.4:0.05]
filament_diameter_mm = 1.75; //[1.5:3:0.05]
filament_bore_clearance_mm = 0.2; //[0.05:0.6:0.05]
filament_bore_diameter_mm = 1.95; //[1.6:3.2:0.05]
default_wall_thickness_mm = 0.9; //[0.45:1.8:0.05]
connect_overlap_mm = 1; //[0.5:2:0.1]
mount_length_mm = 10; //[5:20:1]
mount_diameter_mm = 12; //[6:24:0.5]
nozzle_length_mm = 12; //[6:24:1]
nozzle_tip_diameter_mm = 1; //[0.4:3:0.05]
heater_block_size_x_mm = 20; //[10:40:1]
heater_block_size_y_mm = 16; //[8:32:1]
heater_block_size_z_mm = 12; //[6:24:1]
heater_block_center_z_mm = -20; //[-50:0:1]

// Hot End - complete geometry
module hot_end() {
  color("DimGray") {
    // Barrel
    cylinder(h=total_length_mm, r=barrel_diameter_mm/2, center=true);
    // Filament Bore
    color("White")
    translate([0, 0, 0])
      cylinder(h=total_length_mm + mount_length_mm + nozzle_length_mm + 2*connect_overlap_mm, 
               r=filament_bore_diameter_mm/2, center=true);
  }
}

// E3D Hot End Assembly - complete geometry
module e3d_hot_end_assembly() {
  color("Black") {
    // Mount Interface
    translate([0, 0, total_length_mm/2 + mount_length_mm/2 - connect_overlap_mm])
      cylinder(h=mount_length_mm, r=mount_diameter_mm/2, center=true);
    // Nozzle
    translate([0, 0, -total_length_mm/2 - nozzle_length_mm/2 + connect_overlap_mm])
      cylinder(h=nozzle_length_mm, r1=barrel_diameter_mm/2 + default_wall_thickness_mm, 
               r2=nozzle_tip_diameter_mm/2, center=true);
    // Heater Block
    translate([0, 0, heater_block_center_z_mm])
      cube([heater_block_size_x_mm, heater_block_size_y_mm, heater_block_size_z_mm], center=true);
  }
}

// E3D Hot End - complete geometry
module e3d_hot_end() {
  hot_end();
  e3d_hot_end_assembly();
}

// Jhead Hot End Assembly - complete geometry
module jhead_hot_end_assembly() {
  color("Silver") {
    // Placeholder for Jhead specific geometry
    // This can be expanded with more detailed geometry if needed
    translate([0, 0, heater_block_center_z_mm])
      cube([heater_block_size_x_mm, heater_block_size_y_mm, heater_block_size_z_mm], center=true);
  }
}

// Jhead Hot End - complete geometry
module jhead_hot_end() {
  hot_end();
  jhead_hot_end_assembly();
}

// Assembly
module assembly() {
  e3d_hot_end();
  translate([0, 0, -total_length_mm - 10]) jhead_hot_end();
}

assembly();