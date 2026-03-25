// Dimension-calibrated (target: 0.02 x 0.03 x 0.00 mm)
scale([0.828311, 0.766697, 40.000000])
{
// C-shaped circular ring segment (planar clip) with rounded ends and one bulbous end
// All geometry is one connected solid; no extra floating parts.

$fn = 128;

// Parameters (meters in original; keep as-is)
thickness_z     = 0.0001;
outer_radius    = 0.015;
band_width      = 0.004;
gap_angle_deg   = 50;

end_round_radius = 0.002;
bulb_radius      = 0.0025;
bulb_offset      = 0.001;

overlap = 0.0005;

// Derived
inner_radius = outer_radius - band_width;
mid_radius   = outer_radius - band_width/2;

// 2D ring sector (C-shape) made by subtracting inner circle and a gap wedge
module c_ring_2d() {
    difference() {
        // annulus
        difference() {
            circle(r = outer_radius);
            circle(r = inner_radius);
        }

        // gap wedge centered on +X axis, symmetric about X
        rotate(gap_angle_deg/2)
            polygon(points = [
                [0, 0],
                [ (outer_radius + 2*overlap), 0],
                [ (outer_radius + 2*overlap)*cos(180-gap_angle_deg), (outer_radius + 2*overlap)*sin(180-gap_angle_deg) ]
            ]);
        rotate(-gap_angle_deg/2)
            polygon(points = [
                [0, 0],
                [ (outer_radius + 2*overlap), 0],
                [ (outer_radius + 2*overlap)*cos(180-gap_angle_deg), -(outer_radius + 2*overlap)*sin(180-gap_angle_deg) ]
            ]);

        // simpler robust wedge cut (covers both polygons above)
        // (kept as polygons to avoid arbitrary translations)
    }
}

// Rounded end caps + bulbous feature as 2D additions (then extruded)
module end_features_2d() {
    // Endpoints of the ring centerline at the gap edges
    // Gap is centered on +X axis; ends at angles +/- gap_angle/2
    a = gap_angle_deg/2;

    p_pos = [ mid_radius*cos(a),  mid_radius*sin(a) ];
    p_neg = [ mid_radius*cos(a), -mid_radius*sin(a) ];

    // Rounded ends: add circles at both ends (fillet-like)
    circle(r = end_round_radius, center = true, $fn = 64)
        translate(p_pos) children();
    circle(r = end_round_radius, center = true, $fn = 64)
        translate(p_neg) children();

    // Bulbous feature on the +angle end (slightly outward along radial direction)
    p_bulb = [ (mid_radius + bulb_offset)*cos(a), (mid_radius + bulb_offset)*sin(a) ];
    circle(r = bulb_radius, center = true, $fn = 64)
        translate(p_bulb) children();
}

// Helper to place a circle at a point (OpenSCAD doesn't allow circle+translate in one line with children easily)
module circle_at(pt, r) {
    translate(pt) circle(r = r);
}

module clip_2d() {
    a = gap_angle_deg/2;

    p_pos  = [ mid_radius*cos(a),  mid_radius*sin(a) ];
    p_neg  = [ mid_radius*cos(a), -mid_radius*sin(a) ];
    p_bulb = [ (mid_radius + bulb_offset)*cos(a), (mid_radius + bulb_offset)*sin(a) ];

    union() {
        // Main C-ring band
        difference() {
            difference() {
                circle(r = outer_radius);
                circle(r = inner_radius);
            }
            // Gap wedge: a large triangle sector centered on +X
            polygon(points = [
                [0, 0],
                [ (outer_radius + 2*overlap)*cos( a),  (outer_radius + 2*overlap)*sin( a)],
                [ (outer_radius + 2*overlap)*cos(-a),  (outer_radius + 2*overlap)*sin(-a)]
            ]);
        }

        // Rounded ends (2D)
        hull() {
            circle_at(p_pos, end_round_radius);
            circle_at(p_neg, end_round_radius);
        }

        // Bulbous end (2D) blended into the +end
        hull() {
            circle_at(p_pos, end_round_radius);
            circle_at(p_bulb, bulb_radius);
        }
    }
}

// Final 3D: planar extrusion with uniform thickness
linear_extrude(height = thickness_z, center = true, convexity = 10)
    clip_2d();
}
