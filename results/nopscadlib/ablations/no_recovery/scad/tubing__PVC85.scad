// Parameters
length = 15; //[7.5:30:0.5]
outer_diameter = 10; //[5:20:0.5]
inner_diameter = 8; //[4:16:0.5]
forced_id = 0; //[0:16:0.5]
center = 1; //[0:1:1]
overlap = 1; //[0.5:2:0.1]

// Tubing - complete geometry
module tubing() {
  color([0.85, 0.85, 0.8]) { // Off-white for PVC
    difference() {
      // Outer tube
      translate([0, 0, (center > 0) ? 0 : (length / 2)]) 
        cylinder(h=length, r=((forced_id > 0) ? (outer_diameter + forced_id - inner_diameter) : outer_diameter) / 2, center=true, $fn=64);
      
      // Inner bore
      translate([0, 0, (center > 0) ? 0 : (length / 2)]) 
        cylinder(h=length + overlap * 2, r=((forced_id > 0) ? forced_id : inner_diameter) / 2, center=true, $fn=64);
    }
  }
}

// Assembly
module assembly() {
  tubing();
}

assembly();