// Parameters
length = 15; //[8:30:1]
outer_diameter = 4; //[2:8:0.1]
inner_diameter = 2; //[0.5:6:0.1]
forced_id = 0; //[0:6:0.1]
center = 1; //[0:1:1]
eps = 0.8; //[0.2:2:0.1]

// Tubing - complete geometry
module tubing() {
  color([0.85, 0.85, 0.8]) { // PTFE-like color
    difference() {
      // Outer tube
      cylinder(h=length, r=outer_diameter/2, center=center);
      // Inner bore
      cylinder(h=length + 2*eps, r=((forced_id > 0) ? forced_id : inner_diameter)/2, center=center);
    }
  }
}

// Assembly
module assembly() {
  tubing();
}

assembly();