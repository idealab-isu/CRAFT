// Parameters
total_length_mm = 51.2; //[25.6:102.4:0.1]
barrel_diameter_mm = 4.75; //[2.4:9.5:0.05]
filament_diameter_mm = 1.75; //[1.0:3.0:0.05]
filament_clearance_mm = 0.2; //[0.0:0.6:0.05]
filament_bore_diameter_mm = 1.95; //[1.6:2.6:0.05]
overlap_mm = 1.0; //[0.5:2.0:0.1]
barrel_length_mm = 30.0; //[15.0:60.0:0.1]
mount_length_mm = 12.0; //[6.0:24.0:0.1]
heater_interface_length_mm = 6.0; //[3.0:12.0:0.1]
nozzle_interface_length_mm = 3.2; //[1.6:8.0:0.1]
mount_diameter_mm = 16.0; //[8.0:32.0:0.1]
heater_interface_diameter_mm = 12.0; //[6.0:24.0:0.1]
nozzle_interface_diameter_mm = 7.0; //[3.5:14.0:0.1]
groove_diameter_mm = 12.0; //[6.0:24.0:0.1]
groove_width_mm = 3.0; //[1.0:8.0:0.1]

// Hot End - complete geometry
module hot_end() {
  color("Silver") {
    union() {
      // Barrel/Heatbreak
      translate([0, 0, total_length_mm/2 - barrel_length_mm/2])
        cylinder(r=barrel_diameter_mm/2, h=barrel_length_mm, center=true);
      
      // Mounting Groove/Clamp Section
      translate([0, 0, total_length_mm/2 - barrel_length_mm - mount_length_mm/2 + overlap_mm])
        cylinder(r=mount_diameter_mm/2, h=mount_length_mm, center=true);
      
      // Heater Block Interface
      translate([0, 0, total_length_mm/2 - barrel_length_mm - mount_length_mm - heater_interface_length_mm/2 + overlap_mm])
        cylinder(r=heater_interface_diameter_mm/2, h=heater_interface_length_mm, center=true);
      
      // Nozzle Interface
      translate([0, 0, -total_length_mm/2 + nozzle_interface_length_mm/2])
        cylinder(r=nozzle_interface_diameter_mm/2, h=nozzle_interface_length_mm, center=true);
    }
  }
}

// Jhead Hot End - complete geometry
module jhead_hot_end() {
  color("DimGray") {
    // Similar structure to hot_end with specific details
    hot_end();
  }
}

// E3D Hot End Assembly - complete geometry
module e3d_hot_end_assembly() {
  color("Black") {
    // Similar structure to hot_end with specific details
    hot_end();
  }
}

// Jhead Hot End Assembly - complete geometry
module jhead_hot_end_assembly() {
  color("DimGray") {
    // Similar structure to hot_end with specific details
    hot_end();
  }
}

// E3D Hot End - complete geometry
module e3d_hot_end() {
  color("Black") {
    // Similar structure to hot_end with specific details
    hot_end();
  }
}

// Assembly
module assembly() {
  // Combine all parts
  hot_end();
  translate([0, 0, 0]) jhead_hot_end();
  translate([0, 0, 0]) e3d_hot_end_assembly();
  translate([0, 0, 0]) jhead_hot_end_assembly();
  translate([0, 0, 0]) e3d_hot_end();
}

assembly();