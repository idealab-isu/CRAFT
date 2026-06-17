// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter_mm = 75; //[40:150:1]
length_mm = 1500; //[750:3000:10]
center = 0; //[0:1:1]
ht75_outer_diameter_mm = 75; //[70:80:0.1]
ht75_wall_thickness_mm = 2.7; //[1.5:5.4:0.1]
fit_socket_length_mm = 55; //[30:110:1]
fit_outer_diameter_extra_mm = 6; //[3:12:0.5]
fit_wall_extra_mm = 1.5; //[0.5:3:0.1]
fit_stop_ring_length_mm = 6; //[3:15:0.5]
fit_stop_ring_radial_mm = 2; //[1:5:0.1]
overlap_mm = 1; //[0.5:2:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Pipe body
    difference() {
      cylinder(r=ht75_outer_diameter_mm/2, h=length_mm, center=false);
      translate([0, 0, ht75_wall_thickness_mm])
        cylinder(r=ht75_outer_diameter_mm/2 - ht75_wall_thickness_mm, h=length_mm, center=false);
    }
    
    // End fitting
    difference() {
      translate([0, 0, length_mm - overlap_mm])
        cylinder(r=(ht75_outer_diameter_mm + fit_outer_diameter_extra_mm)/2, h=fit_socket_length_mm, center=false);
      
      union() {
        translate([0, 0, length_mm - overlap_mm])
          cylinder(r=ht75_outer_diameter_mm/2 + fit_wall_extra_mm, h=fit_socket_length_mm, center=false);
        
        translate([0, 0, length_mm - overlap_mm + fit_socket_length_mm - fit_stop_ring_length_mm])
          cylinder(r=ht75_outer_diameter_mm/2 + fit_wall_extra_mm - fit_stop_ring_radial_mm, h=fit_stop_ring_length_mm, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();