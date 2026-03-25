// Parameters
length_mm = 500; //[250:1000:1]
ht40_outer_diameter = 40; //[30:80:0.5]
ht40_wall_thickness = 1.8; //[0.9:3.6:0.1]
end_fitting_length = 12; //[6:24:0.5]
end_fitting_radial_add = 2; //[1:6:0.5]
overlap_mm = 1; //[0.5:2:0.1]
center = 0; //[0:1:1]

$fn = 128;

// HT Pipe - complete geometry
module ht_pipe() {
  outer_r = ht40_outer_diameter/2;
  inner_r = outer_r - ht40_wall_thickness;

  // Keep fitting within total length so overall length stays exactly length_mm
  fit_len = min(end_fitting_length, length_mm);
  pipe_len = length_mm - fit_len;

  // Place pipe along X so front/back/left/right orthographic views show the 500mm length
  // (OpenSCAD default: X=right, Y=back, Z=up; Front view looks along -Y)
  rotate([0, 90, 0]) {
    translate([0, 0, center ? -length_mm/2 : 0]) {
      color([0.85, 0.85, 0.8]) {
        union() {
          // Main pipe section (hollow)
          difference() {
            cylinder(h=pipe_len, r=outer_r, center=false);
            translate([0, 0, -overlap_mm])
              cylinder(h=pipe_len + 2*overlap_mm, r=inner_r, center=false);
          }

          // End fitting (outer sleeve), connected with overlap
          translate([0, 0, pipe_len - overlap_mm]) {
            difference() {
              cylinder(h=fit_len + overlap_mm, r=outer_r + end_fitting_radial_add, center=false);
              translate([0, 0, -overlap_mm])
                cylinder(h=fit_len + 2*overlap_mm, r=inner_r, center=false);
            }
          }
        }
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();