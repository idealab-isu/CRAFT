// HT 125 pipe 1000 mm (single connected solid)

// Parameters
nominal_diameter_mm = 125; //[60:250:1]
length_mm = 1000; //[500:2000:10]
pipe_wall_thickness = 3.2; //[1.6:6.4:0.1]
end_fitting_length = 60; //[30:120:1]
end_fitting_radial_thickness = 4; //[2:10:0.5]
overlap_mm = 1; //[0.5:2:0.1]

$fn = 128;

module ht_pipe() {
    outer_r = nominal_diameter_mm/2;
    inner_r = max(outer_r - pipe_wall_thickness, 0.01);

    socket_outer_r = outer_r + end_fitting_radial_thickness;

    // Small epsilon to avoid coplanar/zero-thickness artifacts
    eps = 0.2;

    // Socket placement at the "top" end, with overlap into the main pipe for connectivity
    socket_z0 = length_mm - end_fitting_length;
    socket_z0_overlap = socket_z0 - overlap_mm;
    socket_h = end_fitting_length + overlap_mm;

    color([0.85, 0.85, 0.8])
    difference() {
        // Outer solid: main pipe + socket (connected via overlap)
        union() {
            cylinder(r=outer_r, h=length_mm, center=false);

            translate([0, 0, socket_z0_overlap])
                cylinder(r=socket_outer_r, h=socket_h, center=false);
        }

        // Inner void: bore through entire pipe AND through socket region
        // (extend slightly beyond ends to ensure clean subtraction)
        translate([0, 0, -eps])
            cylinder(r=inner_r, h=length_mm + 2*eps, center=false);
    }
}

ht_pipe();