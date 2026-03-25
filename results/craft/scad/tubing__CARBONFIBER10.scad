// Parameters
length = 15; //[8:60:1]
forced_id = 0; //[0:30:0.5]
center = 1; //[0:1:1]
profile_od = 10; //[5:20:0.5]
profile_id = 8; //[3:18:0.5]
eps = 0.8; //[0.2:2:0.1]
id_effective = forced_id > 0 ? forced_id : profile_id; //[0:30:0.5]
z_shift = center ? 0 : length / 2; //[-100:100:1]

// Tubing - complete geometry
module tubing() {
  color([0.15, 0.15, 0.17]) {
    difference() {
      // Outer tube
      cylinder(r=profile_od/2, h=length, center=true);
      // Inner bore
      translate([0, 0, 0])
        cylinder(r=id_effective/2, h=length + 2*eps, center=true);
    }
  }
}

// Assembly
module assembly() {
  translate([0, 0, -z_shift]) tubing();
}

assembly();