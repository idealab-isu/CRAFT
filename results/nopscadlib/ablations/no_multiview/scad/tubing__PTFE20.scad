// Parameters
tubing_type = 0; //[0:10:1]
length = 15; //[8:30:1]
forced_id = 0; //[0:20:1]
center = 1; //[0:1:1]
od = 6; //[3:12:0.5]
id = 4; //[1.5:10:0.5]
eps_overlap = 0.8; //[0.5:2:0.1]
path_len = 0; //[0:1:1]

// Tubing - complete geometry
module tubing() {
  color([0.85, 0.85, 0.8]) { // Off-white for PTFE
    difference() {
      // Outer cylinder
      cylinder(h=length, r=od/2, center=center);
      // Inner cylinder
      translate([0, 0, -eps_overlap])
        cylinder(h=length + 2*eps_overlap, r=id/2, center=center);
    }
  }
}

// Assembly
module assembly() {
  tubing();
}

assembly();