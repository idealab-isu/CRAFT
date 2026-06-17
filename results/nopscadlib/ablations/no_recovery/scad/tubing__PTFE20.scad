// Parameters
length = 15; //[8:30:1]
forced_id = 0; //[0:10:0.1]
center = 1; //[0:1:1]
default_id = 2; //[1:4:0.1]
default_od = 4; //[2:8:0.1]
id = forced_id > 0 ? forced_id : default_id; //[1:10:0.1]
od = default_od; //[2:12:0.1]
overlap = 1; //[0.5:2:0.1]
z_center_offset = center ? 0 : length / 2; //[-50:50:0.1]

// Tubing - complete geometry
module tubing() {
  color([0.85, 0.85, 0.8]) { // Off-white for PTFE
    difference() {
      // Outer tube
      translate([0, 0, z_center_offset])
        cylinder(h=length, r=od/2, center=true, $fn=64);
      // Inner bore
      translate([0, 0, z_center_offset])
        cylinder(h=length + 2*overlap, r=id/2, center=true, $fn=64);
    }
  }
}

// Assembly
module assembly() {
  tubing();
}

assembly();