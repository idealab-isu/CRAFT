// Parameters
length = 15; //[8:30:1]
center = 1; //[0:1:1]
forced_id = 0; //[0:10:0.1]
default_id = 2; //[1:6:0.1]
wall_thickness = 0.5; //[0.25:1.5:0.05]
eps_overlap = 0.8; //[0.5:2:0.1]

// Tubing - complete geometry
module tubing() {
  color([0.85, 0.85, 0.8]) { // Off-white for PTFE
    difference() {
      // Outer tube
      cylinder(h=length, r=((forced_id > 0 ? forced_id : default_id) / 2) + wall_thickness, center=center);
      // Inner bore
      cylinder(h=length + 2 * eps_overlap, r=(forced_id > 0 ? forced_id : default_id) / 2, center=center);
    }
  }
}

// Sleeved Resistor - complete geometry
module sleeved_resistor() {
  color([0.2, 0.2, 0.2]) { // Dark color for resistor
    // Resistor body
    cylinder(h=5, r=1.5, center=true); // Assuming a small resistor
    // Leads
    translate([0, 0, -5]) cylinder(h=10, r=0.5, center=false); // Lead on one side
    translate([0, 0, 5]) cylinder(h=10, r=0.5, center=false); // Lead on the other side
  }
}

// Assembly
module assembly() {
  translate([0, 0, center ? 0 : length / 2]) tubing();
  translate([0, 0, center ? 0 : length / 2]) sleeved_resistor();
}

assembly();