// HT pipe: HT 50, length 1000 mm
// Model oriented along X so front/back/left/right orthographic views show the pipe length.

$fn = 128;

// Parameters
pipe_length = 1000;              //[500:2000:1]
outer_diameter = 50;             //[25:100:0.5]
wall_thickness = 1.8;            //[0.9:3.6:0.1]
socket_length = 60;              //[30:120:1]
socket_outer_diameter = 56;      //[52:70:0.5]
chamfer_length = 2;              //[1:6:0.5]
overlap = 1;                     //[0.5:2:0.1]

// Derived
outer_r = outer_diameter/2;
inner_r = outer_r - wall_thickness;
socket_r = socket_outer_diameter/2;

// Safety
inner_r_safe = max(0.01, inner_r);

// Helpers: cylinders along X axis
module cyl_x(h, r, center=true) {
    rotate([0, 90, 0]) cylinder(h=h, r=r, center=center);
}
module cyl_x_taper(h, r1, r2, center=true) {
    rotate([0, 90, 0]) cylinder(h=h, r1=r1, r2=r2, center=center);
}

// Main model (one connected solid)
module ht_pipe() {
    difference() {
        // Outer solid: main pipe + socket (connected with overlap)
        union() {
            // Main outer body
            cyl_x(pipe_length, outer_r, center=true);

            // Socket at +X end, overlapping into main body by "overlap"
            translate([pipe_length/2 - socket_length/2 + overlap, 0, 0])
                cyl_x(socket_length, socket_r, center=true);

            // Small outer chamfer at -X end (kept connected by overlap)
            translate([-pipe_length/2 + chamfer_length/2 - overlap, 0, 0])
                cyl_x_taper(chamfer_length, outer_r, max(0.01, outer_r - chamfer_length), center=true);
        }

        // Inner bore: through entire length + socket, leaving wall thickness
        // Extend beyond both ends to guarantee clean subtraction
        cyl_x(pipe_length + socket_length + 4*overlap, inner_r_safe, center=true);

        // Optional: slightly larger bore inside socket region (typical socket clearance)
        // Keeps a single connected solid while making socket visibly distinct.
        translate([pipe_length/2 - socket_length/2 + overlap, 0, 0])
            cyl_x(socket_length + 2*overlap, min(socket_r - 0.5, inner_r_safe + 1.0), center=true);
    }
}

// Final Output
color([0.85, 0.85, 0.8])
ht_pipe();