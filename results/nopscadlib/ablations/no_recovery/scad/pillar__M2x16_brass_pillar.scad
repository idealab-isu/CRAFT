// Parameters
overall_length_mm = 16; //[8:32:0.5]
outer_diameter_mm = 3.17; //[1.6:6.4:0.01]
thread_diameter_mm = 2; //[1:4:0.01]
thread_pitch_mm = 0.4; //[0.2:0.8:0.01]
thread_length_mm = 16; //[4:32:0.5]
thread_overlap_mm = 1; //[0.5:2:0.1]

// Standoff - complete geometry
module standoff() {
  color("Silver") {
    // Pillar body
    translate([0, 0, 0])
      cylinder(h=overall_length_mm, r=outer_diameter_mm/2, center=true, $fn=32);
  }
}

// Pillar - complete geometry
module pillar() {
  color("DimGray") {
    // Threaded feature
    translate([0, 0, (overall_length_mm/2 - thread_length_mm/2) - thread_overlap_mm])
      cylinder(h=thread_length_mm, r=thread_diameter_mm/2, center=true, $fn=32);
  }
}

// Assembly
module assembly() {
  union() {
    standoff();
    pillar();
  }
}

assembly();