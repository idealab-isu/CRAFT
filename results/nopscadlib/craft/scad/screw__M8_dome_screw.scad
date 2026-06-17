// Dome head screw (single connected solid)
// Requested: 8.0mm thread diameter, 14.0mm head diameter, 4.4mm head height, 10mm length under head

$fn = 128;

// Parameters
thread_diameter    = 8.0;
length_under_head  = 10.0;
head_diameter      = 14.0;
head_height        = 4.4;

// Simple thread approximation (visual helical ridge)
thread_pitch       = 1.25;   // typical for M8 coarse
thread_depth       = 0.45;   // radial height of ridge (visual)
thread_ridge_w     = 0.55;   // ridge thickness (mm)
thread_start_taper = 1.2;    // lead-in length (mm)

// Tip
tip_length         = 1.5;
tip_end_radius     = 0.6;    // small flat at tip

// Hex socket (internal)
socket_af          = 5.0;
socket_depth       = 3.0;

// Robust overlap for unions/differences
eps = 0.05;

// REQUIRED: ensure physical attachment with 1-2mm overlap
overlap = 1.0; // mm (guarantees tip intersects threaded core)

// Helpers
function hex_R_from_AF(af) = af / (2 * cos(30)); // circumradius for hex

module dome_head(head_d, head_h) {
    // Spherical cap: sphere intersected with a slab of height head_h
    // Base at z=0, top at z=head_h
    intersection() {
        translate([0,0, head_h - head_d/2])
            sphere(r=head_d/2);
        translate([0,0, head_h/2])
            cube([head_d*2, head_d*2, head_h], center=true);
    }
}

module helical_thread(major_d, length, pitch, depth, ridge_w, start_taper) {
    major_r = major_d/2;
    minor_r = max(major_r - depth, 0.1);
    turns   = length / pitch;

    union() {
        // Core (minor diameter) centered at z=0
        cylinder(h=length, r=minor_r, center=true);

        // Helical ridge centered at z=0
        intersection() {
            linear_extrude(height=length, twist=turns*360,
                           slices=max(ceil(turns*60), 80), center=true, convexity=10)
                translate([minor_r, -ridge_w/2, 0])
                    square([depth, ridge_w], center=false);

            // Envelope to keep ridge within major diameter and apply lead-in taper near tip (bottom end)
            union() {
                cylinder(h=length + 2*eps, r=major_r + eps, center=true);

                if (start_taper > 0) {
                    translate([0,0, -length/2 + start_taper/2])
                        cylinder(h=start_taper + 2*eps,
                                 r1=minor_r + eps, r2=major_r + eps, center=true);
                }
            }
        }
    }
}

module screw() {
    major_r = thread_diameter/2;
    minor_r = max(major_r - thread_depth, 0.1);

    // Coordinate system:
    // Head base at z=0, head extends to +head_height
    // Shank extends from z=0 down to z=-length_under_head
    // Tip extends further down by tip_length
    difference() {
        union() {
            // Dome head
            dome_head(head_diameter, head_height);

            // Threaded shank: center at z = -length_under_head/2 so top is exactly at z=0
            translate([0,0, -length_under_head/2])
                helical_thread(thread_diameter, length_under_head,
                              thread_pitch, thread_depth, thread_ridge_w, thread_start_taper);

            // Tip: MUST overlap into the shank by 'overlap' to avoid any gap/floating piece.
            // Shank bottom is at z = -length_under_head.
            // Tip top is set to z = -length_under_head + overlap (intersects shank core/ridge).
            // With center=true, top = zc + h/2 => zc = top - h/2
            tip_h = tip_length + 2*eps;
            tip_top_z = -length_under_head + overlap;
            tip_center_z = tip_top_z - tip_h/2;

            translate([0,0, tip_center_z])
                cylinder(h=tip_h, r1=minor_r, r2=tip_end_radius, center=true);
        }

        // Hex socket cut into head (internal drive)
        translate([0,0, head_height - socket_depth/2 + eps])
            cylinder(h=socket_depth + 2*eps, r=hex_R_from_AF(socket_af), $fn=6, center=true);
    }
}

screw();