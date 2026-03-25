// Parameters
length = 15; //[5:60:1]
forced_id = 0; //[0:10:0.1]
center = true; //[0:1:1]
od = 4; //[2:12:0.1]
id_nominal = 2; //[1:10:0.1]
overlap = 1; //[0.5:2:0.1]

// Tubing - complete geometry
module tubing() {
  color([0.85, 0.85, 0.8]) { // Off-white for PTFE
    difference() {
      // Outer tube
      cylinder(r=od/2, h=length, center=center, $fn=64);
      // Inner bore
      cylinder(r=((forced_id > 0) ? forced_id : id_nominal) / 2, h=length + 2 * overlap, center=center, $fn=64);
    }
  }
}

// Assembly
module assembly() {
  tubing();
}

assembly();