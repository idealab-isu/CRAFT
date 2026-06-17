// Parameters
length_mm = 500; //[250:1000:1]
ht40_outer_diameter = 40; //[20:80:0.5]
ht40_wall_thickness = 1.8; //[0.9:3.6:0.1]
fitting_outer_diameter = 46; //[35:70:0.5]
fitting_height = 35; //[15:70:1]
fitting_wall_thickness = 2.5; //[1.2:5:0.1]
fitting_stop_thickness = 2; //[1:6:0.5]
overlap_mm = 1; //[0.5:2:0.1]

$fn = 128;

// HT Pipe Segment - One connected solid
module ht_pipe() {
    // Derived radii
    ro_pipe = ht40_outer_diameter/2;
    ri_pipe = ro_pipe - ht40_wall_thickness;

    ro_fit  = fitting_outer_diameter/2;
    ri_fit  = ro_fit - fitting_wall_thickness;

    // Safety clamps to avoid invalid/empty geometry
    ri_pipe_s = max(0.01, ri_pipe);
    ri_fit_s  = max(0.01, ri_fit);

    // Ensure inner subtraction is longer than outer to avoid coplanar faces
    eps = 0.02;

    color([0.85, 0.85, 0.8])  // PVC color
    union() {
        // Main pipe (hollow)
        difference() {
            cylinder(h=length_mm, r=ro_pipe, center=false);
            translate([0, 0, -eps])
                cylinder(h=length_mm + 2*eps, r=ri_pipe_s, center=false);
        }

        // Socket/fitting at the end, connected with controlled overlap
        // Place fitting so it overlaps the pipe by overlap_mm
        translate([0, 0, length_mm - overlap_mm]) {
            difference() {
                // Outer fitting body
                cylinder(h=fitting_height, r=ro_fit, center=false);

                // Inner cavity of fitting (starts after stop thickness)
                translate([0, 0, fitting_stop_thickness - eps])
                    cylinder(h=fitting_height - fitting_stop_thickness + 2*eps, r=ri_fit_s, center=false);

                // Clear the pipe bore through the fitting so the pipe remains hollow
                translate([0, 0, -eps])
                    cylinder(h=fitting_height + 2*eps, r=ri_pipe_s, center=false);
            }
        }
    }
}

ht_pipe();