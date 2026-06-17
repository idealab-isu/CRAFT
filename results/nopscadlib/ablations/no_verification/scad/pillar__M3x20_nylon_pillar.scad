// Parameters
thread_diameter_mm = 3.0; //[1.5:6.0:0.1]
length_mm = 20.0; //[10.0:40.0:0.5]
outer_diameter_mm = 8.0; //[4.0:16.0:0.5]
threaded_length_mm = 20.0; //[5.0:40.0:0.5]
eps_mm = 0.8; //[0.2:2.0:0.1]

// Pillar - complete geometry
module pillar() {
  color("Silver") {
    // Body
    cylinder(h=length_mm, r=outer_diameter_mm/2, center=true, $fn=64);
  }
}

// Standoff - complete geometry
module standoff() {
  color("DimGray") {
    difference() {
      // Outer body
      pillar();
      // Threaded feature (hole)
      cylinder(h=threaded_length_mm + 2*eps_mm, r=thread_diameter_mm/2, center=true, $fn=64);
    }
  }
}

// Assembly
module assembly() {
  standoff();
}

assembly();