// HT 32 pipe 2000 mm (single connected solid)

// Parameters
pipe_od = 32; //[16:64:1]
wall_thickness = 2.4; //[1.2:4.8:0.1]
length_mm = 2000; //[1000:4000:10]
end_fitting_length = 35; //[15:70:1]
end_fitting_radial_add = 2.0; //[0.5:6.0:0.1]
end_fitting_wall = 2.0; //[1.0:5.0:0.1]
connect_overlap = 1.0; //[0.5:2.0:0.1]

$fn = 128;

module ht_pipe() {
    // Derived radii
    ro = pipe_od/2;
    ri = ro - wall_thickness;

    // Fitting radii (socket OD larger, ID slightly smaller than pipe OD)
    fro = ro + end_fitting_radial_add;
    fri = ro - end_fitting_wall;

    // Robustness
    eps = 0.05;
    ri2  = max(0.01, ri);
    fri2 = max(0.01, fri);

    // Ensure overlap is valid and fitting length is positive
    ov = min(connect_overlap, max(0, end_fitting_length - eps));
    fit_len = max(eps, end_fitting_length);

    // Center the whole pipe on Z for predictable ortho views
    translate([0, 0, -length_mm/2])
    color([0.85, 0.85, 0.8])
    union() {
        // Main pipe (hollow)
        difference() {
            cylinder(h=length_mm, r=ro, center=false);
            translate([0, 0, -eps])
                cylinder(h=length_mm + 2*eps, r=ri2, center=false);
        }

        // End fitting (socket) at +Z end, connected with calculated overlap
        // Fitting starts at: length_mm - fit_len - ov
        translate([0, 0, length_mm - fit_len - ov])
        difference() {
            cylinder(h=fit_len, r=fro, center=false);
            translate([0, 0, -eps])
                cylinder(h=fit_len + 2*eps, r=fri2, center=false);
        }
    }
}

ht_pipe();