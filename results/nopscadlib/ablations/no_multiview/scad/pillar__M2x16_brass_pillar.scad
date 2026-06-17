// Parameters
thread_diameter = 2.0; //[1.0:4.0:0.05]
length = 16.0; //[8.0:32.0:0.5]
outer_diameter = 3.17; //[1.585:6.34:0.01]
thread_feature_length = 16.0; //[4.0:32.0:0.5]
thread_hole_extra = 0.2; //[0.0:0.6:0.05]
overlap = 1.0; //[0.5:2.0:0.1]

// Standoff - complete geometry
module standoff() {
  color("Silver") {
    difference() {
      // Pillar body
      cylinder(h=length, r=outer_diameter/2, center=true, $fn=64);
      // M2 thread feature (clearance hole)
      translate([0, 0, 0])
        cylinder(h=thread_feature_length + 2*overlap, r=(thread_diameter + thread_hole_extra)/2, center=true, $fn=64);
    }
  }
}

// Pillar - complete geometry
module pillar() {
  color("DimGray") {
    // Reuse standoff geometry for pillar
    standoff();
  }
}

// Assembly
module assembly() {
  // Place standoff at origin
  standoff();
  // Attach pillar to standoff (same geometry in this case)
  translate([0, 0, 0]) pillar();
}

// Final assembly call
assembly();