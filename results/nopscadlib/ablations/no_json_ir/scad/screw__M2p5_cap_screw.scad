// Socket head cap screw (M2.5-ish) per requested dimensions
// Shank: 2.5mm dia, 10mm long
// Head: 4.5mm dia, 2.5mm tall
// Hex socket: 2mm across flats (approx), recessed from top

$fn = 96;

// Parameters
shank_diameter   = 2.5;
shank_length     = 10;

head_diameter    = 4.5;
head_height      = 2.5;

hex_af           = 2.0;   // across flats
socket_depth     = 1.6;   // typical recess depth (kept within head height)
socket_top_margin= 0.2;   // material above socket
overlap          = 0.05;  // small overlap to ensure watertight union/difference

// Hex prism sized by across-flats (AF)
module hex_prism_af(af, h) {
    // For a regular hexagon: AF = 2 * apothem; circumradius R = AF / sqrt(3)
    R = af / sqrt(3);
    cylinder(h=h, r=R, $fn=6);
}

module shank() {
    cylinder(d=shank_diameter, h=shank_length, center=false);
}

module head() {
    difference() {
        cylinder(d=head_diameter, h=head_height, center=false);

        // Cut socket from the top down
        // Place so the top of the cut is slightly above the head to guarantee a clean opening
        translate([0, 0, head_height - socket_top_margin - socket_depth])
            hex_prism_af(hex_af, socket_depth + socket_top_margin + overlap);
    }
}

module screw() {
    union() {
        shank();
        // Head sits on top of shank with slight overlap to ensure one connected solid
        translate([0, 0, shank_length - overlap])
            head();
    }
}

screw();