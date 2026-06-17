// Parameters
thread_diameter_mm = 3.0; //[1.5:6.0:0.1]
length_mm = 10.0; //[5.0:20.0:0.5]
outer_diameter_mm = 6.0; //[3.5:12.0:0.5]
hole_extra_mm = 0.2; //[0.0:0.6:0.05]
cut_extra_z_mm = 1.0; //[0.5:3.0:0.5]

// Standoff - complete geometry
module standoff() {
  color("Silver") {
    // Outer body
    cylinder(h=length_mm, r=outer_diameter_mm/2, center=true);
  }
}

// Pillar - complete geometry
module pillar() {
  color("DimGray") {
    // Through-hole for thread representation
    cylinder(h=length_mm + cut_extra_z_mm, r=(thread_diameter_mm + hole_extra_mm)/2, center=true);
  }
}

// Assembly
module assembly() {
  difference() {
    standoff();
    pillar();
  }
}

assembly();