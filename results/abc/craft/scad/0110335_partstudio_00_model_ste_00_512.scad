// Dimension-calibrated (target: 0.15 x 0.38 x 0.06 mm)
scale([0.947500, 0.590009, 1.293112])
{
// Long prismatic bar with recessed panels on broad faces,
// chamfered/mitred perimeter corners, and shallow concave top/bottom
// across width with a central longitudinal rib/step.
//
// Target bounding box (approx): 0.1 x 0.4 x 0.1 mm  =>  H x L x W
// Here: L=0.40, W=0.10, H=0.10 (mm)

$fn = 128;

// -------------------- Parameters (mm) --------------------
L = 0.40;   // length (X)
W = 0.10;   // width  (Y)
H = 0.10;   // height (Z)

// Recessed panel on broad faces (top & bottom)
recess_margin_L = 0.03;
recess_margin_W = 0.015;
recess_depth    = 0.010;

// Perimeter chamfer (mitred corners around full perimeter)
chamfer = 0.010;

// Shallow concave curvature across width (top & bottom)
concave_sag = 0.006;   // sagitta across chord W (per face)

// Central longitudinal rib/step on top and bottom
rib_W = 0.030;         // rib width across Y
rib_H = 0.008;         // rib height above the concave surface
rib_margin_L = 0.03;   // keep rib away from ends

// Small epsilon for robust booleans (tiny, since model is tiny)
eps = 0.0005;

// -------------------- Helpers --------------------
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

recess_L = clamp(L - 2*recess_margin_L, eps, L - eps);
recess_W = clamp(W - 2*recess_margin_W, eps, W - eps);
rib_L    = clamp(L - 2*rib_margin_L, eps, L - eps);

// Radius for a circular arc that gives sagitta = concave_sag over chord W
// R = W^2/(8s) + s/2
R = (W*W)/(8*concave_sag) + concave_sag/2;

// -------------------- Geometry modules --------------------
module base_block() {
    cube([L, W, H], center=true);
}

// Perimeter chamfer wedges (subtractive)
module perimeter_chamfers() {
    // Long edges along X (at Y=±W/2, Z=±H/2)
    for (sy = [-1, 1], sz = [-1, 1]) {
        translate([0, sy*(W/2 - chamfer/2), sz*(H/2 - chamfer/2)])
            rotate([0, 90, 0])
                linear_extrude(height=L + 2*eps, center=true)
                    polygon(points=[
                        [-chamfer/2 - eps, -chamfer/2 - eps],
                        [ chamfer/2 + eps, -chamfer/2 - eps],
                        [-chamfer/2 - eps,  chamfer/2 + eps]
                    ]);
    }

    // End edges along Y (at X=±L/2, Z=±H/2)
    for (sx = [-1, 1], sz = [-1, 1]) {
        translate([sx*(L/2 - chamfer/2), 0, sz*(H/2 - chamfer/2)])
            rotate([90, 0, 0])
                linear_extrude(height=W + 2*eps, center=true)
                    polygon(points=[
                        [-chamfer/2 - eps, -chamfer/2 - eps],
                        [ chamfer/2 + eps, -chamfer/2 - eps],
                        [-chamfer/2 - eps,  chamfer/2 + eps]
                    ]);
    }

    // Vertical edges along Z (at X=±L/2, Y=±W/2)
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx*(L/2 - chamfer/2), sy*(W/2 - chamfer/2), 0])
            linear_extrude(height=H + 2*eps, center=true)
                polygon(points=[
                    [-chamfer/2 - eps, -chamfer/2 - eps],
                    [ chamfer/2 + eps, -chamfer/2 - eps],
                    [-chamfer/2 - eps,  chamfer/2 + eps]
                ]);
    }
}

// Recessed rectangular panel on top face (subtractive)
module top_recess() {
    // Cut starts at top surface and goes downward
    translate([0, 0, H/2 - recess_depth/2])
        cube([recess_L, recess_W, recess_depth + 2*eps], center=true);
}

// Recessed rectangular panel on bottom face (subtractive)
module bottom_recess() {
    // Cut starts at bottom surface and goes upward
    translate([0, 0, -H/2 + recess_depth/2])
        cube([recess_L, recess_W, recess_depth + 2*eps], center=true);
}

// Concave cut across width on top face (cylindrical surface along X).
// IMPORTANT FIX: limit the cutter to only the top region so we don't remove the whole block.
// We intersect the cylinder with a thin "cap" volume above the top face.
module top_concave_cut() {
    cap_h = concave_sag + 4*eps; // only remove a shallow band
    intersection() {
        // Cylinder positioned so it just kisses the top plane at the edges (y=±W/2)
        translate([0, 0, H/2 + (R - concave_sag)])
            rotate([0, 90, 0])
                cylinder(r=R, h=L + 2*eps, center=true);

        // Limit to a thin slab at the top surface
        translate([0, 0, H/2 - cap_h/2 + eps])
            cube([L + 4*eps, W + 4*eps, cap_h], center=true);
    }
}

// Concave cut across width on bottom face (limited to bottom region)
module bottom_concave_cut() {
    cap_h = concave_sag + 4*eps;
    intersection() {
        translate([0, 0, -H/2 - (R - concave_sag)])
            rotate([0, 90, 0])
                cylinder(r=R, h=L + 2*eps, center=true);

        translate([0, 0, -H/2 + cap_h/2 - eps])
            cube([L + 4*eps, W + 4*eps, cap_h], center=true);
    }
}

// Central longitudinal rib/step on top and bottom (additive)
// IMPORTANT FIX: place ribs ON the concave faces (not embedded inside the block).
module ribs() {
    overlap = 2*eps;

    // Top rib: sits above the (now concave) top surface, with slight overlap into body
    translate([0, 0, H/2 + rib_H/2 - overlap])
        cube([rib_L, rib_W, rib_H + 2*overlap], center=true);

    // Bottom rib: sits below the concave bottom surface, with slight overlap into body
    translate([0, 0, -H/2 - rib_H/2 + overlap])
        cube([rib_L, rib_W, rib_H + 2*overlap], center=true);
}

// -------------------- Final solid --------------------
module part() {
    union() {
        // Main body with chamfers, recesses, and concave top/bottom
        difference() {
            base_block();

            perimeter_chamfers();

            top_recess();
            bottom_recess();

            top_concave_cut();
            bottom_concave_cut();
        }

        // Add ribs after concave cuts so they remain visible and create the arched/stepped profile
        ribs();
    }
}

part();
}
