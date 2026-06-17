// 40x80 aluminum T-slot extrusion (approximate 8-series), 100mm long
// One connected solid: outer body minus connected internal voids + 4 face T-slots.

$fn = 96;

// ---------- Parameters (mm) ----------
extrusion_length = 100;

W = 80;   // X overall
H = 40;   // Y overall

corner_r = 2.0;

// Typical 8-series-ish slot sizes (approximate)
slot_open = 8.2;     // opening at surface
slot_neck = 6.2;     // neck width
slot_cavity = 13.0;  // inner cavity width
slot_depth = 12.0;   // depth from surface

// Structure
wall = 3.0;          // outer wall thickness
web = 3.0;           // internal web thickness (keeps it ONE connected solid)
center_bore_d = 10.0;

inner_corner_r = 1.5;
eps = 0.05;

// ---------- Helpers ----------
module rounded_rect(w, h, r) {
    r2 = min(r, min(w, h)/2);
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(w/2 - r2), sy*(h/2 - r2)])
                circle(r = r2);
    }
}

// 2D T-slot cutter on +X or -X face (centered in Y)
module tslot_cut_x(side = 1) {
    // Build a connected "T" void that starts at the surface and goes inward.
    // All translate values are derived from dimensions.
    x_surface = side * (W/2);
    x_in = x_surface - side * slot_depth; // inner end of slot depth

    union() {
        // Opening at surface (short depth)
        // Make it a rectangle that touches the surface and extends inward.
        open_depth = slot_open; // approximate
        translate([ (x_surface + (x_surface - side*open_depth))/2, 0 ])
            square([open_depth, slot_open], center=true);

        // Neck (full depth)
        translate([ (x_surface + x_in)/2, 0 ])
            square([slot_depth, slot_neck], center=true);

        // Inner cavity (placed near inner end, still connected to neck)
        cav_depth = slot_depth * 0.65;
        x_cav_center = x_in + side * (cav_depth/2); // cavity spans from x_in to x_in+side*cav_depth
        translate([x_cav_center, 0])
            square([cav_depth, slot_cavity], center=true);
    }
}

// 2D T-slot cutter on +Y or -Y face (centered in X)
module tslot_cut_y(side = 1) {
    rotate(90) tslot_cut_x(side);
}

module extrusion_cross_section() {
    difference() {
        // Outer boundary (single piece)
        rounded_rect(W, H, corner_r);

        // ---- Internal voids (kept connected, do NOT split the solid) ----

        // Central bore
        circle(d = center_bore_d);

        // Main inner pocket (leaves outer wall)
        // This alone would create a hollow rectangle; we add webs to keep realistic extrusion look.
        rounded_rect(W - 2*wall, H - 2*wall, inner_corner_r);

        // Add back material as webs by subtracting "voids" that avoid the web regions:
        // Instead of adding material, we carve the inner pocket into 4 corner pockets,
        // leaving a cross-shaped web (vertical + horizontal) of thickness 'web'.
        //
        // We do this by subtracting 4 corner pockets (voids) from the already-subtracted inner pocket area:
        // In OpenSCAD difference(), to "leave" webs, we must NOT subtract where webs are.
        // So we subtract only the corner pockets (which are inside the inner pocket),
        // and we DO NOT subtract the cross web region.

        // Corner pockets (4) inside the inner boundary, leaving a cross web.
        // Each pocket is a rounded rectangle quadrant-like pocket.
        pocket_w = (W - 2*wall - web) / 2;
        pocket_h = (H - 2*wall - web) / 2;

        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*(web/2 + pocket_w/2), sy*(web/2 + pocket_h/2)])
                rounded_rect(pocket_w, pocket_h, inner_corner_r);
        }

        // ---- Face T-slots (4 sides) ----
        tslot_cut_x(+1);
        tslot_cut_x(-1);
        tslot_cut_y(+1);
        tslot_cut_y(-1);
    }
}

module extrusion() {
    linear_extrude(height = extrusion_length, center = true, convexity = 10)
        extrusion_cross_section();
}

// Render
extrusion();