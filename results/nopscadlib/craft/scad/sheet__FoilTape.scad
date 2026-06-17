// Aluminium foil tape sheet (flat) - ONE connected solid
// Fixes: removes roll/core, makes a flat sheet with subtle foil-like crinkle,
// consistent in all views, and keeps everything connected via union/overlap.

// ---------------- Parameters ----------------
sheet_len = 120;          //[50:250:1]
sheet_w   = 50;           //[20:150:1]
foil_t    = 0.08;         //[0.04:0.20:0.01]  // physical foil thickness (very thin)
adh_t     = 0.03;         //[0.01:0.10:0.01]  // adhesive layer
liner_t   = 0.06;         //[0.03:0.20:0.01]  // backing/liner (kept as part of single solid)
corner_r  = 2;            //[0.5:8:0.5]

// Foil texture (subtle crinkle)
crinkle_amp   = 0.18;     //[0.05:0.6:0.01]   // height variation (visual only)
crinkle_pitch = 10;       //[4:25:1]          // spacing of crinkles
crinkle_seed  = 7;        //[0:50:1]

// Edge detail
edge_bead = 0.35;         //[0.1:1:0.05]      // tiny rolled edge bead radius (visual)

// ---------------- Derived ----------------
eps = 0.2;
total_t = max(0.6, foil_t + adh_t + liner_t); // ensure visible thickness in CAD
r2 = min(corner_r, min(sheet_len, sheet_w)/2 - 0.01);

// ---------------- Helpers ----------------
module rounded_rect_2d(l, w, r) {
    rr = min(r, min(l, w)/2 - 0.01);
    hull() {
        for (sx=[-1,1], sy=[-1,1])
            translate([sx*(l/2 - rr), sy*(w/2 - rr)])
                circle(r=rr, $fn=48);
    }
}

function hash01(i) = let(x = sin((i + 1) * 12.9898 + crinkle_seed * 78.233) * 43758.5453)
                     x - floor(x);

module crinkle_field(l, w, amp, pitch) {
    // Creates a connected "wrinkle" skin on the top surface by hulling small bumps.
    // All bumps overlap slightly to ensure connectivity.
    nx = max(2, floor(l / pitch));
    ny = max(2, floor(w / pitch));
    dx = l / nx;
    dy = w / ny;

    // Use hull between neighboring bumps to avoid disconnected islands.
    for (ix = [0:nx-2])
    for (iy = [0:ny-2]) {
        // Four corners of a cell
        p00 = [ -l/2 + (ix+0)*dx, -w/2 + (iy+0)*dy ];
        p10 = [ -l/2 + (ix+1)*dx, -w/2 + (iy+0)*dy ];
        p01 = [ -l/2 + (ix+0)*dx, -w/2 + (iy+1)*dy ];
        p11 = [ -l/2 + (ix+1)*dx, -w/2 + (iy+1)*dy ];

        // Heights (deterministic pseudo-random)
        h00 = (hash01(ix*1000 + iy*10 + 0) - 0.5) * 2 * amp;
        h10 = (hash01(ix*1000 + iy*10 + 1) - 0.5) * 2 * amp;
        h01 = (hash01(ix*1000 + iy*10 + 2) - 0.5) * 2 * amp;
        h11 = (hash01(ix*1000 + iy*10 + 3) - 0.5) * 2 * amp;

        // Small bump radius; overlap ensures continuous surface
        br = min(dx, dy) * 0.55;

        hull() {
            translate([p00[0], p00[1], h00]) cylinder(r=br, h=eps, center=true, $fn=18);
            translate([p10[0], p10[1], h10]) cylinder(r=br, h=eps, center=true, $fn=18);
            translate([p01[0], p01[1], h01]) cylinder(r=br, h=eps, center=true, $fn=18);
            translate([p11[0], p11[1], h11]) cylinder(r=br, h=eps, center=true, $fn=18);
        }
    }
}

module edge_beads(l, w, r, bead_r, h) {
    // Tiny rounded beads along the perimeter to suggest a foil edge.
    // Built as 4 capsules (hulls of spheres) and overlapped into the sheet.
    zc = h/2 - bead_r; // keep bead within thickness
    rr = min(r, min(l, w)/2 - 0.01);

    // Straight segments endpoints (inset by corner radius)
    x0 = -l/2 + rr;
    x1 =  l/2 - rr;
    y0 = -w/2 + rr;
    y1 =  w/2 - rr;

    // Beads overlap into sheet by bead_r
    union() {
        // Top edge
        hull() {
            translate([x0,  w/2 - bead_r, zc]) sphere(r=bead_r, $fn=24);
            translate([x1,  w/2 - bead_r, zc]) sphere(r=bead_r, $fn=24);
        }
        // Bottom edge
        hull() {
            translate([x0, -w/2 + bead_r, zc]) sphere(r=bead_r, $fn=24);
            translate([x1, -w/2 + bead_r, zc]) sphere(r=bead_r, $fn=24);
        }
        // Right edge
        hull() {
            translate([ l/2 - bead_r, y0, zc]) sphere(r=bead_r, $fn=24);
            translate([ l/2 - bead_r, y1, zc]) sphere(r=bead_r, $fn=24);
        }
        // Left edge
        hull() {
            translate([-l/2 + bead_r, y0, zc]) sphere(r=bead_r, $fn=24);
            translate([-l/2 + bead_r, y1, zc]) sphere(r=bead_r, $fn=24);
        }
    }
}

// ---------------- Model ----------------
module aluminium_foil_tape_sheet() {
    union() {
        // Base sheet (single solid slab)
        linear_extrude(height=total_t, center=true, convexity=10)
            rounded_rect_2d(sheet_len, sheet_w, r2);

        // Crinkle texture on top surface (kept connected by overlapping into slab)
        // Place it so its bottom intersects the slab by eps.
        translate([0, 0, total_t/2 - eps])
            crinkle_field(sheet_len, sheet_w, crinkle_amp, crinkle_pitch);

        // Subtle edge bead detail (also overlaps into slab)
        edge_beads(sheet_len, sheet_w, r2, min(edge_bead, total_t*0.45), total_t);
    }
}

// Final output
aluminium_foil_tape_sheet();