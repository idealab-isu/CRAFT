// Parameters
length = 15; //[8:30:1]
center = 1; //[0:1:1]
forced_id = 0; //[0:10:0.1]
type_od = 4; //[2:8:0.1]
type_id = 2; //[1:6:0.1]
eps = 0.5; //[0.2:2:0.1]

// Tubing - complete geometry
module tubing() {
  color([0.85, 0.85, 0.8]) { // PTFE color
    difference() {
      // Outer cylinder
      cylinder(
        h = length,
        r = (type_od + (forced_id > 0 ? (forced_id - type_id) : 0)) / 2,
        center = center
      );
      // Inner cylinder (cutout)
      translate([0, 0, -eps]) // Adjust for epsilon
        cylinder(
          h = length + 2 * eps,
          r = (forced_id > 0 ? forced_id : type_id) / 2,
          center = center
        );
    }
  }
}

// Assembly
module assembly() {
  if (center == 1) {
    tubing();
  } else {
    translate([0, 0, length / 2]) tubing();
  }
}

assembly();