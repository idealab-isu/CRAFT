$fn = 96;

// Parameters (mm)
shank_d = 3.0;                 // shaft diameter
screw_L = 10.0;                // overall length (tip to top of head)
head_af = 6.4;                 // hex across flats
head_H = 2.125;                // head height
thread_L = 7.875;              // threaded length from tip upward
thread_pitch = 0.5;            // decorative ring pitch
overlap = 0.15;                // small overlap to guarantee connectivity/robust booleans
head_chamfer = 0.4;            // top edge chamfer height
tip_chamfer = 0.6;             // tip chamfer height
fillet_r = 0.5;                // under-head fillet radius
drive_mark_d = 1.6;            // top mark diameter
drive_mark_depth = 0.3;        // top mark depth
thread_ring_depth = 0.15;      // decorative ring depth (radial)
thread_ring_width = 0.2;       // decorative ring axial width

// Derived
shank_L = screw_L - head_H;                 // length under head
z_tip = -screw_L/2;
z_head_top = screw_L/2;
z_head_bot = z_head_top - head_H;
z_shank_top = z_head_bot;                   // shank meets head bottom
z_shank_bot = z_tip;                        // shank ends at tip

// Hex geometry: across flats -> circumradius
hex_R = head_af / sqrt(3);

// Base shapes (all positioned by formulas so parts connect)
module shank_cyl() {
    // Centered on shank span
    translate([0, 0, (z_shank_top + z_shank_bot)/2])
        cylinder(h=shank_L + overlap, r=shank_d/2, center=true);
}

module hex_head_prism() {
    translate([0, 0, (z_head_top + z_head_bot)/2])
        linear_extrude(height=head_H + overlap, center=true)
            polygon(points=[
                [ hex_R, 0],
                [ hex_R/2,  head_af/2],
                [-hex_R/2,  head_af/2],
                [-hex_R, 0],
                [-hex_R/2, -head_af/2],
                [ hex_R/2, -head_af/2]
            ]);
}

module under_head_fillet() {
    // Quarter-round fillet connecting shank to head underside
    // Place torus so its lowest Z touches shank top and highest Z touches head bottom.
    translate([0, 0, z_shank_top + fillet_r - overlap])
        rotate_extrude(convexity=10)
            translate([shank_d/2 + fillet_r, 0, 0])
                circle(r=fillet_r);
}

module head_top_chamfer_cutter() {
    // Cut a shallow chamfer from the top of the hex head
    // Use a frustum that intersects only the top region.
    translate([0, 0, z_head_top - head_chamfer/2])
        cylinder(h=head_chamfer + overlap,
                 r1=hex_R + head_chamfer,
                 r2=hex_R - head_chamfer,
                 center=true);
}

module tip_chamfer_cutter() {
    // Cut a conical chamfer at the tip
    translate([0, 0, z_tip + tip_chamfer/2])
        cylinder(h=tip_chamfer + overlap,
                 r1=shank_d/2 + tip_chamfer,
                 r2=0,
                 center=true);
}

module drive_mark_cutter() {
    translate([0, 0, z_head_top - drive_mark_depth/2])
        cylinder(h=drive_mark_depth + overlap, r=drive_mark_d/2, center=true);
}

module thread_ring_cutter(zpos) {
    // A shallow ring groove (decorative) cut into the shank
    translate([0, 0, zpos])
        difference() {
            cylinder(h=thread_ring_width + overlap, r=shank_d/2 + overlap, center=true);
            cylinder(h=thread_ring_width + 2*overlap, r=shank_d/2 - thread_ring_depth, center=true);
        }
}

module screw_solid() {
    union() {
        shank_cyl();
        hex_head_prism();
        under_head_fillet();
    }
}

module screw_with_details() {
    difference() {
        screw_solid();

        // Top chamfer
        head_top_chamfer_cutter();

        // Tip chamfer
        tip_chamfer_cutter();

        // Drive mark
        drive_mark_cutter();

        // Decorative thread rings along the lower threaded length
        // Start slightly above the tip chamfer and stop before the head underside.
        z_thread_start = z_tip + tip_chamfer + thread_ring_width/2;
        z_thread_end   = z_tip + thread_L - thread_ring_width/2;

        for (zpos = [z_thread_start : thread_pitch : z_thread_end])
            thread_ring_cutter(zpos);
    }
}

// Final Output (single connected solid)
color("DimGray") screw_with_details();