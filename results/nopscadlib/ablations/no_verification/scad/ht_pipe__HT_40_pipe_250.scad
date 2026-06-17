$fn = 128;

// Parameters
nominal_diameter = 40; //[20:80:1]
length_mm = 250; //[125:500:1]
outer_diameter_mm = 40; //[30:60:0.5]
wall_thickness_mm = 1.8; //[0.9:3.6:0.1]
include_end_fitting = 1; //[0:1:1]
overlap_mm = 1; //[0.5:2:0.1]
fitting_length_mm = 25; //[12.5:50:0.5]
fitting_wall_extra_mm = 2.2; //[1.1:4.4:0.1]
fitting_bore_clearance_mm = 0.4; //[0.2:1.0:0.1]

// Derived radii (robust)
outer_r = max(0.01, outer_diameter_mm/2);
inner_r = max(0.01, outer_r - wall_thickness_mm);

// Fitting radii
fitting_outer_r = max(outer_r + 0.01, outer_r + fitting_wall_extra_mm);
fitting_inner_r = max(0.01, outer_r + fitting_bore_clearance_mm);

// Ensure fitting bore is not larger than fitting outer radius
fitting_inner_r_safe = min(fitting_inner_r, fitting_outer_r - 0.01);

// Ensure main bore is not larger than outer radius
inner_r_safe = min(inner_r, outer_r - 0.01);

// Module for the HT Pipe (one connected solid)
module ht_pipe() {
  color([0.85, 0.85, 0.8])
  difference() {
    // OUTER SOLID (connected via overlap)
    union() {
      cylinder(h=length_mm, r=outer_r, center=false);

      if (include_end_fitting)
        translate([0, 0, length_mm - fitting_length_mm - overlap_mm])
          cylinder(h=fitting_length_mm + overlap_mm, r=fitting_outer_r, center=false);
    }

    // INNER VOID (continuous subtraction; extends beyond ends to avoid coplanar faces)
    union() {
      translate([0, 0, -overlap_mm])
        cylinder(h=length_mm + 2*overlap_mm, r=inner_r_safe, center=false);

      if (include_end_fitting)
        translate([0, 0, length_mm - fitting_length_mm - 2*overlap_mm])
          cylinder(h=fitting_length_mm + 4*overlap_mm, r=fitting_inner_r_safe, center=false);
    }
  }
}

// Call
ht_pipe();