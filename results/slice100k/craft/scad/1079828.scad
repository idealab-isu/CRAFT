// Long thin strip with shallow saddle (V) along length + subtle end steps + mid seam
// Bounding box target: 61.0 x 12.8 x 5.1 mm

L = 60.96;          // X length
W = 12.77;          // Y width
H = 5.08;           // Z overall height (top is flat)

v_depth = 1.20;       // ends are higher (bottom closer to top) by this amount vs center
end_step_len = 4.0;   // shoulder length at each end
end_step_drop = 0.60; // extra thickness at ends (bottom lower) by this amount

mid_seam_len = 6.0;   // subtle mid transition length
mid_seam_drop = 0.25; // extra thickness at mid (bottom lower) by this amount

overlap = 0.20;
$fn = 64;

// --- Profiles along X (length) ---
function saddle_raise(x) =
    v_depth * (abs(x) / (L/2)); // 0 at center, v_depth at ends (linear "V")

function end_drop(x) =
    (abs(x) >= (L/2 - end_step_len)) ? end_step_drop : 0;

function mid_drop(x) =
    (abs(x) <= (mid_seam_len/2)) ? mid_seam_drop : 0;

// Bottom Z at given x (top is fixed at +H/2)
function bottom_z(x) =
    (-H/2) + saddle_raise(x) - end_drop(x) - mid_drop(x);

// Build watertight solid by extruding an XZ polygon along Y (width).
module strip_solid() {
    n = 180;
    dx = L / n;

    pts_top = [ for (i = [0:n]) [ -L/2 + i*dx,  H/2 ] ];
    pts_bot = [ for (i = [n:-1:0]) [ -L/2 + i*dx, bottom_z(-L/2 + i*dx) ] ];
    pts = concat(pts_top, pts_bot);

    // Correct orientation: polygon in XZ, extrude along Y, centered about Y=0.
    translate([0, -W/2, 0])
        linear_extrude(height=W, center=false, convexity=10)
            polygon(points=pts);
}

// Small chamfers on the long top edges (kept subtle).
module edge_soften() {
    cham = 0.35;
    difference() {
        children();

        // Remove tiny wedges along the two long top edges
        for (sy = [-1, 1]) {
            translate([0, sy*(W/2 - cham/2), H/2 - cham/2])
                rotate([0, 45*sy, 0])  // slight bevel feel without changing overall size much
                    cube([L + 2*overlap, cham, cham], center=true);
        }
    }
}

module final_model() {
    edge_soften()
        strip_solid();
}

final_model();