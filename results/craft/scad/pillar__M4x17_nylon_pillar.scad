// Standoff pillar: M4 internal thread, 20mm long, 8mm OD
// One connected solid (body minus threaded hole)

$fn = 96;

// Parameters (fixed to requested spec)
thread_diameter_mm = 4.0;     // M4 nominal major diameter
thread_pitch_mm    = 0.7;     // M4 coarse pitch
length_mm          = 20.0;    // overall length
outer_diameter_mm  = 8.0;     // body diameter

// Small edge break (visual + print-friendly)
edge_chamfer_mm    = 0.4;

// Thread modeling controls
thread_clearance_mm = 0.15;   // enlarge internal thread slightly for fit
thread_depth_mm     = 0.35;   // radial thread depth (approx for M4)
thread_steps_per_turn = 28;   // smoothness of helix

// ---- Helpers ----
module chamfered_cylinder(h, d, c) {
    // c is chamfer size along Z and radial
    // Implemented as hull of two slightly smaller cylinders
    hull() {
        translate([0,0,-h/2 + c/2])
            cylinder(h=c, d=d - 2*c, center=true);
        translate([0,0, h/2 - c/2])
            cylinder(h=c, d=d - 2*c, center=true);
        cylinder(h=h - c, d=d, center=true);
    }
}

// Internal ISO-like thread approximation using a helical triangular ridge,
// then subtracted from the body to create a threaded hole.
module internal_thread_hole(major_d, pitch, length, depth, clearance) {
    // For internal thread, the "hole" major diameter is slightly larger than nominal.
    major_r = (major_d + clearance)/2;
    minor_r = major_r - depth;

    // Ensure valid geometry
    minor_r_safe = max(minor_r, 0.2);

    turns = length / pitch;
    slices = max(ceil(turns * thread_steps_per_turn), 20);

    // 2D profile in X-Y plane (to be twisted along Z):
    // A ring sector with a triangular notch that forms the thread flank.
    // We build a polygon in (radius, z) then rotate_extrude? Not possible with twist.
    // Instead: linear_extrude with twist of a 2D polygon in X-Y.
    // The polygon is a "tooth" that spans radially from minor_r to major_r.
    tooth_w = pitch * 0.55; // tangential thickness of the tooth in 2D profile

    // The helical cutter is union of:
    // - a core cylinder at minor diameter (guarantees through-hole)
    // - a twisted tooth that reaches up to major diameter (creates thread form)
    union() {
        // Core through-hole at minor diameter
        cylinder(h=length + 0.6, r=minor_r_safe, center=true);

        // Helical tooth cutter
        translate([0,0,-length/2 - 0.3])
            linear_extrude(height=length + 0.6, twist=turns*360, slices=slices, convexity=10)
                polygon(points=[
                    [minor_r_safe, -tooth_w/2],
                    [major_r,      0],
                    [minor_r_safe,  tooth_w/2]
                ]);
    }
}

// ---- Main part ----
module standoff_pillar_M4_L20_D8() {
    difference() {
        // Body
        chamfered_cylinder(h=length_mm, d=outer_diameter_mm, c=edge_chamfer_mm);

        // Threaded hole (through)
        internal_thread_hole(
            major_d = thread_diameter_mm,
            pitch   = thread_pitch_mm,
            length  = length_mm,
            depth   = thread_depth_mm,
            clearance = thread_clearance_mm
        );
    }
}

standoff_pillar_M4_L20_D8();