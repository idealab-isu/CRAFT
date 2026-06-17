// Parameters
nominal_size = 75; //[40:160:1]
length_mm = 500; //[250:1000:1]
pipe_od = 75; //[60:110:0.5]
pipe_wall = 2.7; //[1.5:5.5:0.1]
fitting_length = 35; //[20:70:1]
fitting_od_scale = 1.12; //[1.02:1.3:0.01]
fitting_bore_clearance = 0.3; //[0.0:1.0:0.05]
connect_overlap = 1; //[0.5:2:0.1]

$fn = 128;

module ht_pipe() {
    pipe_r = pipe_od/2;
    fit_r  = (pipe_od * fitting_od_scale)/2;

    // Inner radii
    pipe_ir = max(0.01, pipe_r - pipe_wall);
    fit_ir  = max(0.01, pipe_ir + fitting_bore_clearance);

    // Ensure overlap is valid and fitting exists
    ov = min(connect_overlap, fitting_length - 0.01);
    z_fit0 = length_mm - ov;          // fitting starts overlapping into pipe
    z_fit1 = z_fit0 + fitting_length; // fitting end

    // Robust boolean epsilon to avoid coplanar/empty results
    eps = 0.05;

    color([0.85, 0.85, 0.8])
    difference() {
        // OUTER solid (one connected body)
        union() {
            cylinder(h=length_mm, r=pipe_r, center=false);
            translate([0, 0, z_fit0])
                cylinder(h=fitting_length, r=fit_r, center=false);
        }

        // INNER void (continuous bore; slightly extended to guarantee clean subtraction)
        union() {
            // Main pipe bore (open both ends)
            translate([0, 0, -eps])
                cylinder(h=length_mm + 2*eps, r=pipe_ir, center=false);

            // Socket bore: leave a closed ring at the very end of the socket
            // (starts at z_fit0 + pipe_wall, ends at z_fit1)
            translate([0, 0, z_fit0 + pipe_wall - eps])
                cylinder(h=max(0.01, fitting_length - pipe_wall) + 2*eps, r=fit_ir, center=false);
        }
    }
}

ht_pipe();