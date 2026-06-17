// Parameters
thread_diameter_mm = 3.0; //[2.0:6.0:0.1]
length_mm = 13.0; //[6.0:26.0:0.5]
outer_diameter_mm = 6.0; //[4.0:12.0:0.5]
thread_length_top_mm = 6.0; //[0.0:13.0:0.5]
thread_length_bottom_mm = 6.0; //[0.0:13.0:0.5]
thread_feature_radial_depth_mm = 0.4; //[0.1:1.0:0.1]
overlap_mm = 1.0; //[0.5:2.0:0.1]
chamfer_height_mm = 0.8; //[0.0:2.0:0.1]
chamfer_radial_mm = 0.6; //[0.0:2.0:0.1]

// Standoff - complete geometry
module standoff() {
  color([0.85, 0.85, 0.8]) {
    // Pillar body
    cylinder(r=outer_diameter_mm/2, h=length_mm, center=true);

    // Thread features
    union() {
      translate([0, 0, length_mm/2 - thread_length_top_mm/2])
        cylinder(r=max(thread_diameter_mm/2, outer_diameter_mm/2 - thread_feature_radial_depth_mm), 
                 h=thread_length_top_mm + overlap_mm, center=true);
      translate([0, 0, -length_mm/2 + thread_length_bottom_mm/2])
        cylinder(r=max(thread_diameter_mm/2, outer_diameter_mm/2 - thread_feature_radial_depth_mm), 
                 h=thread_length_bottom_mm + overlap_mm, center=true);
    }
  }
}

// Pillar - complete geometry
module pillar() {
  color([0.85, 0.85, 0.8]) {
    // Chamfered ends
    difference() {
      cylinder(r=outer_diameter_mm/2, h=length_mm, center=true);
      scale([(outer_diameter_mm - 2*chamfer_radial_mm)/outer_diameter_mm, 
             (outer_diameter_mm - 2*chamfer_radial_mm)/outer_diameter_mm, 1]) {
        translate([0, 0, length_mm/2 - chamfer_height_mm/2])
          cylinder(r1=outer_diameter_mm/2, r2=0, h=chamfer_height_mm, center=true);
        translate([0, 0, -length_mm/2 + chamfer_height_mm/2])
          cylinder(r1=outer_diameter_mm/2, r2=0, h=chamfer_height_mm, center=true);
      }
    }
  }
}

// Assembly
module assembly() {
  standoff();
  pillar();
}

assembly();