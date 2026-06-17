// Parameters
length = 15; //[8:60:1]
outer_diameter = 4; //[2:12:0.1]
inner_diameter = 2; //[1:10:0.1]
center = 1; //[0:1:1]
forced_id = 0; //[0:10:0.1]

// Tubing - complete geometry
module tubing() {
  color([0.85, 0.85, 0.8]) { // Off-white for PTFE
    difference() {
      // Outer cylinder
      cylinder(h=length, r=outer_diameter/2, center=true);
      // Inner bore
      cylinder(h=length, r=((forced_id > 0) ? forced_id : inner_diameter) / 2, center=true);
    }
  }
}

// Assembly
module assembly() {
  translate([0, 0, ((center >= 0.5) ? 0 : (length / 2))]) tubing();
}

assembly();