$fn = 64;

// Target overall bracket size (X,Y,Z) = [28,28,20]
size_x = 28;
size_y = 28;
size_z = 20;

// Leg thickness (planar width of each leg)
leg_w = 10;

// Inner corner relief radius (concave)
inner_relief_r = 2;

// Outer corner rounding radius (convex) to avoid razor edges
outer_round_r = 2;

// Mounting holes (through Z)
hole_d = 5;
hole_edge_margin = 6;   // from outer edges to hole center
hole_from_inner = 8;    // minimum from inner corner to hole center along each leg

// Small overlap to guarantee manifold unions/differences
eps = 0.25;

function clamp(v, lo, hi) = max(lo, min(hi, v));

module l_profile_2d() {
    // L shape in +X,+Y quadrant with inner corner at (0,0)
    // Add outer rounding by minkowski, then cut inner relief.
    difference() {
        // Outer rounding (convex) on the L outline
        minkowski() {
            union() {
                square([size_x - 2*outer_round_r, leg_w - 2*outer_round_r], center=false);
                square([leg_w - 2*outer_round_r, size_y - 2*outer_round_r], center=false);
            }
            circle(r=outer_round_r);
        }

        // Inner corner relief (concave quarter-circle cut)
        // Place circle at inner corner; only the part inside the L is removed.
        translate([0, 0]) circle(r=inner_relief_r);
    }
}

module l_bracket_body() {
    // Extrude the 2D profile to Z
    linear_extrude(height=size_z, center=true, convexity=10)
        l_profile_2d();
}

module mounting_holes() {
    // Hole centers computed from dimensions (no arbitrary offsets)
    // X-leg hole: near +X outer edge, centered in leg width
    hx1 = clamp(size_x - hole_edge_margin, hole_from_inner, size_x - hole_from_inner);
    hy1 = leg_w/2;

    // Y-leg hole: near +Y outer edge, centered in leg width
    hx2 = leg_w/2;
    hy2 = clamp(size_y - hole_edge_margin, hole_from_inner, size_y - hole_from_inner);

    translate([hx1, hy1, 0])
        cylinder(d=hole_d, h=size_z + 2*eps, center=true);

    translate([hx2, hy2, 0])
        cylinder(d=hole_d, h=size_z + 2*eps, center=true);
}

module extrusion_corner_bracket() {
    // Build in +X,+Y then shift so overall bounding box is centered at origin
    translate([-size_x/2, -size_y/2, 0])
    difference() {
        l_bracket_body();
        mounting_holes();
    }
}

extrusion_corner_bracket();