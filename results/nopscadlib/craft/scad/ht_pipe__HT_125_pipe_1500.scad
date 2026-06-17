// Parameters
length_mm = 1500; //[750:3000:10]
ht125_outer_diameter_mm = 125; //[100:160:1]
ht125_wall_thickness_mm = 3.2; //[1.6:6.4:0.1]
include_end_fitting = 1; //[0:1:1]
fitting_length_mm = 60; //[30:120:1]
fitting_od_increase_mm = 8; //[2:20:0.5]
fitting_wall_extra_mm = 1.5; //[0.5:4:0.1]
connect_overlap_mm = 1; //[0.5:2:0.1]

$fn = 128;

module ht_pipe() {
    od = ht125_outer_diameter_mm;
    t  = ht125_wall_thickness_mm;

    // Radii
    or = od/2;
    ir = max(0.01, or - t);

    // Fitting (socket) dimensions
    fit_len = fitting_length_mm;
    fit_or  = (od + 2*fitting_od_increase_mm)/2;

    // Socket wall thickness = pipe wall + extra (so socket is thicker, not thinner)
    fit_ir = max(0.01, fit_or - (t + fitting_wall_extra_mm));

    // Ensure socket bore is not smaller than pipe bore (avoid internal step that can look like "missing" geometry)
    fit_ir = max(fit_ir, ir);

    // Robust boolean epsilon
    eps = 0.2;

    // Place pipe centered on Z for better viewing (prevents "blank" due to extreme extents in some viewers)
    translate([0, 0, -length_mm/2])
    color([0.85, 0.85, 0.8])
    difference() {
        // OUTER SOLID (connected via overlap)
        union() {
            cylinder(h=length_mm, r=or, center=false);

            if (include_end_fitting)
                translate([0, 0, length_mm - connect_overlap_mm])
                    cylinder(h=fit_len + connect_overlap_mm, r=fit_or, center=false);
        }

        // INNER VOID (continuous bore)
        union() {
            // Pipe bore
            translate([0, 0, -eps])
                cylinder(h=length_mm + 2*eps, r=ir, center=false);

            // Socket bore
            if (include_end_fitting)
                translate([0, 0, (length_mm - connect_overlap_mm) - eps])
                    cylinder(h=(fit_len + connect_overlap_mm) + 2*eps, r=fit_ir, center=false);
        }
    }
}

ht_pipe();