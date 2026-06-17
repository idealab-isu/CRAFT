// Parameters
length = 15; //[7.5:30:0.5]
outer_diameter = 4; //[2:8:0.1]
inner_diameter = 2; //[1:6:0.1]
forced_id = 0; //[0:6:0.1]
center = 1; //[0:1:1]
eps_overlap = 0.5; //[0.2:2:0.1]

// PTFE Tubing - complete geometry
module tubing() {
  color([0.85, 0.85, 0.8]) { // Off-white for PTFE
    difference() {
      // Outer tube
      translate([0, 0, center == 1 ? 0 : length / 2])
        cylinder(h=length, r=outer_diameter / 2, center=true, $fn=64);
      
      // Inner bore
      translate([0, 0, center == 1 ? 0 : length / 2])
        cylinder(h=length + 2 * eps_overlap, r=(forced_id > 0 ? forced_id : inner_diameter) / 2, center=true, $fn=64);
    }
  }
}

// Assembly
module assembly() {
  tubing();
}

assembly();