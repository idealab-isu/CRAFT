// Parameters
material = 0; //[0:0:1]
type = 0; //[0:10:1]
length = 15; //[8:30:1]
forced_id = 0; //[0:30:1]
center = 1; //[0:1:1]
path_enabled = 0; //[0:1:1]
type_od = 10; //[5:20:0.5]
type_id = 8; //[3:18:0.5]
id = 8; //[3:18:0.5]
od = 10; //[5:20:0.5]
eps_overlap = 0.8; //[0.2:2:0.1]
z_offset = 0; //[-50:50:1]

// Tubing - complete geometry
module tubing() {
  color([0.15, 0.15, 0.17]) {
    difference() {
      // Outer tube
      translate([0, 0, z_offset])
        cylinder(h=length, r=od/2, center=center, $fn=64);
      // Inner bore
      translate([0, 0, z_offset])
        cylinder(h=length + 2*eps_overlap, r=id/2, center=center, $fn=64);
    }
  }
}

// Assembly
module assembly() {
  tubing();
}

assembly();