// HT 125 pipe 500 mm (connected, visible, manifold)

// Parameters
nominal_diameter_mm = 125; //[60:250:1]
length_mm = 500; //[250:1000:1]
wall_thickness_mm = 3.2; //[1.6:6.4:0.1]
include_end_fitting = 1; //[0:1:1]
center = 0; //[0:1:1]
fitting_length_mm = 55; //[25:110:1]
fitting_od_extra_mm = 8; //[3:20:0.5]
fitting_wall_extra_mm = 1.8; //[0.5:4:0.1]
connection_overlap_mm = 1; //[0.5:2:0.1]
bore_clearance_mm = 0.2; //[0:0.6:0.05]

// Quality
$fn = 128;

// Robust epsilon
eps = 0.02;

// Derived radii (ensure valid)
outer_r = max(0.1, nominal_diameter_mm/2);
inner_r = max(0.1, outer_r - wall_thickness_mm);

// Fitting OD is larger by fitting_od_extra_mm (diameter), so radius increases by half
fitting_outer_r = max(outer_r + 0.1, outer_r + fitting_od_extra_mm/2);

// Fitting wall is thicker by fitting_wall_extra_mm
fitting_inner_r = max(0.1, fitting_outer_r - (wall_thickness_mm + fitting_wall_extra_mm));

// Clamp overlap to sensible range
overlap = min(connection_overlap_mm, fitting_length_mm - eps);

// HT Pipe - ONE connected solid (outer union, inner difference)
module ht_pipe() {
  color([0.85, 0.85, 0.8])
  difference() {
    // OUTER SOLID
    union() {
      // Main pipe outer
      cylinder(h=length_mm, r=outer_r, center=false);

      // End fitting outer (connected by computed overlap)
      if (include_end_fitting) {
        translate([0, 0, length_mm - fitting_length_mm + overlap])
          cylinder(h=fitting_length_mm, r=fitting_outer_r, center=false);
      }
    }

    // INNER VOID (continuous bore through entire part)
    // Use the smallest inner radius so the void always passes through both sections.
    void_r = max(0.1, min(inner_r, fitting_inner_r) - bore_clearance_mm);
    void_h = length_mm + (include_end_fitting ? fitting_length_mm : 0) + 2*bore_clearance_mm + 4*eps;

    translate([0, 0, -bore_clearance_mm - 2*eps])
      cylinder(h=void_h, r=void_r, center=false);
  }
}

// Assembly
if (center)
  translate([0, 0, -length_mm/2]) ht_pipe();
else
  ht_pipe();