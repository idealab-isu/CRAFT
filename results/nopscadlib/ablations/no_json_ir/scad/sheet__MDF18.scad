// Sheet MDF (single connected solid, no text)

// Parameters
sheet_length    = 200;
sheet_width     = 100;
sheet_thickness = 5;

corner_radius   = 5;   // rounded corners
edge_chamfer    = 2;   // top-edge chamfer amount

$fn = 64;

// 2D rounded rectangle (solid)
module rounded_rect_2d(L, W, R) {
    R2 = min(R, min(L, W)/2);
    offset(r=R2)
        square([L - 2*R2, W - 2*R2], center=true);
}

// 3D sheet with rounded corners and a top chamfer (connected solid)
module mdf_sheet() {
    R = min(corner_radius, min(sheet_length, sheet_width)/2);
    c = min(edge_chamfer, sheet_thickness);

    union() {
        // Base slab up to (thickness - chamfer)
        linear_extrude(height = sheet_thickness - c)
            rounded_rect_2d(sheet_length, sheet_width, R);

        // Chamfered top section: slightly smaller footprint, placed to touch base
        translate([0, 0, sheet_thickness - c])
            linear_extrude(height = c, scale = (sheet_length - 2*c)/sheet_length)
                rounded_rect_2d(sheet_length - 2*c, sheet_width - 2*c, max(0, R - c));
    }
}

mdf_sheet();