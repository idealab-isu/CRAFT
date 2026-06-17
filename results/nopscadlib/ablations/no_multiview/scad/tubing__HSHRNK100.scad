// Parameters
length = 15; //[8:30:1]
center = true; //[0:1:1]
original_id = 3; //[1.5:6:0.1]
original_od = 5; //[2.5:10:0.1]
id = 3; //[1.5:20:0.1]
od = 5; //[2.5:30:0.1]

// Tubing - complete geometry
module tubing() {
  color([0.85, 0.85, 0.8]) { // Off-white for heatshrink
    difference() {
      cylinder(h=length, r=od/2, center=center, $fn=64);
      cylinder(h=length, r=id/2, center=center, $fn=64);
    }
  }
}

// Sleeved Resistor - complete geometry
module sleeved_resistor() {
  color([0.2, 0.2, 0.2]) { // Dark color for resistor body
    // Resistor body
    cylinder(h=5, r=1.5, center=true, $fn=32);
    // Leads
    translate([0, 0, -5/2-5]) cylinder(h=5, r=0.5, center=false, $fn=16);
    translate([0, 0, 5/2]) cylinder(h=5, r=0.5, center=false, $fn=16);
  }
}

// Assembly
module assembly() {
  tubing();
  translate([0, 0, 0]) sleeved_resistor();
}

assembly();