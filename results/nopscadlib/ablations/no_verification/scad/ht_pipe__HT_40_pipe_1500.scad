// HT 40 pipe 1500 mm (single connected solid)

// Parameters
length_mm = 1500; //[750:3000:10]
ht40_outer_diameter = 40; //[30:80:1]
ht40_wall_thickness = 1.8; //[1:4:0.1]
include_end_fitting = 1; //[0:1:1]
fitting_length = 45; //[20:90:1]
fitting_outer_diameter = 46; //[40:90:1]
fitting_wall_extra = 1.2; //[0.5:4:0.1]
overlap = 1; //[0.5:2:0.1]

$fn = 128;

// Derived radii (guard against invalid values)
outer_r = ht40_outer_diameter/2;
inner_r = max(0.01, outer_r - ht40_wall_thickness);

fitting_outer_r = fitting_outer_diameter/2;
fitting_inner_r = max(0.01, inner_r - fitting_wall_extra);

// HT Pipe Segment - Complete Geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8])  // PVC color
  difference() {
    // OUTER solid (pipe + optional socket), unioned so it's one connected body
    union() {
      // Main pipe outer
      cylinder(h=length_mm, r=outer_r, center=false);

      // End fitting outer (socket collar), connected with overlap
      if (include_end_fitting)
        translate([0, 0, length_mm - fitting_length - overlap])
          cylinder(h=fitting_length + overlap, r=fitting_outer_r, center=false);
    }

    // INNER void (continuous through pipe and into socket)
    union() {
      // Main pipe inner
      translate([0, 0, -overlap])
        cylinder(h=length_mm + 2*overlap, r=inner_r, center=false);

      // Socket inner (slightly larger void region), aligned and overlapping
      if (include_end_fitting)
        translate([0, 0, length_mm - fitting_length - 2*overlap])
          cylinder(h=fitting_length + 4*overlap, r=fitting_inner_r, center=false);
    }
  }
}

// Assembly
ht_pipe();