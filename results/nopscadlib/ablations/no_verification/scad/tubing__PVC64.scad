// Parameters
length_mm = 15; //[8:30:1]
outer_diameter_mm = 10; //[5:20:0.5]
inner_diameter_mm = 8; //[4:18:0.5]
forced_inner_diameter_mm = 0; //[0:18:0.5]
center = 1; //[0:1:1]
z_center_offset_mm = 0; //[-50:50:1]
overlap_mm = 1; //[0.5:2:0.1]

// Tubing - complete geometry
module tubing() {
  color([0.85, 0.85, 0.8]) { // PVC color
    difference() {
      // Outer tube
      cylinder(r=outer_diameter_mm/2, h=length_mm, center=true);
      // Inner tube
      cylinder(r=((forced_inner_diameter_mm > 0) ? forced_inner_diameter_mm : inner_diameter_mm)/2, 
               h=length_mm + 2*overlap_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  translate([0, 0, ((center > 0) ? 0 : (length_mm/2))]) tubing();
}

assembly();