// Parameters
length = 15; //[8:30:1]
forced_id = 0; //[0:10:0.5]
center = true; //[0:1:1]
original_id = 2; //[1:4:0.5]
original_od = 3.2; //[1.6:6.4:0.1]
id = forced_id > 0 ? forced_id : original_id; //[1:4:0.5]
od = original_od; //[1.6:6.4:0.1]
eps_overlap = 0.8; //[0.2:2:0.1]

// Tubing - complete geometry
module tubing() {
  color([0.85, 0.85, 0.8]) { // Off-white for heatshrink
    difference() {
      // Outer cylinder
      cylinder(h=length, r=od/2, center=center, $fn=64);
      // Inner cylinder
      cylinder(h=length + 2*eps_overlap, r=id/2, center=center, $fn=64);
    }
  }
}

// Sleeved Resistor - complete geometry
module sleeved_resistor() {
  color([0.2, 0.2, 0.2]) { // Dark color for resistor
    // Resistor body
    cylinder(h=5, r=1, center=true, $fn=32);
    // Leads
    translate([0, 0, -3]) cylinder(h=6, r=0.3, center=true, $fn=16);
  }
}

// Assembly
module assembly() {
  tubing();
  translate([0, 0, 0]) sleeved_resistor();
}

assembly();