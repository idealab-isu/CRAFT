// Parameters
nominal_size = 125; //[60:250:1]
length_mm = 150; //[75:300:1]
center = 0; //[0:1:1]

ht125_outer_diameter = 125; //[62.5:250:0.5]
ht125_wall_thickness = 3.2; //[1.6:6.4:0.1]

end_fitting_length = 25; //[12.5:50:0.5]
end_fitting_radial_add = 2.5; //[1.0:5.0:0.1]
end_fitting_inner_clearance = 0.5; //[0.2:1.5:0.1]

overlap = 1; //[0.5:2:0.1]
$fn = 128;

module ht_pipe() {
    od = ht125_outer_diameter;
    wt = ht125_wall_thickness;

    main_r = od/2;
    fit_r  = main_r + end_fitting_radial_add;

    // Inner radii (must remain positive)
    main_ir = max(0.01, main_r - wt);
    fit_ir  = max(0.01, main_ir + end_fitting_inner_clearance);

    // Fitting at the top end
    fit_z0 = length_mm - end_fitting_length;

    // Optional centering
    z_shift = (center == 1) ? -length_mm/2 : 0;

    translate([0, 0, z_shift])
    difference() {
        // Outer shell (one connected solid)
        union() {
            cylinder(h=length_mm, r=main_r, center=false);

            // Connected by overlap into main pipe
            translate([0, 0, fit_z0 - overlap])
                cylinder(h=end_fitting_length + overlap, r=fit_r, center=false);
        }

        // Inner void: subtract as two segments to avoid coplanar/zero-thickness issues
        // Segment 1: main bore up to start of fitting
        translate([0, 0, -overlap])
            cylinder(h=fit_z0 + overlap, r=main_ir, center=false);

        // Segment 2: fitting bore (slightly larger clearance)
        translate([0, 0, fit_z0 - overlap])
            cylinder(h=end_fitting_length + 2*overlap, r=fit_ir, center=false);
    }
}

ht_pipe();