// Parameters
length = 15; //[8:30:1]
center = 1; //[0:1:1]
forced_id = 0; //[0:50:0.5]
od_mm = 10; //[5:20:0.5]
id_mm = 6; //[2:18:0.5]
eps = 1; //[0.5:2:0.1]

// Tubing - complete geometry
module tubing() {
  color([0.2, 0.2, 0.2]) { // Neoprene-like color
    if (center == 1) {
      difference() {
        // Outer cylinder centered
        cylinder(h=length, r=od_mm/2, center=true);
        // Inner cylinder centered
        cylinder(h=length + 2*eps, r=((forced_id > 0) ? forced_id : id_mm)/2, center=true);
      }
    } else {
      difference() {
        // Outer cylinder uncentered
        translate([0, 0, length/2])
          cylinder(h=length, r=od_mm/2, center=true);
        // Inner cylinder uncentered
        translate([0, 0, length/2])
          cylinder(h=length + 2*eps, r=((forced_id > 0) ? forced_id : id_mm)/2, center=true);
      }
    }
  }
}

// Assembly
module assembly() {
  tubing();
}

assembly();