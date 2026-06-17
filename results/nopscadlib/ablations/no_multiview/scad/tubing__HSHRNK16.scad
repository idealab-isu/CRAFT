// Parameters
length = 15; //[8:30:1]
original_id = 2; //[1:4:0.1]
original_od = 3.2; //[1.6:6.4:0.1]
forced_id = 0; //[0:6:0.1]
center = 1; //[0:1:1]
overlap = 1; //[0.5:2:0.1]

// Tubing - complete geometry
module tubing() {
  color([0.85, 0.85, 0.8]) { // Off-white for heatshrink
    difference() {
      // Outer sleeve
      translate([0, 0, (center > 0 ? 0 : length / 2)])
        cylinder(h=length, r=((original_od + (forced_id > 0 ? (forced_id - original_id) : 0)))/2, center=true);
      // Inner bore
      translate([0, 0, (center > 0 ? 0 : length / 2)])
        cylinder(h=length + 2 * overlap, r=((forced_id > 0 ? forced_id : original_id))/2, center=true);
    }
  }
}

// Sleeved Resistor - placeholder geometry
module sleeved_resistor() {
  color([0.2, 0.2, 0.2]) { // Dark color for resistor
    // Placeholder for resistor
    translate([0, 0, (center > 0 ? 0 : length / 2)])
      cylinder(h=5, r=original_id/2, center=true);
  }
}

// Assembly
module assembly() {
  tubing();
  translate([0, 0, 0]) sleeved_resistor();
}

assembly();