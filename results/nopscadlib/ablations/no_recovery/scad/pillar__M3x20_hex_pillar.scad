// Parameters
thread_diameter_mm = 3.0; //[1.5:6.0:0.1]
length_mm = 20.0; //[10.0:40.0:0.5]
outer_diameter_mm = 6.0; //[3.5:12.0:0.5]
threaded_length_top_mm = 6.0; //[0.0:20.0:0.5]
threaded_length_bottom_mm = 0.0; //[0.0:20.0:0.5]
overlap_mm = 1.0; //[0.5:2.0:0.1]

// Standoff - complete geometry
module standoff() {
  color("Silver") {
    // Main body
    cylinder(h=length_mm, r=outer_diameter_mm/2, center=true);
  }
}

// Pillar - complete geometry
module pillar() {
  color("DimGray") {
    // Top threaded section
    translate([0, 0, length_mm/2 + threaded_length_top_mm/2 - overlap_mm])
      cylinder(h=threaded_length_top_mm, r=thread_diameter_mm/2, center=true);
    
    // Bottom threaded section
    translate([0, 0, -(length_mm/2 + threaded_length_bottom_mm/2 - overlap_mm)])
      cylinder(h=threaded_length_bottom_mm, r=thread_diameter_mm/2, center=true);
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