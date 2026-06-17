$fn = 180;

// Parameters (mm)
pipe_length = 150;                 //[75:300:1]
outer_diameter = 110;              //[55:220:1]
wall_thickness = 3.2;              //[1.6:6.4:0.1]
socket_length = 45;                //[20:90:1]
socket_outer_diameter = 118;       //[112:140:1]
chamfer_length = 2;                //[1:6:0.5]
overlap = 1;                       //[0.5:2:0.1]

// Derived
outer_r        = outer_diameter/2;
socket_outer_r = socket_outer_diameter/2;
inner_r        = outer_r - wall_thickness;

// Z extents (centered model)
z_min = -pipe_length/2;
z_max =  pipe_length/2;

// Socket placement (on +Z end, connected with overlap)
socket_zc = z_max - socket_length/2 + overlap;

// Chamfer centers
chamfer_plain_zc  = z_min + chamfer_length/2;
chamfer_socket_zc = z_max - chamfer_length/2;

// Geometry
module outer_shell() {
    union() {
        // Main pipe OD
        cylinder(h=pipe_length, r=outer_r, center=true);

        // Socket OD (slightly larger) on +Z end, connected
        translate([0,0,socket_zc])
            cylinder(h=socket_length, r=socket_outer_r, center=true);

        // Outer chamfer on plain end
        translate([0,0,chamfer_plain_zc])
            cylinder(h=chamfer_length,
                     r1=outer_r,
                     r2=max(outer_r - chamfer_length, 0.01),
                     center=true);

        // Outer chamfer on socket end
        translate([0,0,chamfer_socket_zc])
            cylinder(h=chamfer_length,
                     r1=socket_outer_r,
                     r2=max(socket_outer_r - chamfer_length, 0.01),
                     center=true);
    }
}

module inner_void() {
    // Make the bore longer than the entire outer shell (including socket)
    // so both ends are open and the hollow is visible in orthographic views.
    total_outer_len = pipe_length + socket_length; // conservative
    cylinder(h=total_outer_len + 4*overlap, r=inner_r, center=true);
}

module complete_model() {
    difference() {
        outer_shell();
        inner_void();
    }
}

// Final Output
color([0.85, 0.85, 0.8])
complete_model();