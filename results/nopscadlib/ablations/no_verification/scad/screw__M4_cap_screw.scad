$fn = 96;

// Target screw: socket head cap screw
nominal_diameter_mm   = 4.0;   // shank diameter
length_under_head_mm  = 10.0;  // under-head length
head_diameter_mm      = 7.0;   // head diameter
head_height_mm        = 4.0;   // head height

// Socket (hex recess) for M4 SHCS (typical)
hex_socket_af_mm      = 3.0;   // across flats
hex_socket_depth_mm   = 2.5;   // recess depth

// Simple thread appearance (optional visual ridges; not true helical)
thread_pitch_mm       = 0.7;
thread_coverage_ratio = 1.0;
thread_radial_amplitude_mm = 0.15;

// Small overlaps to ensure one connected solid
overlap_mm = 0.2;

// Derived
shank_r = nominal_diameter_mm/2;
head_r  = head_diameter_mm/2;

module hex_prism(af, h, center=false) {
    // Regular hex with across-flats = af
    // For a regular hex: across-flats = 2*apothem, apothem = R*cos(30) => R = af / sqrt(3)
    R = af / sqrt(3);
    linear_extrude(height=h, center=center, convexity=10)
        polygon(points=[for (i=[0:5]) [R*cos(60*i), R*sin(60*i)]]);
}

module faux_threads(len, r_base, amp, pitch) {
    // Axis-aligned ring ridges to suggest threads (keeps model robust)
    turns = max(1, floor(len / pitch));
    ridge_h = min(pitch*0.45, 0.35);
    for (i = [0:turns-1]) {
        z0 = i * pitch;
        translate([0,0,z0])
            cylinder(h=ridge_h, r=r_base + amp, center=false);
    }
}

module socket_head_cap_screw(d=4, L=10, hd=7, hh=4, af=3, socket_depth=2.5) {
    sh_r = d/2;
    h_r  = hd/2;

    // Place under-head plane at z=0, shank extends to -L, head to +hh
    difference() {
        union() {
            // Shank core
            translate([0,0,-L])
                cylinder(h=L + overlap_mm, r=sh_r, center=false);

            // Faux thread ridges along shank (visual only)
            translate([0,0,-L])
                faux_threads(L*thread_coverage_ratio, sh_r, thread_radial_amplitude_mm, thread_pitch_mm);

            // Head
            cylinder(h=hh, r=h_r, center=false);

            // Small under-head fillet (conical blend) to resemble SHCS
            fillet_h = min(0.8, hh*0.25);
            translate([0,0,-fillet_h + overlap_mm])
                cylinder(h=fillet_h, r1=sh_r, r2=h_r, center=false);
        }

        // Hex socket recess from top face down
        translate([0,0,hh - socket_depth])
            hex_prism(af, socket_depth + overlap_mm, center=false);
    }
}

socket_head_cap_screw(
    d=nominal_diameter_mm,
    L=length_under_head_mm,
    hd=head_diameter_mm,
    hh=head_height_mm,
    af=hex_socket_af_mm,
    socket_depth=hex_socket_depth_mm
);