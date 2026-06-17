// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter_mm = 32; //[16:64:1]
length_mm = 1500; //[750:3000:10]
center = 0; //[0:1:1]
ht32_outer_diameter = 32; //[24:40:0.5]
ht32_wall_thickness = 1.8; //[1.0:3.0:0.1]
fit_socket_od_factor = 1.18; //[1.05:1.35:0.01]
fit_socket_length_factor = 0.75; //[0.4:1.2:0.01]
fit_stop_ring_od_factor = 1.28; //[1.1:1.6:0.01]
fit_stop_ring_length_factor = 0.12; //[0.05:0.25:0.01]
fit_overlap = 1; //[0.5:2:0.1]
fit_socket_wall_extra = 1.2; //[0.5:3:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Pipe segment
    difference() {
      cylinder(h=length_mm, r=ht32_outer_diameter/2, center=false);
      translate([0, 0, ht32_wall_thickness])
        cylinder(h=length_mm, r=ht32_outer_diameter/2 - ht32_wall_thickness, center=false);
    }
    
    // End fitting geometry
    union() {
      // Socket outer
      translate([0, 0, length_mm - fit_overlap])
        cylinder(h=ht32_outer_diameter * fit_socket_length_factor, r=(ht32_outer_diameter * fit_socket_od_factor) / 2, center=false);
      
      // Stop ring outer
      translate([0, 0, length_mm - fit_overlap + ht32_outer_diameter * fit_socket_length_factor - ht32_outer_diameter * fit_stop_ring_length_factor])
        cylinder(h=ht32_outer_diameter * fit_stop_ring_length_factor, r=(ht32_outer_diameter * fit_stop_ring_od_factor) / 2, center=false);
    }
    
    // Socket inner void
    translate([0, 0, length_mm - fit_overlap + (ht32_wall_thickness + fit_socket_wall_extra)])
      difference() {
        cylinder(h=ht32_outer_diameter * fit_socket_length_factor, r=(ht32_outer_diameter * fit_socket_od_factor) / 2, center=false);
        cylinder(h=ht32_outer_diameter * fit_socket_length_factor, r=(ht32_outer_diameter * fit_socket_od_factor) / 2 - (ht32_wall_thickness + fit_socket_wall_extra), center=false);
      }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();