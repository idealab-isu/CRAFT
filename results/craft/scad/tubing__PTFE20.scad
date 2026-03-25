// Parameters
length = 15; //[8:30:1]
center = 1; //[0:1:1]
forced_id = 0; //[0:10:0.1]
type_od = 4; //[2:8:0.1]
type_id = 2; //[1:6:0.1]
id = 2; //[1:10:0.1]
od = 4; //[2:12:0.1]
eps_overlap = 0.8; //[0.5:2:0.1]
path_enabled = 0; //[0:1:1]
path_length = 15; //[8:60:1]

// Tubing - complete geometry
module tubing() {
  color([0.85, 0.85, 0.8]) { // Off-white for PTFE
    if (path_enabled == 0) {
      // Straight tubing
      difference() {
        translate([0, 0, center == 1 ? 0 : length / 2])
          cylinder(r=od/2, h=length, center=true, $fn=64);
        translate([0, 0, center == 1 ? 0 : length / 2])
          cylinder(r=id/2, h=length + 2*eps_overlap, center=true, $fn=64);
      }
    } else {
      // Path sweep placeholder
      difference() {
        translate([0, 0, 0])
          cylinder(r=od/2, h=path_length, center=true, $fn=64);
        translate([0, 0, 0])
          cylinder(r=id/2, h=path_length + 2*eps_overlap, center=true, $fn=64);
      }
    }
  }
}

// Assembly
module assembly() {
  tubing();
}

assembly();