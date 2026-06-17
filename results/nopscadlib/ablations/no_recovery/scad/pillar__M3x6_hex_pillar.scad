// Parameters
thread_diameter_mm = 3.0; //[1.5:6.0:0.1]
length_mm = 6.0; //[3.0:12.0:0.5]
outer_diameter_mm = 6.0; //[3.5:12.0:0.5]
top_thread_length_mm = 6.0; //[0.0:6.0:0.5]
bottom_thread_length_mm = 0.0; //[0.0:6.0:0.5]
overlap_mm = 1.0; //[0.5:2.0:0.1]
eps_mm = 0.2; //[0.05:0.5:0.05]

// Standoff - complete geometry
module standoff() {
  color("Silver") {
    difference() {
      // Pillar body
      translate([0, 0, 0])
        cylinder(h=length_mm, r=outer_diameter_mm/2, center=true, $fn=64);
      
      // Top threaded section (hole)
      translate([0, 0, length_mm/2 - (top_thread_length_mm + eps_mm)/2 + overlap_mm])
        cylinder(h=top_thread_length_mm + eps_mm, r=thread_diameter_mm/2, center=true, $fn=64);
      
      // Bottom threaded section (hole)
      translate([0, 0, -length_mm/2 + (bottom_thread_length_mm + eps_mm)/2 - overlap_mm])
        cylinder(h=bottom_thread_length_mm + eps_mm, r=thread_diameter_mm/2, center=true, $fn=64);
    }
  }
}

// Pillar - complete geometry
module pillar() {
  color("DimGray") {
    // Using the same geometry as standoff for demonstration
    standoff();
  }
}

// Assembly
module assembly() {
  standoff();
  translate([0, 0, length_mm + 1]) pillar(); // Adjust position to stack on top
}

assembly();