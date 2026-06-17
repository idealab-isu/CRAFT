// Parameters
thread_diameter_mm = 3; //[1.5:6:0.1]
length_mm = 20; //[10:40:0.5]
outer_diameter_mm = 6; //[3.5:12:0.5]
thread_pitch_mm = 0.5; //[0.35:1:0.05]
thread_feature_depth_mm = 20; //[5:40:0.5]
hole_clearance_mm = 0.2; //[0:0.6:0.05]
eps_mm = 0.5; //[0.2:2:0.1]

// Standoff - complete geometry
module standoff() {
  color("Silver") {
    // Body
    cylinder(h=length_mm, r=outer_diameter_mm/2, center=true);
    // Thread feature (clearance hole)
    translate([0, 0, 0])
      cylinder(h=thread_feature_depth_mm + 2*eps_mm, r=(thread_diameter_mm + hole_clearance_mm)/2, center=true);
  }
}

// Pillar - complete geometry
module pillar() {
  color("DimGray") {
    // Body
    cylinder(h=length_mm, r=outer_diameter_mm/2, center=true);
    // Thread feature (clearance hole)
    translate([0, 0, 0])
      cylinder(h=thread_feature_depth_mm + 2*eps_mm, r=(thread_diameter_mm + hole_clearance_mm)/2, center=true);
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