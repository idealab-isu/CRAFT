// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter_mm = 90; //[45:180:1]
length_mm = 500; //[250:1000:1]
include_end_fitting = 1; //[0:1:1]
wall_thickness = 3.2; //[1.6:6.4:0.1]
fit_length = 55; //[30:110:1]
fit_od_extra = 8; //[3:16:0.5]
socket_clearance = 0.6; //[0.2:1.5:0.1]
socket_wall = 3.5; //[2:7:0.1]
stop_ring_thickness = 4; //[2:10:0.5]
stop_ring_radial = 2; //[1:5:0.5]
overlap = 1; //[0.5:2:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Pipe outer
    difference() {
      cylinder(r=nominal_diameter_mm/2, h=length_mm - (include_end_fitting*fit_length), center=false);
      // Pipe inner void
      translate([0, 0, -overlap/2])
        cylinder(r=nominal_diameter_mm/2 - wall_thickness, h=length_mm - (include_end_fitting*fit_length) + overlap, center=false);
    }
    
    // End fitting shell
    if (include_end_fitting) {
      difference() {
        translate([0, 0, length_mm - (include_end_fitting*fit_length) - overlap])
          cylinder(r=(nominal_diameter_mm + fit_od_extra)/2, h=include_end_fitting*fit_length, center=false);
        // Fitting socket void
        translate([0, 0, length_mm - (include_end_fitting*fit_length) - overlap])
          cylinder(r=nominal_diameter_mm/2 + socket_clearance, h=include_end_fitting*fit_length + overlap, center=false);
        // Fitting stop ring void
        translate([0, 0, length_mm - (include_end_fitting*fit_length) - overlap + include_end_fitting*(fit_length - stop_ring_thickness)])
          cylinder(r=nominal_diameter_mm/2 + socket_clearance - stop_ring_radial, h=include_end_fitting*stop_ring_thickness + overlap, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();