// Parameters
thread_diameter = 3.0; //[1.5:6.0:0.1]
overall_length = 20.0; //[10.0:40.0:0.5]
outer_diameter = 8.0; //[4.0:16.0:0.5]
threaded_length_internal = 20.0; //[5.0:40.0:0.5]
eps = 0.8; //[0.2:2.0:0.1]

// Standoff - complete geometry
module standoff() {
  color("Silver") {
    difference() {
      // Outer cylindrical body
      cylinder(h=overall_length, r=outer_diameter/2, center=true, $fn=64);
      // Internal threaded feature (modeled as a clearance hole)
      cylinder(h=threaded_length_internal + 2*eps, r=thread_diameter/2, center=true, $fn=64);
    }
  }
}

// Pillar - complete geometry (same as standoff for this example)
module pillar() {
  standoff();
}

// Assembly
module assembly() {
  standoff();
  // Additional components can be added here if needed
}

assembly();