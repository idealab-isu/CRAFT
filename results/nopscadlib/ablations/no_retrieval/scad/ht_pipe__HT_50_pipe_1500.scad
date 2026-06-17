// HT pipe: HT 50, length 1500 mm
// One connected solid, no floating parts, no text/labels.

// Parameters
pipe_length = 1500;              //[750:3000:10]
outer_diameter = 50;             //[25:100:1]
wall_thickness = 1.8;            //[0.9:3.6:0.1]

socket_length = 60;              //[30:120:1]
socket_outer_diameter = 56;      //[52:70:1]
socket_wall_thickness = 2.2;     //[1.1:4.4:0.1]

overlap = 1;                     //[0.5:2:0.1]
chamfer_length = 2;              //[1:6:0.5]
chamfer_radial = 1;              //[0.5:3:0.5]

$fn = 128;

// Derived
pipe_r   = outer_diameter/2;
pipe_ri  = pipe_r - wall_thickness;

socket_r  = socket_outer_diameter/2;
socket_ri = socket_r - socket_wall_thickness;

// Place socket at +Z end of pipe, overlapping into pipe by "overlap"
socket_center_z = (pipe_length/2 - socket_length/2) + overlap;

// Helpers
module tube(h, ro, ri, center=true) {
    difference() {
        cylinder(h=h, r=ro, center=center);
        cylinder(h=h + 2*overlap, r=ri, center=center);
    }
}

module ht50_pipe_1500() {

    // Build as a Z-axis pipe, then rotate so the 1500 mm length runs along X.
    // This makes front/back/left/right orthographic views show the long body.
    rotate([0,90,0])
    difference() {

        // Outer connected solid
        union() {
            // Main pipe outer
            cylinder(h=pipe_length, r=pipe_r, center=true);

            // Socket outer (overlaps into pipe by overlap)
            translate([0,0,socket_center_z])
                cylinder(h=socket_length, r=socket_r, center=true);
        }

        // Inner voids (single connected cavity)
        union() {
            // Main bore through entire pipe
            cylinder(h=pipe_length + 2*overlap, r=pipe_ri, center=true);

            // Socket bore (slightly longer to ensure clean subtraction)
            translate([0,0,socket_center_z])
                cylinder(h=socket_length + 2*overlap, r=socket_ri, center=true);
        }

        // Chamfer cuts (simple conical cuts at both ends)
        // Pipe end at -Z
        translate([0,0,-pipe_length/2])
            cylinder(h=chamfer_length + overlap,
                     r1=pipe_r + chamfer_radial,
                     r2=pipe_r - chamfer_radial,
                     center=false);

        // Socket far end at +Z (socket extends beyond pipe end by overlap)
        socket_far_end_z = socket_center_z + socket_length/2;
        translate([0,0,socket_far_end_z - overlap])
            cylinder(h=chamfer_length + overlap,
                     r1=socket_r - chamfer_radial,
                     r2=socket_r + chamfer_radial,
                     center=false);
    }
}

ht50_pipe_1500();