// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter_mm = 32; //[16:64:1]
length_mm = 500; //[250:1000:1]
wall_thickness_mm = 2.4; //[1.2:4.8:0.1]
fitting_length_mm = 25; //[12.5:50:0.5]
fitting_radial_thickness_mm = 2.0; //[1.0:4.0:0.1]
overlap_mm = 1.0; //[0.5:2.0:0.1]

// HT Pipe Segment - Complete Geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    union() {
      // Main pipe segment
      difference() {
        cylinder(h=length_mm, r=nominal_diameter_mm/2, center=false);
        translate([0, 0, wall_thickness_mm])
          cylinder(h=length_mm, r=nominal_diameter_mm/2 - wall_thickness_mm, center=false);
      }
      
      // End fitting geometry
      difference() {
        translate([0, 0, length_mm - fitting_length_mm - overlap_mm])
          cylinder(h=fitting_length_mm, r=nominal_diameter_mm/2 + fitting_radial_thickness_mm, center=false);
        translate([0, 0, length_mm - fitting_length_mm - overlap_mm + wall_thickness_mm])
          cylinder(h=fitting_length_mm + overlap_mm, r=nominal_diameter_mm/2 - wall_thickness_mm, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();