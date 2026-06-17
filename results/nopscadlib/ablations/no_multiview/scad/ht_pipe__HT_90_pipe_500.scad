// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter_mm = 90; //[50:180:1]
length_mm = 500; //[250:1000:1]
include_end_fitting = 1; //[0:1:1]
center = 0; //[0:1:1]
od_mm = 90; //[50:180:1]
wall_thickness_mm = 3.2; //[1.6:6.4:0.1]
socket_length_mm = 55; //[30:110:1]
socket_wall_extra_mm = 2.5; //[1:6:0.1]
socket_clearance_mm = 0.6; //[0.2:1.5:0.1]
overlap_mm = 1; //[0.5:2:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Outer pipe segment
    cylinder(h=length_mm, r=od_mm/2, center=false);

    // End fitting (socket)
    if (include_end_fitting) {
      translate([0, 0, length_mm - overlap_mm])
        cylinder(h=socket_length_mm, r=od_mm/2 + socket_wall_extra_mm, center=false);
    }

    // Hollow bore cutter
    difference() {
      // Outer pipe with fitting
      union() {
        cylinder(h=length_mm, r=od_mm/2, center=false);
        if (include_end_fitting) {
          translate([0, 0, length_mm - overlap_mm])
            cylinder(h=socket_length_mm, r=od_mm/2 + socket_wall_extra_mm, center=false);
        }
      }
      // Inner bore
      translate([0, 0, -overlap_mm])
        cylinder(h=length_mm + socket_length_mm + overlap_mm * 2, r=od_mm/2 - wall_thickness_mm, center=false);

      // Socket void
      if (include_end_fitting) {
        translate([0, 0, length_mm - overlap_mm * 2])
          cylinder(h=socket_length_mm + overlap_mm * 2, r=od_mm/2 + socket_clearance_mm, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();