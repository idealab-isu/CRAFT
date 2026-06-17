// Parameters
length = 15; //[7.5:30:0.5]
forced_id = 0; //[0:10:0.1]
default_id = 2; //[1:4:0.1]
default_od = 3; //[1.5:6:0.1]
center = 1; //[0:1:1]
eps = 0.8; //[0.5:2:0.1]

// Tubing - complete geometry
module tubing() {
  color([0.85, 0.85, 0.8]) { // Off-white for PTFE
    difference() {
      // Outer tubing body
      translate([0, 0, ((center > 0) ? 0 : (length / 2))])
        cylinder(h=length, r=((default_od + ((forced_id > 0) ? forced_id : default_id) - default_id) / 2), center=true, $fn=64);
      
      // Inner hollow bore
      translate([0, 0, ((center > 0) ? 0 : (length / 2))])
        cylinder(h=length + 2 * eps, r=(((forced_id > 0) ? forced_id : default_id) / 2), center=true, $fn=64);
    }
  }
}

// Assembly
module assembly() {
  tubing();
}

assembly();