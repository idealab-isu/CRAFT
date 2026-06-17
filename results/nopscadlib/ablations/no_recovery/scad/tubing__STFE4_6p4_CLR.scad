// Parameters
length = 15; //[8:30:1]
center = 1; //[0:1:1]
forced_id = 0; //[0:10:1]
default_id = 2; //[1:6:0.5]
wall_thickness = 0.3; //[0.15:0.8:0.05]
overlap = 1; //[0.5:2:0.1]

// Tubing - complete geometry
module tubing() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      // Outer tube
      translate([0, 0, (center > 0 ? 0 : length / 2)])
        cylinder(h=length, r=((forced_id > 0 ? forced_id : default_id) / 2) + wall_thickness, center=true, $fn=64);
      // Inner bore
      translate([0, 0, (center > 0 ? 0 : length / 2)])
        cylinder(h=length + 2 * overlap, r=((forced_id > 0 ? forced_id : default_id) / 2), center=true, $fn=64);
    }
  }
}

// Sleeved Resistor - complete geometry
module sleeved_resistor() {
  color([0.2, 0.2, 0.2]) {
    // Resistor body
    translate([0, 0, (center > 0 ? 0 : length / 2)])
      cylinder(h=5, r=1, center=true, $fn=32);
    // Leads
    translate([0, 0, (center > 0 ? 0 : length / 2) - 2.5])
      cylinder(h=10, r=0.5, center=true, $fn=16);
  }
}

// Assembly
module assembly() {
  tubing();
  sleeved_resistor();
}

assembly();