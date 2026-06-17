// Parameters
total_length_mm = 51.2; //[25.6:102.4:0.1]
barrel_diameter_mm = 4.75; //[2.4:9.5:0.05]
filament_diameter_mm = 1.75; //[1.0:3.0:0.05]
filament_clearance_mm = 0.2; //[0.0:0.6:0.05]
filament_bore_diameter_mm = 1.95; //[1.2:3.5:0.05]
mount_diameter_mm = 12; //[6:24:0.1]
mount_height_mm = 6; //[3:12:0.1]
nozzle_tip_diameter_mm = 6; //[3:12:0.1]
nozzle_tip_height_mm = 8; //[4:16:0.1]
connection_overlap_mm = 1; //[0.5:2:0.1]
bore_extra_length_mm = 2; //[1:6:0.1]

// Hot End - complete geometry
module hot_end() {
  color("DimGray") {
    // Main cylindrical barrel
    translate([0, 0, -total_length_mm/2])
      cylinder(r=barrel_diameter_mm/2, h=total_length_mm, center=true);
  }
}

// E3D Hot End Assembly - complete geometry
module e3d_hot_end_assembly() {
  color("Silver") {
    // Mounting interface placeholder
    translate([0, 0, -mount_height_mm/2 + connection_overlap_mm/2])
      cylinder(r=mount_diameter_mm/2, h=mount_height_mm, center=true);
  }
}

// E3D Hot End - complete geometry
module e3d_hot_end() {
  color("Black") {
    // Nozzle/tip placeholder
    translate([0, 0, -total_length_mm + nozzle_tip_height_mm/2 - connection_overlap_mm/2])
      cylinder(r1=nozzle_tip_diameter_mm/2, r2=0, h=nozzle_tip_height_mm, center=true);
  }
}

// Jhead Hot End Assembly - complete geometry
module jhead_hot_end_assembly() {
  color("Silver") {
    // Mounting interface placeholder
    translate([0, 0, -mount_height_mm/2 + connection_overlap_mm/2])
      cylinder(r=mount_diameter_mm/2, h=mount_height_mm, center=true);
  }
}

// Jhead Hot End - complete geometry
module jhead_hot_end() {
  color("Black") {
    // Nozzle/tip placeholder
    translate([0, 0, -total_length_mm + nozzle_tip_height_mm/2 - connection_overlap_mm/2])
      cylinder(r1=nozzle_tip_diameter_mm/2, r2=0, h=nozzle_tip_height_mm, center=true);
  }
}

// Assembly
module assembly() {
  union() {
    hot_end();
    e3d_hot_end_assembly();
    e3d_hot_end();
    jhead_hot_end_assembly();
    jhead_hot_end();
  }
}

assembly();