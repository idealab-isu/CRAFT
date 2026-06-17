// Parameters
material = 1; //[1:1:1]
length = 15; //[8:30:1]
center = 1; //[0:1:1]
forced_id = 0; //[0:20:0.1]
path = 0; //[0:0:1]
library_od = 8; //[4:16:0.1]
library_id = 6; //[2:14:0.1]
eps_overlap = 0.5; //[0.2:2:0.1]

// Tubing - complete geometry
module tubing() {
  color([0.1, 0.1, 0.1]) { // Carbon fiber color
    difference() {
      // Outer cylinder
      cylinder(
        h = length,
        r = (library_od + (forced_id > 0 ? (forced_id - library_id) : 0)) / 2,
        center = true
      );
      // Inner void
      cylinder(
        h = length + 2 * eps_overlap,
        r = (forced_id > 0 ? forced_id : library_id) / 2,
        center = true
      );
    }
  }
}

// Assembly
module assembly() {
  tubing();
}

assembly();