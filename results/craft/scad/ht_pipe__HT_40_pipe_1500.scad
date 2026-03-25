// Parameters
length_mm = 1500; //[750:3000:10]
ht40_outer_diameter = 40; //[30:80:1]
ht40_wall_thickness = 1.8; //[1:4:0.1]
end_fitting_length = 35; //[15:80:1]
end_fitting_radial_add = 3; //[1:10:0.5]
overlap_mm = 1; //[0.5:2:0.1]

$fn = 96;

// HT Pipe Segment - oriented along X so orthographic front/back/left/right show full length
module ht_pipe() {
    outer_r = ht40_outer_diameter/2;
    inner_r = outer_r - ht40_wall_thickness;

    // Total outer length includes the socket/fitting on one end
    total_outer_len = length_mm + end_fitting_length - overlap_mm;

    // Place the whole part centered in X for correct framing in all views
    x_min = -length_mm/2;
    x_max =  length_mm/2 + end_fitting_length - overlap_mm;
    x_center = (x_min + x_max)/2;

    translate([-x_center, 0, 0])
    color([0.85, 0.85, 0.8])
    difference() {
        // ONE connected solid outer shell (main pipe + end fitting) via union with overlap
        union() {
            // Main pipe outer
            translate([0, 0, 0])
                rotate([0, 90, 0])
                    cylinder(h=length_mm, r=outer_r, center=true);

            // End fitting outer (socket) connected to +X end of main pipe
            translate([length_mm/2 + end_fitting_length/2 - overlap_mm, 0, 0])
                rotate([0, 90, 0])
                    cylinder(h=end_fitting_length, r=outer_r + end_fitting_radial_add, center=true);
        }

        // Inner void: continuous through entire length (including fitting)
        // Slightly longer to guarantee clean subtraction at ends
        rotate([0, 90, 0])
            cylinder(h=total_outer_len + 2*overlap_mm, r=inner_r, center=true);
    }
}

// Assembly
module assembly() {
    ht_pipe();
}

assembly();