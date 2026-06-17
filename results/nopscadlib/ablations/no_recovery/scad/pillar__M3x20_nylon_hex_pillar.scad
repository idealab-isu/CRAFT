// Parameters
thread_diameter_mm = 3.0; //[1.5:6.0:0.1]
length_mm = 20.0; //[10.0:40.0:0.5]
outer_diameter_mm = 6.0; //[4.0:12.0:0.5]
thread_length_top_mm = 20.0; //[0.0:20.0:0.5]
thread_length_bottom_mm = 20.0; //[0.0:20.0:0.5]
through_hole_diameter_mm = 3.0; //[1.5:6.0:0.1]
chamfer_mm = 0.8; //[0.0:2.0:0.1]
eps_mm = 0.5; //[0.2:2.0:0.1]

// Pillar - complete geometry
module pillar() {
  color("Silver") {
    // Main body
    cylinder(h=length_mm, r=outer_diameter_mm/2, center=true);
  }
}

// Standoff - complete geometry
module standoff() {
  color("DimGray") {
    difference() {
      // Main body
      pillar();
      // Through hole
      translate([0, 0, 0])
        cylinder(h=length_mm + 2*eps_mm, r=through_hole_diameter_mm/2, center=true);
      // Top chamfer
      translate([0, 0, length_mm/2 - (chamfer_mm + eps_mm)/2 + eps_mm/2])
        cylinder(h=chamfer_mm + eps_mm, r1=through_hole_diameter_mm/2 + chamfer_mm, r2=through_hole_diameter_mm/2, center=true);
      // Bottom chamfer
      translate([0, 0, -length_mm/2 + (chamfer_mm + eps_mm)/2 - eps_mm/2])
        cylinder(h=chamfer_mm + eps_mm, r1=through_hole_diameter_mm/2, r2=through_hole_diameter_mm/2 + chamfer_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  standoff();
}

assembly();