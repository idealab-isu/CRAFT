// Parameters
thread_diameter_mm = 3.0; //[1.5:6.0:0.1]
length_mm = 13.0; //[6.5:26.0:0.5]
outer_diameter_mm = 6.0; //[3.5:12.0:0.5]
top_thread_length_mm = 13.0; //[3.0:13.0:0.5]
bottom_thread_length_mm = 0.0; //[0.0:13.0:0.5]
overlap_mm = 1.0; //[0.5:2.0:0.1]

// Standoff - complete geometry
module standoff() {
  color("Silver") {
    // Main body
    cylinder(h=length_mm, r=outer_diameter_mm/2, center=true);
    
    // Top threaded interface
    translate([0, 0, (length_mm/2 - top_thread_length_mm/2) - overlap_mm/2])
      cylinder(h=top_thread_length_mm, r=thread_diameter_mm/2, center=true);
    
    // Bottom threaded interface (not visible as length is 0)
    if (bottom_thread_length_mm > 0) {
      translate([0, 0, (-length_mm/2 + bottom_thread_length_mm/2) + overlap_mm/2])
        cylinder(h=bottom_thread_length_mm, r=thread_diameter_mm/2, center=true);
    }
  }
}

// Pillar - complete geometry
module pillar() {
  // For this example, the pillar is the same as the standoff
  standoff();
}

// Assembly
module assembly() {
  pillar();
}

assembly();