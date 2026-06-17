// Parameters
length = 15; //[8:30:1]
forced_id = 0; //[0:10:1]
center = 1; //[0:1:1]
default_id = 2; //[1:6:0.5]
wall_thickness = 0.5; //[0.25:1.5:0.05]
overlap = 1; //[0.5:2:0.1]

// Tubing - complete geometry
module tubing() {
  color([0.85, 0.85, 0.8]) { // Off-white for PTFE
    difference() {
      // Outer tube
      cylinder(
        r=((forced_id > 0) ? forced_id : default_id) / 2 + wall_thickness,
        h=length,
        center=true
      );
      // Inner bore
      cylinder(
        r=((forced_id > 0) ? forced_id : default_id) / 2,
        h=length + 2 * overlap,
        center=true
      );
    }
  }
}

// Sleeved Resistor - complete geometry
module sleeved_resistor() {
  color([0.2, 0.2, 0.2]) { // Dark color for resistor body
    // Resistor body
    cylinder(r=1.5, h=5, center=true);
    // Resistor leads
    color("Silver") {
      translate([0, 0, -3]) cylinder(r=0.5, h=3, center=false);
      translate([0, 0, 2]) cylinder(r=0.5, h=3, center=false);
    }
  }
}

// Assembly
module assembly() {
  translate([0, 0, ((center > 0) ? 0 : length / 2)]) tubing();
  translate([0, 0, ((center > 0) ? 0 : length / 2) + 7.5]) sleeved_resistor();
}

assembly();