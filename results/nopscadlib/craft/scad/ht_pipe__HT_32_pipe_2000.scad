$fn = 128;

// Parameters
length_mm = 2000; //[1000:4000:10]
ht32_outer_diameter_mm = 32; //[16:64:1]
ht32_wall_thickness_mm = 1.8; //[0.9:3.6:0.1]
fitting_length_mm = 45; //[25:90:1]
fitting_outer_diameter_mm = 40; //[32:80:1]
fitting_wall_thickness_mm = 2.5; //[1.2:5:0.1]
fitting_stop_thickness_mm = 3; //[1:8:0.5]
fitting_stop_axial_pos_mm = 18; //[8:35:1]
overlap_mm = 1; //[0.5:2:0.1]

eps = 0.02;

module ht_pipe() {
    pipe_r_o = ht32_outer_diameter_mm/2;
    pipe_r_i = max(0.01, pipe_r_o - ht32_wall_thickness_mm);

    fit_r_o  = fitting_outer_diameter_mm/2;
    fit_r_i  = max(0.01, fit_r_o - fitting_wall_thickness_mm);

    // Clamp overlap so fitting always intersects pipe (one connected solid)
    ov = min(max(overlap_mm, 0.1), fitting_length_mm - 0.1);

    // Fitting starts before pipe end by ov, so it overlaps into pipe
    fit_z = length_mm - ov;

    // Stop ring: create an internal shoulder by reducing the inner radius locally
    stop_h = min(max(fitting_stop_thickness_mm, 0.1), fitting_length_mm - 0.1);
    stop_z0 = min(max(fitting_stop_axial_pos_mm, 0), fitting_length_mm - stop_h);

    // Inner radius at stop region (smaller than fit_r_i, but not smaller than pipe_r_i)
    // This leaves a shoulder that can stop the inserted pipe.
    stop_inner_r = max(pipe_r_i, fit_r_i - max(0.5, fitting_wall_thickness_mm*0.6));

    color([0.85, 0.85, 0.8])
    union() {
        // Pipe body (hollow)
        difference() {
            cylinder(h=length_mm, r=pipe_r_o, center=false);
            translate([0, 0, -eps])
                cylinder(h=length_mm + 2*eps, r=pipe_r_i, center=false);
        }

        // End fitting (hollow with internal stop shoulder)
        translate([0, 0, fit_z])
        difference() {
            cylinder(h=fitting_length_mm, r=fit_r_o, center=false);

            // Inner void of fitting (full length)
            translate([0, 0, -eps])
                cylinder(h=fitting_length_mm + 2*eps, r=fit_r_i, center=false);

            // Remove less material in stop region by subtracting only to stop_inner_r there
            // (i.e., leave a ring/shoulder between stop_inner_r and fit_r_i)
            translate([0, 0, stop_z0 - eps])
                cylinder(h=stop_h + 2*eps, r=stop_inner_r, center=false);
        }
    }
}

ht_pipe();