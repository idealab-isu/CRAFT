// HT 160 pipe 2000 mm (single connected solid)

// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter_mm = 160; //[80:320:1]
length_mm = 2000; //[1000:4000:10]
outer_diameter_mm = 160; //[80:320:1]
wall_thickness_mm = 4.7; //[2.35:9.4:0.1]
include_end_fitting = 1; //[0:1:1]
fit_overlap_mm = 1; //[0.5:2:0.1]
fitting_length_mm = 120; //[60:240:1]
fitting_od_extra_mm = 10; //[4:25:0.5]
fitting_wall_extra_mm = 2; //[0.5:6:0.1]
fitting_bore_clearance_mm = 1; //[0.2:3:0.1]

$fn = 128;

// Helpers
eps = 0.05;

module ht_pipe() {
    // Derived dimensions (guard against invalid values)
    od = outer_diameter_mm;
    r_out = od/2;
    t = wall_thickness_mm;
    r_in = max(r_out - t, 0.1);

    fit_len = fitting_length_mm;
    overlap = fit_overlap_mm;

    // Fitting outer radius and inner bore radius
    r_fit_out = r_out + fitting_od_extra_mm/2;
    r_fit_bore = r_out + fitting_bore_clearance_mm; // socket bore for pipe OD

    // Place fitting so it overlaps the main pipe by 'overlap' (ensures connectivity)
    z_fit = length_mm - fit_len - overlap;

    color([0.85, 0.85, 0.8])
    union() {
        // Main pipe (hollow)
        difference() {
            cylinder(h=length_mm, r=r_out, center=false);
            translate([0, 0, -eps])
                cylinder(h=length_mm + 2*eps, r=r_in, center=false);
        }

        // End fitting (socket) - hollow ring that overlaps the pipe
        if (include_end_fitting) {
            translate([0, 0, z_fit])
            difference() {
                cylinder(h=fit_len, r=r_fit_out, center=false);
                translate([0, 0, -eps])
                    cylinder(h=fit_len + 2*eps, r=r_fit_bore, center=false);
            }
        }
    }
}

ht_pipe();