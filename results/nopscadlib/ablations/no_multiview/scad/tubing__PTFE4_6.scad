// Parameters
length = 15; //[8:30:1]
center = 1; //[0:1:1]
forced_id = 0; //[0:10:0.1]
standard_od = 4; //[2:8:0.1]
standard_id = 2; //[1:6:0.1]
id = 2; //[1:10:0.1]
od = 4; //[2:12:0.1]
eps_overlap = 0.8; //[0.2:2:0.1]

// Tubing - complete geometry
module tubing() {
  color([0.85, 0.85, 0.8]) { // PTFE color
    if (center) {
      difference() {
        // Outer cylinder
        cylinder(r=od/2, h=length, center=true);
        // Inner cylinder
        cylinder(r=((forced_id>0)?forced_id:standard_id)/2, h=length + 2*eps_overlap, center=true);
      }
    } else {
      difference() {
        // Outer cylinder
        translate([0, 0, length/2])
          cylinder(r=od/2, h=length, center=true);
        // Inner cylinder
        translate([0, 0, length/2])
          cylinder(r=((forced_id>0)?forced_id:standard_id)/2, h=length + 2*eps_overlap, center=true);
      }
    }
  }
}

// Assembly
module assembly() {
  tubing();
}

assembly();