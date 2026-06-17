// Parameters
length = 15; //[8:30:1]
forced_id = 0; //[0:10:0.1]
center = 1; //[0:1:1]
tubing_od = 4; //[2:8:0.1]
tubing_id = 2; //[1:6:0.1]
eps_overlap = 0.5; //[0.1:2:0.1]

// Tubing - complete geometry
module tubing() {
  color([0.85, 0.85, 0.8]) { // Off-white for PTFE
    difference() {
      // Outer cylinder
      cylinder(h=length, r=tubing_od/2, center=true);
      // Inner cylinder
      cylinder(h=length + 2*eps_overlap, r=(forced_id > 0 ? forced_id : tubing_id)/2, center=true);
    }
  }
}

// Assembly
module assembly() {
  translate([0, 0, (center == 1) ? 0 : (length/2)]) tubing();
}

assembly();