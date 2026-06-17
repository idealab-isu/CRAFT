// Parameters
length = 15; //[8:30:1]
forced_id = 0; //[0:20:1]
tubing_nominal_id = 3; //[1.5:6:0.1]
tubing_nominal_od = 5; //[2.5:10:0.1]
eps_overlap = 0.8; //[0.5:2:0.1]

// Tubing - complete detailed geometry
module tubing() {
  color([0.85, 0.85, 0.8]) { // Off-white for heatshrink
    difference() {
      // Outer cylinder
      cylinder(
        r=((forced_id > 0 ? forced_id : tubing_nominal_id) + (tubing_nominal_od - tubing_nominal_id)) / 2,
        h=length,
        center=true
      );
      // Inner cylinder
      cylinder(
        r=(forced_id > 0 ? forced_id : tubing_nominal_id) / 2,
        h=length + 2 * eps_overlap,
        center=true
      );
    }
  }
}

// Sleeved Resistor - complete detailed geometry
module sleeved_resistor() {
  color([0.2, 0.2, 0.2]) { // Dark color for resistor
    // Resistor body
    translate([0, 0, -eps_overlap/2])
      cube([eps_overlap, eps_overlap, eps_overlap], center=true);
  }
}

// Assembly
module assembly() {
  tubing();
  translate([0, 0, 0]) sleeved_resistor();
}

assembly();