// M5 grub screw (set screw) with external thread + internal hex socket + cup point
// One connected solid, no floating parts, all placements derived from dimensions.

$fn = 96;

// ---- Parameters (mm) ----
screw_length      = 10;     // overall length
major_diameter    = 5;      // M5 major diameter
pitch             = 0.8;    // M5 coarse pitch
minor_diameter    = 4.2;    // approximate M5 minor diameter (visual/printable)
thread_depth      = (major_diameter - minor_diameter)/2;

socket_af         = 2.5;    // internal hex across flats (approx for M5 grub)
socket_depth      = 3.0;    // socket depth
socket_chamfer    = 0.4;    // small lead-in chamfer

cup_depth         = 0.8;    // cup point depth
cup_diameter      = 3.2;    // cup diameter
end_chamfer       = 0.35;   // small chamfer on both ends

eps = 0.02;

// ---- Helpers ----
function hex_R_from_AF(af) = af / sqrt(3); // circumradius for hex polygon with given across-flats

module hex_prism(af, h, center=false) {
    r = hex_R_from_AF(af);
    cylinder(h=h, r=r, $fn=6, center=center);
}

// Robust external thread approximation: helical "band" made from a 2D rectangle
// rotated around Z while extruding along Z. This avoids degenerate geometry.
module external_thread(major_d, minor_d, pitch, length) {
    turns  = length / pitch;
    r0     = minor_d/2;
    tdepth = max((major_d - minor_d)/2, 0.01);
    band_w = pitch * 0.55;

    // Place the band so its inner edge slightly overlaps the core cylinder
    // to guarantee a single connected solid.
    overlap = 0.05;
    rotate_extrude(angle=360, convexity=10)
        translate([r0 - overlap, 0, 0])
            square([tdepth + overlap, band_w], center=false);

    // The above creates a ring; now make it helical by twisting a linear extrusion
    // of the same band around Z.
    // (We union both: the helical part provides the thread look; the ring ensures
    // connectivity even if the helical band gets thin at some slicer settings.)
    linear_extrude(height=length, twist=turns*360, slices=max(ceil(turns*60), 120), convexity=10)
        translate([r0 - overlap, 0, 0])
            square([tdepth + overlap, band_w], center=false);
}

module grub_screw() {
    difference() {
        union() {
            // Core cylinder (minor diameter)
            cylinder(h=screw_length, d=minor_diameter, center=false);

            // External thread (connected via small radial overlap into core)
            external_thread(major_diameter, minor_diameter, pitch, screw_length);

            // End chamfers as frustums that overlap the body slightly
            // Top chamfer
            translate([0, 0, screw_length - end_chamfer])
                cylinder(h=end_chamfer + eps,
                         d1=major_diameter,
                         d2=max(major_diameter - 2*end_chamfer, 0.1),
                         center=false);

            // Bottom chamfer
            translate([0, 0, -eps])
                cylinder(h=end_chamfer + eps,
                         d1=max(major_diameter - 2*end_chamfer, 0.1),
                         d2=major_diameter,
                         center=false);
        }

        // Internal hex socket cut from top
        translate([0, 0, screw_length - socket_depth])
            hex_prism(socket_af, socket_depth + eps, center=false);

        // Lead-in chamfer for socket
        translate([0, 0, screw_length - socket_chamfer])
            hex_prism(socket_af + 0.6, socket_chamfer + eps, center=false);

        // Cup point at bottom (concave)
        // Use a sphere intersected with a cylinder, positioned to remove from bottom face.
        intersection() {
            cylinder(h=cup_depth + eps, d=cup_diameter, center=false);
            translate([0, 0, cup_depth])
                sphere(d=cup_diameter);
        }
    }
}

// Render
grub_screw();