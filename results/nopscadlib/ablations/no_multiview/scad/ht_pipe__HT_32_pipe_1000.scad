// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter_mm = 32; //[16:64:1]
length_mm = 1000; //[500:2000:10]
pipe_od_mm = 32; //[16:64:1]
wall_thickness_mm = 2.0; //[1.0:4.0:0.1]
end_fitting_length_mm = 25; //[10:60:1]
end_fitting_radial_add_mm = 2.0; //[0.5:6.0:0.1]
overlap_mm = 1.0; //[0.5:2.0:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Pipe body
    difference() {
      cylinder(h=length_mm, r=pipe_od_mm/2, center=false);
      translate([0, 0, -overlap_mm/2])
        cylinder(h=length_mm + overlap_mm, r=pipe_od_mm/2 - wall_thickness_mm, center=false);
    }
    
    // End fitting detail
    translate([0, 0, length_mm - end_fitting_length_mm - overlap_mm]) {
      difference() {
        cylinder(h=end_fitting_length_mm, r=pipe_od_mm/2 + end_fitting_radial_add_mm, center=false);
        translate([0, 0, -overlap_mm/2])
          cylinder(h=end_fitting_length_mm + overlap_mm, r=pipe_od_mm/2 - wall_thickness_mm, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();