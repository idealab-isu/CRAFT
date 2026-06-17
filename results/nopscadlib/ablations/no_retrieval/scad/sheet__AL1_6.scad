// Aluminium tooling plate (single connected solid)
// Fixes: robust chamfers/fillets (no over-subtraction), adds tooling-plate hole grid + counterbores

$fn = 96;

// Parameters
plate_length = 300; //[150:600:1]
plate_width  = 200; //[100:400:1]
plate_thickness = 12; //[6:24:1]

corner_chamfer = 10; //[5:20:1]          // 45° chamfer size on top/bottom edges
edge_fillet_radius = 2; //[1:6:1]        // rounded outer vertical edges

// Tooling features (distinguishing)
hole_pitch = 50; //[25:100:1]
hole_d = 10; //[6:16:1]                  // through hole diameter
counterbore_d = 18; //[12:30:1]          // counterbore diameter (both faces)
counterbore_depth = 3; //[1:6:0.5]
edge_margin = 25; //[10:60:1]            // keep holes away from edges

// Robust boolean overlap
eps = 0.2;

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Base plate with rounded vertical edges (fillet) using minkowski
module rounded_plate(L, W, T, r) {
    // Ensure valid core dimensions
    coreL = max(0.01, L - 2*r);
    coreW = max(0.01, W - 2*r);
    minkowski() {
        cube([coreL, coreW, T], center=true);
        cylinder(r=r, h=eps, center=true);
    }
}

// 45° chamfer ring around top/bottom perimeter (keeps solid connected)
module chamfer_cut(L, W, T, c) {
    // Limit chamfer so it can't erase the plate
    c_eff = clamp(c, 0, min(L, W)/2 - 0.01);

    // Outer prism slightly larger than plate footprint
    outer = [L + 2*eps, W + 2*eps, T + 2*c_eff + 2*eps];
    // Inner prism slightly smaller than plate footprint
    inner = [max(0.01, L - 2*c_eff), max(0.01, W - 2*c_eff), T + 2*eps];

    // Subtracting this from the plate creates a 45° chamfer on both faces
    difference() {
        cube(outer, center=true);
        cube(inner, center=true);
    }
}

// Hole grid with counterbores on both faces
module tooling_holes(L, W, T, pitch, d_thru, d_cb, cb_depth, margin) {
    // Compute grid counts (at least 1 if space allows)
    usableL = max(0, L - 2*margin);
    usableW = max(0, W - 2*margin);

    nx = usableL >= 0 ? floor(usableL / pitch) + 1 : 0;
    ny = usableW >= 0 ? floor(usableW / pitch) + 1 : 0;

    // Center the grid within usable area
    spanX = (nx > 1) ? (nx - 1) * pitch : 0;
    spanY = (ny > 1) ? (ny - 1) * pitch : 0;

    for (ix = [0 : max(nx-1, -1)]) {
        for (iy = [0 : max(ny-1, -1)]) {
            x = -spanX/2 + ix*pitch;
            y = -spanY/2 + iy*pitch;

            // Through hole
            translate([x, y, 0])
                cylinder(d=d_thru, h=T + 2*eps, center=true);

            // Top counterbore
            translate([x, y,  T/2 - cb_depth/2 + eps/2])
                cylinder(d=d_cb, h=cb_depth + eps, center=true);

            // Bottom counterbore
            translate([x, y, -T/2 + cb_depth/2 - eps/2])
                cylinder(d=d_cb, h=cb_depth + eps, center=true);
        }
    }
}

// Final model
difference() {
    // Main solid
    rounded_plate(plate_length, plate_width, plate_thickness, edge_fillet_radius);

    // Chamfers (top & bottom perimeter)
    chamfer_cut(plate_length, plate_width, plate_thickness, corner_chamfer);

    // Tooling hole pattern (distinguishing feature)
    tooling_holes(
        plate_length, plate_width, plate_thickness,
        hole_pitch, hole_d, counterbore_d, counterbore_depth, edge_margin
    );
}