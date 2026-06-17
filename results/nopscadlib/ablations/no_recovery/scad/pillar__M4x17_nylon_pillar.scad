// Parameters
overall_length_mm = 20; //[10:40:1]
outer_diameter_mm = 8; //[4:16:0.5]
thread_diameter_mm = 4; //[2:8:0.25]
thread_length_mm = 20; //[5:40:1]
overlap_mm = 1; //[0.5:2:0.1]

// Standoff - complete geometry
module standoff() {
  color("Silver") {
    // Main body
    cylinder(h=overall_length_mm, r=outer_diameter_mm/2, center=true, $fn=64);
  }
}

// Pillar - complete geometry
module pillar() {
  color("DimGray") {
    // Threaded feature
    cylinder(h=thread_length_mm + overlap_mm, r=thread_diameter_mm/2, center=true, $fn=64);
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