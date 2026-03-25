// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter = 125; //[63:250:1]
length_mm = 250; //[125:500:1]
center = 0; //[0:1:1]
end_style = 1; //[1:1:1]
pipe_od = 125; //[63:250:1]
pipe_wall = 3.2; //[1.6:6.4:0.1]
fit_len = 55; //[30:110:1]
fit_od_extra = 6; //[3:12:0.5]
fit_wall_extra = 1.2; //[0.5:3:0.1]
stop_ring_len = 6; //[3:15:0.5]
stop_ring_radial = 2; //[1:5:0.5]
overlap = 1; //[0.5:2:0.1]
pipe_body_len = 195; //[60:450:1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Outer pipe body
    difference() {
      cylinder(r=pipe_od/2, h=pipe_body_len, center=false);
      // Inner pipe void
      translate([0, 0, -overlap/2])
        cylinder(r=pipe_od/2 - pipe_wall, h=pipe_body_len + overlap, center=false);
    }
    
    // Integrated end fitting
    translate([0, 0, pipe_body_len - overlap]) {
      difference() {
        // Outer fitting
        cylinder(r=pipe_od/2 + fit_od_extra/2, h=fit_len, center=false);
        // Inner fitting void
        translate([0, 0, -overlap/2])
          cylinder(r=pipe_od/2 - pipe_wall - fit_wall_extra, h=fit_len + overlap, center=false);
        // Stop ring void
        translate([0, 0, fit_len - stop_ring_len - overlap/2])
          cylinder(r=pipe_od/2 - pipe_wall - fit_wall_extra - stop_ring_radial, h=stop_ring_len + overlap, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();