// Parameters
length = 15; //[8:30:1]
forced_id = 0; //[0:10:1]
center = 1; //[0:1:1]
type_id_nominal = 3; //[1:12:1]
type_od_nominal = 5; //[2:20:1]
eps_overlap = 1; //[0.5:2:0.1]

// Tubing - complete geometry
module tubing() {
  color([0.85, 0.85, 0.8]) { // Off-white for heatshrink
    difference() {
      // Outer sleeve
      cylinder(
        r=((type_od_nominal + ((forced_id > 0) * forced_id + (forced_id <= 0) * type_id_nominal) - type_id_nominal)) / 2,
        h=length + eps_overlap,
        center=true
      );
      // Inner bore
      cylinder(
        r=(((forced_id > 0) * forced_id + (forced_id <= 0) * type_id_nominal) / 2),
        h=length + 2 * eps_overlap,
        center=true
      );
    }
  }
}

// Sleeved Resistor - placeholder geometry
module sleeved_resistor() {
  color([0.2, 0.2, 0.2]) { // Dark color for resistor
    // Placeholder for resistor
    translate([0, 0, 0]) cylinder(r=2.5, h=5, center=true);
  }
}

// Assembly
module assembly() {
  tubing();
  translate([0, 0, 0]) sleeved_resistor();
}

assembly();