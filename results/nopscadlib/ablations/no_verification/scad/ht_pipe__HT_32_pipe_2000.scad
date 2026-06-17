// HT 32 pipe 2000 mm (single connected solid, centered for visibility in all orthographic views)

// Parameters
length_mm = 2000; //[1000:4000:10]
od_mm = 32; //[25:50:1]
wall_thickness_mm = 1.8; //[1:4:0.1]
include_end_fitting = 1; //[0:1:1]
fitting_length_mm = 45; //[25:90:1]
fitting_od_extra_mm = 6; //[2:15:0.5]
fitting_wall_extra_mm = 1.2; //[0.5:4:0.1]
fitting_stop_thickness_mm = 2; //[1:6:0.5]
overlap_mm = 1; //[0.5:2:0.1]

$fn = 128;

// Derived radii (clamped)
od_r = od_mm/2;
id_r = max(0.01, od_r - wall_thickness_mm);

fitting_od_r = od_r + fitting_od_extra_mm/2;
fitting_id_r = max(0.01, fitting_od_r - (wall_thickness_mm + fitting_wall_extra_mm));

// HT Pipe - complete geometry (ONE connected solid)
module ht_pipe() {
  // Center the whole assembly around Z=0 so front/back/left/right views show geometry
  z_shift = -(length_mm/2);

  color([0.85, 0.85, 0.8])
  translate([0, 0, z_shift])
  union() {

    // Main pipe body (hollow)
    difference() {
      cylinder(h=length_mm, r=od_r, center=false);
      translate([0, 0, -overlap_mm])
        cylinder(h=length_mm + 2*overlap_mm, r=id_r, center=false);
    }

    // End fitting (socket) at far end, connected with overlap
    if (include_end_fitting) {
      z0 = length_mm - overlap_mm; // overlap into main pipe by overlap_mm

      // Outer fitting shell (solid ring)
      difference() {
        // Outer
        translate([0, 0, z0])
          cylinder(h=fitting_length_mm, r=fitting_od_r, center=false);

        // Inner cavity: accepts pipe OD, but leaves a stop ring at the far end
        translate([0, 0, z0])
          cylinder(
            h=max(0.01, fitting_length_mm - fitting_stop_thickness_mm),
            r=max(0.01, od_r + overlap_mm),
            center=false
          );

        // Keep the pipe bore continuous through the overlapped region
        translate([0, 0, z0 - overlap_mm])
          cylinder(h=fitting_length_mm + 2*overlap_mm, r=id_r, center=false);
      }
    }
  }
}

// Assembly
ht_pipe();