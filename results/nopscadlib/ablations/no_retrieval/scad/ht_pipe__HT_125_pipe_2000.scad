// HT pipe: HT 125, length 2000 mm
// Oriented along X so front/back/left/right orthographic views show full length.

$fn = 128;

// Parameters
pipe_length = 2000;          //[1000:4000:10]
outer_diameter = 125;        //[62.5:250:1]
wall_thickness = 3.2;        //[1.6:6.4:0.1]
socket_length = 80;          //[40:160:1]
socket_wall_extra = 2.0;     //[1.0:4.0:0.1]
chamfer_length = 10;         //[3:25:1]
chamfer_radial = 2;          //[1:6:0.5]
overlap = 1;                 //[0.5:2:0.1]

// Derived
outer_r = outer_diameter/2;
inner_r = outer_r - wall_thickness;
socket_r = outer_r + socket_wall_extra;

// Base shapes (built along Z, then rotated to X in final)
module pipe_outer_z() {
    cylinder(h=pipe_length, r=outer_r, center=true);
}

module pipe_bore_z() {
    cylinder(h=pipe_length + 2*overlap, r=inner_r, center=true);
}

module socket_outer_z() {
    // Socket centered so it overlaps the pipe body by "overlap"
    translate([0, 0, pipe_length/2 - socket_length/2 + overlap])
        cylinder(h=socket_length, r=socket_r, center=true);
}

module chamfer_ring_z() {
    // A short ring that removes material at the end (outer chamfer)
    difference() {
        cylinder(h=chamfer_length, r=outer_r + overlap, center=true);
        cylinder(h=chamfer_length + 2*overlap, r=outer_r - chamfer_radial, center=true);
    }
}

module pipe_solid_z() {
    difference() {
        union() {
            pipe_outer_z();
            socket_outer_z(); // connected via overlap
        }
        pipe_bore_z();
    }
}

module pipe_with_chamfers_z() {
    difference() {
        pipe_solid_z();
        // Remove outer chamfer at both ends of the main pipe body
        translate([0, 0,  pipe_length/2 - chamfer_length/2]) chamfer_ring_z();
        translate([0, 0, -pipe_length/2 + chamfer_length/2]) chamfer_ring_z();
    }
}

// Final output: rotate so length is along X (fixes orthographic views)
rotate([0, 90, 0])
    pipe_with_chamfers_z();