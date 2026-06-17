// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter = 32; //[16:64:1]
length_mm = 250; //[125:500:1]
pipe_od = 32; //[16:64:0.5]
wall_thickness = 2.4; //[1.2:4.8:0.1]
fit_socket_od_extra = 6; //[3:12:0.5]
fit_socket_length = 35; //[18:70:1]
fit_stop_ring_length = 6; //[3:12:0.5]
fit_stop_ring_od_extra = 10; //[5:20:0.5]
fit_socket_wall_extra = 0.8; //[0.2:2:0.1]
overlap = 1; //[0.5:2:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Pipe body
    difference() {
      cylinder(r=pipe_od/2, h=length_mm, center=false);
      translate([0, 0, -overlap/2])
        cylinder(r=pipe_od/2 - wall_thickness, h=length_mm + overlap, center=false);
    }
    
    // End fitting geometry
    union() {
      // Socket outer
      translate([0, 0, length_mm - overlap])
        cylinder(r=pipe_od/2 + fit_socket_od_extra/2, h=fit_socket_length, center=false);
      
      // Stop ring outer
      translate([0, 0, length_mm + fit_socket_length - fit_stop_ring_length - overlap])
        cylinder(r=pipe_od/2 + fit_stop_ring_od_extra/2, h=fit_stop_ring_length, center=false);
    }
    
    // End fitting inner void
    difference() {
      union() {
        // Socket inner void
        translate([0, 0, length_mm - overlap - overlap/2])
          cylinder(r=pipe_od/2 - wall_thickness - fit_socket_wall_extra, h=fit_socket_length + overlap, center=false);
        
        // Stop ring inner void
        translate([0, 0, length_mm + fit_socket_length - fit_stop_ring_length - overlap - overlap/2])
          cylinder(r=pipe_od/2 - wall_thickness - fit_socket_wall_extra, h=fit_stop_ring_length + overlap, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();