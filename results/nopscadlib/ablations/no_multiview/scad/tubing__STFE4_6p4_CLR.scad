// Parameters
length = 15; //[8:30:1]
forced_id = 0; //[0:10:1]
center = 1; //[0:1:1]
original_id = 2; //[1:4:0.1]
original_od = 3; //[1.5:6:0.1]
id = 2; //[1:6:0.1]
od = 3; //[1.5:10:0.1]
eps_overlap = 0.8; //[0.2:2:0.1]

// Tubing - complete geometry
module tubing() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      cylinder(h=length, r=od/2, center=center);
      translate([0, 0, 0])
        cylinder(h=length + 2*eps_overlap, r=id/2, center=center);
    }
  }
}

// Sleeved Resistor - complete geometry
module sleeved_resistor() {
  color([0.2, 0.2, 0.2]) {
    // Resistor body
    translate([0, 0, -2.5])
      cylinder(h=5, r=1.5, center=true);
    // Leads
    translate([0, 0, -7.5])
      cylinder(h=5, r=0.5, center=false);
    translate([0, 0, 2.5])
      cylinder(h=5, r=0.5, center=false);
  }
}

// Assembly
module assembly() {
  tubing();
  translate([0, 0, 0])
    sleeved_resistor();
}

assembly();