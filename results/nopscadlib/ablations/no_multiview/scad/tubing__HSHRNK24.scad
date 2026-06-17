// Parameters
length = 15; //[8:30:1]
original_id = 2.0; //[1.0:4.0:0.1]
original_od = 3.2; //[1.6:6.4:0.1]
forced_id = 0; //[0:6:0.1]
center = 1; //[0:1:1]
eps_overlap = 0.8; //[0.5:2:0.1]
id = 2.0; //[1.0:6.0:0.1]
od = 3.2; //[1.6:10.0:0.1]
z_center_offset = 0; //[-50:50:0.5]

// Tubing - complete geometry
module tubing() {
  color([0.85, 0.85, 0.8]) { // Off-white for heatshrink
    difference() {
      translate([0, 0, z_center_offset])
        cylinder(h=length, r=od/2, center=center);
      translate([0, 0, z_center_offset])
        cylinder(h=length + 2*eps_overlap, r=id/2, center=center);
    }
  }
}

// Sleeved Resistor - complete geometry
module sleeved_resistor() {
  color([0.2, 0.2, 0.2]) { // Dark color for resistor
    translate([0, 0, z_center_offset])
      cylinder(h=5, r=original_id/2, center=center); // Bare resistor
  }
}

// Assembly
module assembly() {
  tubing();
  translate([0, 0, 0]) sleeved_resistor(); // Align resistor with tubing
}

assembly();