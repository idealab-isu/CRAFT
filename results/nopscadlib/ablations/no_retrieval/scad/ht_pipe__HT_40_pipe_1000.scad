$fn = 128;

// Parameters (mm)
pipe_length = 1000;              // HT 40 pipe length
outer_diameter = 40;             // HT 40 OD
wall_thickness = 2;              // wall
socket_length = 60;              // socket length at one end
socket_outer_diameter = 46;      // socket OD
chamfer_length = 2;              // small end chamfer
overlap = 0.5;                   // boolean overlap to avoid gaps

// Derived
outer_r  = outer_diameter/2;
socket_r = socket_outer_diameter/2;
inner_r  = outer_r - wall_thickness;

// Safety
inner_r_ok        = (inner_r > 0) ? inner_r : 0.1;
socket_inner_r_ok = (socket_r - wall_thickness > 0) ? (socket_r - wall_thickness) : 0.1;

// Build along X so orthographic front/back/left/right show the long pipe consistently
module outer_shell_x() {
    union() {
        // Main pipe body centered at origin (axis = X)
        rotate([0, 90, 0])
            cylinder(h=pipe_length, r=outer_r, center=true);

        // Socket on +X end, connected with overlap
        translate([pipe_length/2 - overlap + socket_length/2, 0, 0])
            rotate([0, 90, 0])
                cylinder(h=socket_length, r=socket_r, center=true);
    }
}

module inner_void_x() {
    union() {
        // Bore through main pipe
        rotate([0, 90, 0])
            cylinder(h=pipe_length + 2*overlap, r=inner_r_ok, center=true);

        // Bore through socket region
        translate([pipe_length/2 - overlap + socket_length/2, 0, 0])
            rotate([0, 90, 0])
                cylinder(h=socket_length + 2*overlap, r=socket_inner_r_ok, center=true);
    }
}

// Chamfers by subtracting cones at both ends (axis = X)
module chamfer_cuts_x() {
    union() {
        // +X end chamfer (outer edge of socket)
        translate([pipe_length/2 + socket_length - chamfer_length/2, 0, 0])
            rotate([0, 90, 0])
                cylinder(h=chamfer_length + 2*overlap, r1=socket_r + overlap, r2=0, center=true);

        // -X end chamfer (outer edge of pipe)
        translate([-pipe_length/2 + chamfer_length/2, 0, 0])
            rotate([0, -90, 0])
                cylinder(h=chamfer_length + 2*overlap, r1=outer_r + overlap, r2=0, center=true);
    }
}

// Final model: one connected hollow solid
difference() {
    difference() {
        outer_shell_x();
        chamfer_cuts_x();
    }
    inner_void_x();
}