// Sheet: carbon fiber (single connected solid with subtle woven relief)
// Parameters
length = 100;          // X
width  = 50;           // Y
thickness = 2;         // Z
corner_radius = 5;     // rounded corners
edge_chamfer = 0.6;    // small bevel on top/bottom edges

// Weave relief (very shallow so it still reads as a sheet)
weave_pitch = 4;       // spacing between weave ridges
weave_amp   = 0.12;    // height of weave ridges (keep small)
weave_w     = 0.7;     // ridge width

$fn = 64;

// 2D rounded rectangle
module rounded_rect_2d(L, W, R) {
    // robust rounded rectangle using minkowski
    minkowski() {
        square([L - 2*R, W - 2*R], center=true);
        circle(r=R);
    }
}

// 3D sheet with chamfered edges (via hull between two rounded rectangles)
module chamfered_sheet(L, W, T, R, C) {
    // Clamp chamfer so geometry stays valid
    c = min(C, T/2 - 0.001, R - 0.001);

    hull() {
        // bottom face (slightly inset)
        translate([0, 0, -T/2])
            linear_extrude(height=0.001)
                rounded_rect_2d(L - 2*c, W - 2*c, R - c);

        // top face (slightly inset)
        translate([0, 0,  T/2 - 0.001])
            linear_extrude(height=0.001)
                rounded_rect_2d(L - 2*c, W - 2*c, R - c);

        // mid body (full size)
        translate([0, 0, -0.0005])
            linear_extrude(height=0.001)
                rounded_rect_2d(L, W, R);
    }
}

// Subtle woven relief on top surface (kept inside perimeter)
module weave_relief(L, W, T, R, pitch, amp, ridge_w) {
    inset = max(R + 1, pitch); // keep ridges away from rounded corners/edges
    x0 = -L/2 + inset;
    x1 =  L/2 - inset;
    y0 = -W/2 + inset;
    y1 =  W/2 - inset;

    // Place ridges so they are guaranteed to intersect the sheet (connected solid)
    z_base = T/2 - amp; // ridges sit on top surface with full contact

    union() {
        // 0° ridges
        for (y = [y0 : pitch : y1]) {
            translate([0, y, z_base])
                cube([ (x1 - x0), ridge_w, amp ], center=true);
        }

        // 90° ridges
        for (x = [x0 : pitch : x1]) {
            translate([x, 0, z_base])
                cube([ ridge_w, (y1 - y0), amp ], center=true);
        }

        // Clip relief to the sheet outline so nothing protrudes outside
        intersection() {
            // relief union above
            children();
            // clipping volume: slightly smaller than sheet top area
            translate([0, 0, T/2 - amp/2])
                linear_extrude(height=amp + 0.001, center=true)
                    rounded_rect_2d(L - 2*inset, W - 2*inset, max(0.01, R - inset));
        }
    }
}

// Assemble: one connected solid
union() {
    chamfered_sheet(length, width, thickness, corner_radius, edge_chamfer);

    // Add subtle weave as real geometry (still one solid)
    weave_relief(length, width, thickness, corner_radius, weave_pitch, weave_amp, weave_w)
        union() {
            // pass-through placeholder for intersection() children()
            // (actual ridges are created inside weave_relief via children())
        };
}

// Rebuild weave_relief with proper children content (OpenSCAD needs explicit children usage)
module weave_relief(L, W, T, R, pitch, amp, ridge_w) {
    inset = max(R + 1, pitch);
    x0 = -L/2 + inset;
    x1 =  L/2 - inset;
    y0 = -W/2 + inset;
    y1 =  W/2 - inset;

    z_base = T/2 - amp;

    intersection() {
        union() {
            for (y = [y0 : pitch : y1])
                translate([0, y, z_base])
                    cube([ (x1 - x0), ridge_w, amp ], center=true);

            for (x = [x0 : pitch : x1])
                translate([x, 0, z_base])
                    cube([ ridge_w, (y1 - y0), amp ], center=true);
        }

        translate([0, 0, T/2 - amp/2])
            linear_extrude(height=amp + 0.01, center=true)
                rounded_rect_2d(L - 2*inset, W - 2*inset, max(0.01, R - inset));
    }
}