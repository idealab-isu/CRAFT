// Pan head screw (connected solid)
// Target: shank Ø3.5, head Ø6.9, head height 2.5, overall length 10

$fn = 96;

// --- Parameters (mm) ---
shank_d = 3.5;
length  = 10;

head_d  = 6.9;
head_h  = 2.5;

// Simple thread representation (rings) kept subtle
thread_pitch   = 0.7;
thread_len     = 8;          // threaded length from tip upward
thread_radial  = 0.18;
thread_ring_h  = 0.25;

// Tip
tip_chamfer_h = 0.6;
tip_end_d     = 0.6;         // small flat at tip

// Drive (Phillips-like cross)
drive_d     = 3.0;
drive_depth = 1.4;
drive_arm_w = 0.8;

// Rounding / fillets (kept small, within head envelope)
underhead_fillet_r = 0.35;
head_edge_round_r  = 0.35;

// Robust overlap to ensure single connected solid
overlap = 0.2;

// --- Derived Z layout ---
// Place tip at z=0, head top at z=length
z_tip        = 0;
z_shank_top  = length - head_h;   // underside of head
z_head_bot   = z_shank_top;
z_head_top   = length;

// Thread region
z_thread_start = z_tip;
z_thread_end   = min(z_tip + thread_len, z_shank_top);

// --- Helpers ---
module thread_rings() {
    // Rings overlap the shank so union is watertight
    n = max(0, floor((z_thread_end - z_thread_start) / thread_pitch));
    for (i = [0:n]) {
        zc = z_thread_start + i*thread_pitch + thread_ring_h/2;
        if (zc + thread_ring_h/2 <= z_thread_end + 1e-6)
            translate([0,0,zc])
                cylinder(h=thread_ring_h + overlap, r=shank_d/2 + thread_radial, center=true);
    }
}

module tip_chamfer() {
    // Cone from shank diameter down to small tip flat
    translate([0,0, z_tip + tip_chamfer_h/2])
        cylinder(h=tip_chamfer_h + overlap, r1=tip_end_d/2, r2=shank_d/2, center=true);
}

module shank() {
    // Main shank up to underside of head
    translate([0,0, (z_tip + z_shank_top)/2])
        cylinder(h=(z_shank_top - z_tip) + overlap, r=shank_d/2, center=true);
}

module underhead_fillet() {
    // Small torus-like fillet at shank/head junction (adds material, stays within head diameter)
    // Positioned so it bridges shank to head underside.
    translate([0,0, z_head_bot + underhead_fillet_r - overlap/2])
        rotate_extrude()
            translate([shank_d/2, 0, 0])
                circle(r=underhead_fillet_r, $fn=48);
}

module pan_head_solid() {
    // Rounded pan head made by hulling two cylinders:
    // - bottom cylinder at full head diameter
    // - top cylinder slightly smaller to create a dome-like profile
    top_d = max(head_d - 2*head_edge_round_r, head_d*0.78);

    hull() {
        // Bottom (underside) disk
        translate([0,0, z_head_bot + overlap/2])
            cylinder(h=overlap, r=head_d/2, center=true);

        // Main head body (near bottom)
        translate([0,0, z_head_bot + head_h*0.45])
            cylinder(h=head_h*0.55, r=head_d/2, center=true);

        // Top crown (smaller) to round the head
        translate([0,0, z_head_top - head_edge_round_r])
            cylinder(h=2*head_edge_round_r, r=top_d/2, center=true);
    }
}

module drive_recess() {
    // Cross recess cut from the top, depth limited to drive_depth
    zc = z_head_top - drive_depth/2;
    translate([0,0,zc])
        union() {
            cube([drive_d, drive_arm_w, drive_depth + overlap], center=true);
            cube([drive_arm_w, drive_d, drive_depth + overlap], center=true);
        }
}

module screw() {
    difference() {
        union() {
            // Body
            shank();
            tip_chamfer();
            thread_rings();

            // Head + fillet (all connected by shared z_head_bot plane with overlap)
            pan_head_solid();
            underhead_fillet();
        }
        // Drive cut
        drive_recess();
    }
}

// Final
screw();