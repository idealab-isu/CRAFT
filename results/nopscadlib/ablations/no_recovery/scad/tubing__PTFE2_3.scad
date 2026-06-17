// Parameters
length = 15; //[8:30:1]
center = true; //[0:1:1]
forced_id = 0; //[0:6:0.1]
ptfe_od = 4; //[2:8:0.1]
ptfe_id_nominal = 2; //[1:6:0.1]
eps_overlap = 0.8; //[0.2:2:0.1]

// Tubing - complete geometry
module tubing() {
  color([0.85, 0.85, 0.8]) { // Off-white for PTFE
    difference() {
      // Outer cylinder
      cylinder(h=length, r=ptfe_od/2, center=center);
      // Inner cylinder (cut)
      cylinder(h=length + 2*eps_overlap, r=((forced_id>0)?forced_id:ptfe_id_nominal)/2, center=center);
    }
  }
}

// Assembly
module assembly() {
  tubing();
}

assembly();