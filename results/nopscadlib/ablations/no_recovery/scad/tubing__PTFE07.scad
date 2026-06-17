// Parameters
length = 15; //[8:30:1]
center = 1; //[0:1:1]
forced_id = 0; //[0:20:1]
ptfe_nominal_od = 4; //[2:8:0.5]
ptfe_nominal_id = 2; //[1:6:0.5]
eps = 0.8; //[0.2:2:0.1]

// Tubing - complete geometry
module tubing() {
  color([0.85, 0.85, 0.8]) { // Off-white for PTFE
    difference() {
      // Outer cylinder
      translate([0, 0, center * 0 + (1 - center) * (length / 2)])
        cylinder(r=ptfe_nominal_od / 2, h=length + 2 * eps, center=true);
      // Inner cylinder
      translate([0, 0, center * 0 + (1 - center) * (length / 2)])
        cylinder(r=(forced_id > 0 ? forced_id : ptfe_nominal_id) / 2, h=length + 4 * eps, center=true);
    }
  }
}

// Assembly
module assembly() {
  tubing();
}

assembly();