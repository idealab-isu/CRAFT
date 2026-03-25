// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter_mm = 75; //[40:150:1]
length_mm = 500; //[250:1000:1]
include_end_fitting = 1; //[0:1:1]
center = 0; //[0:1:1]
pipe_od_mm = 75; //[60:110:0.5]
pipe_wall_mm = 2.7; //[1.5:5.5:0.1]
fit_socket_length_mm = 45; //[25:80:1]
fit_od_extra_mm = 6; //[2:15:0.5]
fit_wall_extra_mm = 1.3; //[0.5:4:0.1]
fit_stop_ring_length_mm = 8; //[3:20:1]
fit_stop_ring_extra_od_mm = 3; //[1:10:0.5]
overlap_mm = 1; //[0.5:2:0.1]
pipe_id_mm = 69.6; //[50:105:0.5]
fit_od_mm = 81; //[65:130:0.5]
fit_wall_mm = 4; //[2:8:0.1]
fit_id_mm = 73; //[55:120:0.5]
fit_effective_length_mm = 45; //[0:80:1]

$fn = 128;

// Module for the HT Pipe (axis along X so orthographic front/back/left/right show length)
module ht_pipe() {
  color([0.85, 0.85, 0.8])
  rotate([0, 90, 0])  // make pipe run along X instead of Z
  union() {
    // Outer solid (pipe + optional socket + stop ring) as ONE connected solid
    difference() {
      union() {
        // Main pipe outer
        cylinder(h=length_mm, r=pipe_od_mm/2, center=false);

        if (include_end_fitting) {
          // Socket outer (overlaps into pipe by overlap_mm to guarantee connectivity)
          translate([0, 0, length_mm - overlap_mm])
            cylinder(h=fit_effective_length_mm + overlap_mm, r=fit_od_mm/2, center=false);

          // Stop ring outer (overlaps into socket by overlap_mm)
          translate([0, 0, length_mm + fit_effective_length_mm - fit_stop_ring_length_mm - overlap_mm])
            cylinder(h=fit_stop_ring_length_mm + overlap_mm,
                     r=(fit_od_mm + fit_stop_ring_extra_od_mm)/2, center=false);
        }
      }

      // Inner void (continuous through pipe and into socket)
      union() {
        // Pipe inner
        translate([0, 0, -overlap_mm])
          cylinder(h=length_mm + 2*overlap_mm, r=pipe_id_mm/2, center=false);

        if (include_end_fitting) {
          // Socket inner (starts slightly inside pipe to ensure clean boolean)
          translate([0, 0, length_mm - 2*overlap_mm])
            cylinder(h=fit_effective_length_mm + 4*overlap_mm, r=fit_id_mm/2, center=false);
        }
      }
    }
  }
}

// Assembly
module assembly() {
  // Optional centering of the whole part along its length
  if (center)
    translate([-length_mm/2, 0, 0]) ht_pipe();
  else
    ht_pipe();
}

assembly();