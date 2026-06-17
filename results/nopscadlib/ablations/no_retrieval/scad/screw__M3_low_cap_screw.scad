// Socket head cap screw (M3-ish) — corrected to be cylindrical head with internal hex socket,
// connected shank, and visible helical thread representation.
// Dimensions: shank_d=3.0, head_d=5.5, head_h=2.0, overall_L=10.0

$fn = 96;

// ---- Parameters ----
shank_d   = 3.0;
overall_L = 10.0;

head_d = 5.5;
head_h = 2.0;

// Internal hex socket (approx for M3)
socket_hex_af = 2.5;   // across flats
socket_depth  = 1.5;

// Thread representation
thread_pitch   = 0.5;
thread_major_d = 3.0;
thread_minor_d = 2.6;
thread_L       = overall_L - head_h;  // threaded length under head

// Small features
overlap = 0.05;
head_top_chamfer_h = 0.25;
shank_end_chamfer_h = 0.35;
underhead_fillet_r = 0.25;

// ---- Helpers ----
function hex_R_from_AF(af) = af / sqrt(3); // circumradius for regular hex given across-flats

module hex_prism(af, h, center=false) {
    linear_extrude(height=h, center=center, convexity=10)
        polygon(points=[
            for (i=[0:5]) let(a=60*i) [hex_R_from_AF(af)*cos(a), hex_R_from_AF(af)*sin(a)]
        ]);
}

// ISO-ish external thread approximation using a helical ridge (not a true profile, but clearly threaded)
module external_thread(major_d, minor_d, L, pitch) {
    turns = L / pitch;
    ridge_h = (major_d - minor_d) / 2;
    ridge_w = max(0.18, pitch * 0.35);

    union() {
        // core
        cylinder(h=L, r=minor_d/2, center=false);

        // helical ridge
        linear_extrude(height=L, twist=turns*360, slices=max(ceil(turns*40), 60), center=false, convexity=10)
            translate([minor_d/2, 0, 0])
                square([ridge_h, ridge_w], center=false);
    }
}

// ---- Main screw ----
module socket_head_cap_screw() {
    shank_L = overall_L - head_h;

    difference() {
        union() {
            // Shank + thread (from z=0 to z=shank_L)
            external_thread(thread_major_d, thread_minor_d, shank_L, thread_pitch);

            // Under-head fillet (small torus segment) to blend into head
            // Positioned at the shank/head junction (z=shank_L)
            translate([0, 0, shank_L])
                rotate_extrude(convexity=10)
                    translate([shank_d/2, 0, 0])
                        circle(r=underhead_fillet_r, $fn=48);

            // Cylindrical head (from z=shank_L to z=overall_L)
            translate([0, 0, shank_L])
                cylinder(h=head_h, r=head_d/2, center=false);
        }

        // Internal hex socket cut (from top down)
        translate([0, 0, overall_L - socket_depth])
            hex_prism(socket_hex_af, socket_depth + overlap, center=false);

        // Top chamfer on head (remove a conical ring)
        translate([0, 0, overall_L - head_top_chamfer_h])
            cylinder(h=head_top_chamfer_h + overlap,
                     r1=head_d/2 + head_top_chamfer_h,
                     r2=head_d/2 - head_top_chamfer_h,
                     center=false);

        // End chamfer on shank tip (z=0 end)
        translate([0, 0, -overlap])
            cylinder(h=shank_end_chamfer_h + overlap,
                     r1=thread_major_d/2 - shank_end_chamfer_h,
                     r2=thread_major_d/2 + shank_end_chamfer_h,
                     center=false);
    }
}

// Orient so overall length spans Z from 0..overall_L (connected solid)
socket_head_cap_screw();