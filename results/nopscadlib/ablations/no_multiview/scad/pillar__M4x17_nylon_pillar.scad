// Parameters
overall_length_mm = 20; //[10:40:0.5]
outer_diameter_mm = 8; //[4:16:0.5]
thread_diameter_mm = 4; //[2:8:0.1]
thread_pitch_mm = 0.7; //[0.35:1.4:0.05]
threaded_length_mm = 20; //[5:40:0.5]
overlap_mm = 1; //[0.5:2:0.1]

// Standoff - complete geometry
module standoff() {
  color("Silver") {
    // Pillar body
    translate([0, 0, 0])
      cylinder(h=overall_length_mm, r=outer_diameter_mm/2, center=true, $fn=64);
  }
}

// Pillar - complete geometry
module pillar() {
  color("DimGray") {
    // Threaded section
    translate([0, 0, overall_length_mm/2 - threaded_length_mm/2 - overlap_mm])
      cylinder(h=threaded_length_mm, r=thread_diameter_mm/2, center=true, $fn=64);
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