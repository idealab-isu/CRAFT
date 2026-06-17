// HT 50 pipe, 250 mm long (with optional end socket)
// One connected solid, no arbitrary translations.

$fn = 128;

// Parameters
length_mm = 250;                 // [125:500:1]
ht50_outer_diameter = 50;        // [40:80:0.5]
wall_thickness = 1.8;            // [1:4:0.1]
include_end_fitting = 1;         // [0:1:1]
fitting_length = 18;             // [10:40:1]
fitting_radial_thickness = 3;    // [1:8:0.5]
overlap = 1;                     // [0.5:2:0.1]

// Derived
outer_r = ht50_outer_diameter/2;
inner_r = outer_r - wall_thickness;
fitting_outer_r = outer_r + fitting_radial_thickness;

// Safety
inner_r_safe = max(0.01, inner_r);
overlap_safe = max(0.01, overlap);

// Pipe wall (hollow)
module ht_pipe_segment() {
    difference() {
        cylinder(h=length_mm, r=outer_r, center=false);
        translate([0, 0, -overlap_safe])
            cylinder(h=length_mm + 2*overlap_safe, r=inner_r_safe, center=false);
    }
}

// End socket (thickened outer ring) that overlaps the pipe to ensure connectivity
module end_fitting() {
    if (include_end_fitting) {
        z0 = length_mm - overlap_safe; // overlap into pipe by overlap_safe

        difference() {
            translate([0, 0, z0])
                cylinder(h=fitting_length, r=fitting_outer_r, center=false);

            // Keep bore continuous through fitting; extend a bit to avoid coplanar faces
            translate([0, 0, z0 - overlap_safe])
                cylinder(h=fitting_length + 2*overlap_safe, r=inner_r_safe, center=false);
        }
    }
}

// Complete HT pipe (single connected solid)
module ht_pipe() {
    union() {
        ht_pipe_segment();
        end_fitting();
    }
}

ht_pipe();