$fn = 96;

// DiBond sheet parameters
sheet_length    = 200;
sheet_width     = 100;
sheet_thickness = 3;

corner_radius   = 5;
hole_diameter   = 5;

// DiBond construction (two aluminum skins + PE core)
skin_thickness  = 0.3;                         // each aluminum skin
core_thickness  = sheet_thickness - 2*skin_thickness;

// Edge detail
edge_reveal     = 0.35;                        // inset of skins from outer edge to reveal core
chamfer_size    = 0.6;                         // small edge chamfer
eps             = 0.02;

// 2D rounded rectangle
module rr2d(L, W, R) {
    offset(r=R)
        square([L - 2*R, W - 2*R], center=true);
}

// 2D hole pattern
module corner_holes_2d(L, W, R, d) {
    for (sx = [-1, 1], sy = [-1, 1])
        translate([sx*(L/2 - R), sy*(W/2 - R)])
            circle(d=d);
}

// 3D layer with holes
module layer_with_holes(zc, h, L, W, R, d) {
    translate([0, 0, zc])
        linear_extrude(height=h, center=true)
            difference() {
                rr2d(L, W, R);
                corner_holes_2d(L, W, R, d);
            }
}

// Main DiBond sheet (single connected solid)
module dibond_sheet() {
    // Guard against invalid thickness
    core_t = (core_thickness > 0) ? core_thickness : 0.01;

    // Outer silhouette for chamfering (no holes)
    module outer_solid() {
        linear_extrude(height=sheet_thickness, center=true)
            rr2d(sheet_length, sheet_width, corner_radius);
    }

    // Chamfer cutter (slightly larger, tapered)
    module chamfer_cutter() {
        translate([0, 0, 0])
            linear_extrude(height=sheet_thickness + 2*eps, center=true, scale=0.985)
                offset(delta=chamfer_size)
                    rr2d(sheet_length, sheet_width, corner_radius);
    }

    // Build: chamfered outer, then subtract holes, then union in skins+core (all overlap -> connected)
    difference() {
        // Chamfered outer body
        difference() {
            outer_solid();
            chamfer_cutter();
        }

        // Through holes
        translate([0, 0, 0])
            linear_extrude(height=sheet_thickness + 2*eps, center=true)
                corner_holes_2d(sheet_length, sheet_width, corner_radius, hole_diameter);
    }

    // Add internal material structure (skins inset to reveal core at edge)
    union() {
        // Core (full outline)
        layer_with_holes(
            zc = 0,
            h  = core_t,
            L  = sheet_length,
            W  = sheet_width,
            R  = corner_radius,
            d  = hole_diameter
        );

        // Front skin (inset)
        layer_with_holes(
            zc = (core_t/2 + skin_thickness/2) - eps,
            h  = skin_thickness + 2*eps,
            L  = sheet_length - 2*edge_reveal,
            W  = sheet_width  - 2*edge_reveal,
            R  = max(0.01, corner_radius - edge_reveal),
            d  = hole_diameter
        );

        // Back skin (inset)
        layer_with_holes(
            zc = -(core_t/2 + skin_thickness/2) + eps,
            h  = skin_thickness + 2*eps,
            L  = sheet_length - 2*edge_reveal,
            W  = sheet_width  - 2*edge_reveal,
            R  = max(0.01, corner_radius - edge_reveal),
            d  = hole_diameter
        );
    }
}

dibond_sheet();