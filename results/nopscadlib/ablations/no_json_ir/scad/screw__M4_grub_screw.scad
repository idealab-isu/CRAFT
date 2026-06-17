// M4 grub (set) screw with visible external threads, internal hex socket, and cup-point tip.
// FIX: ensure no floating/disconnected geometry by keeping ALL features inside one union/difference,
// and by using meaningful overlaps (1–2mm) for all subtractive cuts.

$fn = 96;

// --- Parameters (mm) ---
shaft_diameter   = 4;      // M4 major diameter
shaft_length     = 8;      // overall length
pitch            = 0.7;    // M4 coarse pitch
thread_depth     = 0.35;   // radial thread height (visual/printable)
hex_socket_af    = 2;      // internal hex across flats (approx for M4)
hex_socket_depth = shaft_length * 0.35;
hex_clearance    = 0.15;   // extra clearance for socket
cup_depth        = 0.6;    // cup point depth
cup_diameter     = shaft_diameter * 0.75;
end_chamfer      = 0.25;   // small edge break

// Structural overlap to guarantee boolean connectivity (1–2mm as required)
overlap = 1.0;

// --- Helpers ---
function hex_r_from_af(af) = af / sqrt(3); // circumradius for regular hex given across-flats

module hex_prism(af, h, center=false) {
    r = hex_r_from_af(af);
    linear_extrude(height=h, center=center, convexity=10)
        polygon([for (i=[0:5]) [r*cos(60*i), r*sin(60*i)]]);
}

// External thread approximation: helical ridge around a core cylinder
module external_thread(d_major, length, pitch, depth) {
    r_major = d_major/2;
    r_core  = r_major - depth;

    union() {
        // Core
        cylinder(r=r_core, h=length, center=false);

        // Helical ridge (rect section swept with twist)
        linear_extrude(height=length, twist=360*length/pitch,
                       slices=max(ceil(length*24), 60), convexity=10)
            translate([r_core, 0, 0])
                square([depth, pitch*0.35], center=true);
    }
}

// Cup point cut at the tip (bottom end) - SUBTRACTIVE
module cup_point_cut(d_cup, depth) {
    // Start slightly below z=0 and extend upward past the intended depth
    // so it always intersects the body (prevents "floating" artifacts).
    translate([0,0,-overlap])
        cylinder(h=depth + 2*overlap,
                 r1=d_cup/2,
                 r2=max(d_cup/2 - depth*0.6, 0.2),
                 center=false);
}

// Small chamfer at ends (subtractive)
module end_chamfer_cut(d_major, chamfer_h, at_top=false, total_h=10) {
    r = d_major/2 + 0.2;
    if (!at_top) {
        // bottom chamfer: extend below 0 to guarantee intersection
        translate([0,0,-overlap])
            cylinder(h=chamfer_h + 2*overlap,
                     r1=r,
                     r2=max(r - chamfer_h, 0.01),
                     center=false);
    } else {
        // top chamfer: extend above total_h to guarantee intersection
        translate([0,0,total_h - chamfer_h - overlap])
            cylinder(h=chamfer_h + 2*overlap,
                     r1=max(r - chamfer_h, 0.01),
                     r2=r,
                     center=false);
    }
}

// --- Main ---
module grub_screw() {
    union() {
        difference() {
            // Solid body with threads (single solid base)
            external_thread(shaft_diameter, shaft_length, pitch, thread_depth);

            // Internal hex socket from top face downward
            // Extend slightly above the top face and deeper by overlap to ensure a clean, connected cut.
            translate([0,0,shaft_length - hex_socket_depth - overlap])
                hex_prism(hex_socket_af + hex_clearance, hex_socket_depth + 2*overlap, center=false);

            // Cup point at bottom (subtractive) - guaranteed to intersect
            cup_point_cut(cup_diameter, cup_depth);

            // End chamfers (top and bottom) - guaranteed to intersect
            end_chamfer_cut(shaft_diameter, end_chamfer, at_top=false, total_h=shaft_length);
            end_chamfer_cut(shaft_diameter, end_chamfer, at_top=true,  total_h=shaft_length);
        }
    }
}

grub_screw();