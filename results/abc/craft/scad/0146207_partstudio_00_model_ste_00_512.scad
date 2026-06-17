// Dimension-calibrated (target: 0.16 x 0.27 x 0.03 mm)
scale([0.900000, 0.617761, 5.090909])
{
// Thin faceplate with rounded-rect plate, 4 corner holes,
// 2 opposite diamond tabs with holes, and a raised octagonal bezel
// around a recessed rectangular pocket.
//
// Bounding box target: 0.2 x 0.3 x ~0 (very thin / plate-like)

$fn = 64;

// --- Target overall size (X x Y) ---
L = 0.30;          // overall length (X)
W = 0.20;          // overall width  (Y)

// --- Thicknesses (keep very thin) ---
T = 0.004;         // base plate thickness (near-zero but renderable)
bezel_h = 0.002;   // raised bezel height above plate
pocket_depth = 0.002; // recessed pocket depth into plate

// --- Plate corner rounding ---
corner_r = 0.015;

// --- Corner fastener holes ---
hole_d = 0.010;
hole_edge_offset_L = 0.025;  // from left/right edges
hole_edge_offset_W = 0.020;  // from top/bottom edges

// --- Diamond tabs (on midpoints of two opposite sides: +/-Y) ---
tab_out = 0.020;        // how far tab protrudes beyond plate edge (Y direction)
tab_half_width = 0.020; // half width of diamond (X direction)
tab_thickness = T;      // same as plate thickness
tab_hole_d = 0.010;

// --- Central bezel (octagon) and pocket ---
bezel_flat_to_flat = 0.090; // outer octagon flat-to-flat
bezel_wall = 0.010;         // ring wall thickness (flat-to-flat difference/2 approx)
pocket_L = 0.090;
pocket_W = 0.050;

eps = 0.0005;

// ---------- Helpers ----------
function clamp(x,a,b) = x < a ? a : (x > b ? b : x);

// Regular octagon points for a given circumradius
module octagon_2d(R){
    polygon(points=[
        [ R, 0],
        [ R*0.70710678,  R*0.70710678],
        [ 0,  R],
        [-R*0.70710678,  R*0.70710678],
        [-R, 0],
        [-R*0.70710678, -R*0.70710678],
        [ 0, -R],
        [ R*0.70710678, -R*0.70710678]
    ]);
}

// Rounded rectangle 2D (robust, no skew/chamfer artifacts)
module rounded_rect_2d(l, w, r){
    r2 = clamp(r, 0, min(l,w)/2 - eps);
    hull(){
        for (sx=[-1,1], sy=[-1,1])
            translate([sx*(l/2 - r2), sy*(w/2 - r2)])
                circle(r=r2);
    }
}

// Diamond tab 2D (pointing outward in +Y by default)
module diamond_2d(half_w, out){
    polygon(points=[
        [ half_w, 0],
        [ 0, out],
        [-half_w, 0],
        [ 0,-out]
    ]);
}

// ---------- Main solids ----------
module plate_with_tabs_solid(){
    union(){
        // Main rounded rectangle plate
        linear_extrude(height=T, center=true)
            rounded_rect_2d(L, W, corner_r);

        // Two opposite diamond tabs centered on midpoints of +/-Y sides
        // Place so inner diamond vertex slightly overlaps plate edge for connectivity.
        tab_center_y = W/2 + tab_out/2 - eps;

        for (sy=[-1,1])
            translate([0, sy*tab_center_y, 0])
                linear_extrude(height=tab_thickness, center=true)
                    diamond_2d(tab_half_width, tab_out);
    }
}

module all_through_holes_cut(){
    union(){
        // 4 corner holes (near corners of the rounded rectangle)
        xh = L/2 - hole_edge_offset_L;
        yh = W/2 - hole_edge_offset_W;

        for (sx=[-1,1], sy=[-1,1])
            translate([sx*xh, sy*yh, 0])
                cylinder(d=hole_d, h=T + 6*eps, center=true);

        // Tab holes (centered in each diamond tab)
        tab_center_y = W/2 + tab_out/2 - eps;
        for (sy=[-1,1])
            translate([0, sy*tab_center_y, 0])
                cylinder(d=tab_hole_d, h=T + 6*eps, center=true);
    }
}

module bezel_ring_solid(){
    // Convert flat-to-flat to circumradius: R = (flat/2)/cos(22.5°)
    // cos(22.5)=0.9238795325
    outer_R = (bezel_flat_to_flat/2) / 0.9238795325;
    inner_flat = bezel_flat_to_flat - 2*bezel_wall;
    inner_R = ((inner_flat/2) / 0.9238795325);

    translate([0,0, T/2 + bezel_h/2 - eps])  // sit on top of plate with slight overlap
    linear_extrude(height=bezel_h, center=true)
        difference(){
            octagon_2d(outer_R);
            octagon_2d(inner_R);
        }
}

module pocket_cut(){
    // Recessed rectangular pocket inside the bezel (cut down from top surface)
    // Ensure it doesn't cut through the whole plate.
    d = clamp(pocket_depth, eps, T - eps);

    translate([0,0, T/2 - d/2 + eps])
        cube([pocket_L, pocket_W, d + 4*eps], center=true);
}

// ---------- Final ----------
difference(){
    union(){
        difference(){
            plate_with_tabs_solid();
            all_through_holes_cut();
        }
        bezel_ring_solid();
    }
    pocket_cut();
}
}
