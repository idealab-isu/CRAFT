// Parameters
thread_diameter_mm = 3.0; //[1.5:6.0:0.1]
length_mm = 10.0; //[5.0:20.0:0.5]
outer_diameter_mm = 6.0; //[3.5:12.0:0.5]
thread_length_top_mm = 3.0; //[0.0:10.0:0.5]
thread_length_bottom_mm = 3.0; //[0.0:10.0:0.5]
overlap_mm = 1.0; //[0.5:2.0:0.1]

// Standoff - complete geometry
module standoff() {
  color("Silver") {
    // Pillar body
    translate([0, 0, 0])
      cylinder(h=length_mm, r=outer_diameter_mm/2, center=true, $fn=64);
  }
}

// Pillar - complete geometry
module pillar() {
  color("DimGray") {
    // Top threaded interface
    translate([0, 0, length_mm/2 + thread_length_top_mm/2 - overlap_mm])
      cylinder(h=thread_length_top_mm, r=thread_diameter_mm/2, center=true, $fn=32);
    
    // Bottom threaded interface
    translate([0, 0, -(length_mm/2 + thread_length_bottom_mm/2 - overlap_mm)])
      cylinder(h=thread_length_bottom_mm, r=thread_diameter_mm/2, center=true, $fn=32);
  }
}

// Assembly
module assembly() {
  standoff();
  pillar();
}

assembly();