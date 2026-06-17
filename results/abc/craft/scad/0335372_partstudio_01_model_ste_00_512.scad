// Dimension-calibrated (target: 0.02 x 0.03 x 0.00 mm)
scale([1.195661, 1.250000, 4.000000])
{
// C-shaped circular clip (planar extrusion) with rounded ends and one slightly bulbous end.
// Single connected solid, no extra bodies.

// ---------- Parameters (meters in original; keep as-is) ----------
bbox_X = 0.03; //[0.015:0.06:0.001]
bbox_Y = 0.02; //[0.01:0.04:0.001]
bbox_Z = 0.0;  //[0.0:0.2:0.001]

t_eps = 0.001; //[0.0005:0.01:0.0005]

R_outer = 0.01; //[0.005:0.02:0.0005]
band_W  = 0.003; //[0.0015:0.006:0.0005]

gap_ang_deg = 60; //[20:140:5]   // total opening angle

end_round_r = 0.0015; //[0.00075:0.003:0.00025]
bulb_scale  = 1.25;   //[1.0:1.8:0.05]

// ---------- Derived ----------
thickness    = max(bbox_Z, t_eps);
R_inner      = max(R_outer - band_W, 0.0001);
R_mid        = (R_outer + R_inner) / 2;
gap_half     = gap_ang_deg / 2;

// Resolution
$fn = 128;

// ---------- Helpers ----------
module ring2d() {
    difference() {
        circle(r = R_outer);
        circle(r = R_inner);
    }
}

// 2D wedge that removes the gap (centered on +X axis)
module gap_wedge2d() {
    // Make wedge large enough to cover the ring area
    Rw = R_outer + 2*end_round_r + 0.002;
    polygon(points = [
        [0, 0],
        [Rw*cos(-gap_half), Rw*sin(-gap_half)],
        [Rw*cos( gap_half), Rw*sin( gap_half)]
    ]);
}

// Rounded end caps (2D) placed at the two gap edges on the mid-radius
module end_caps2d() {
    // Edge angles of the remaining arc are +/- gap_half
    for (s = [-1, 1]) {
        a = s * gap_half;
        translate([R_mid*cos(a), R_mid*sin(a)])
            circle(r = end_round_r);
    }
}

// Slightly bulbous enlargement on one end (choose +gap_half end)
module bulb2d() {
    a = gap_half;
    translate([R_mid*cos(a), R_mid*sin(a)])
        circle(r = end_round_r * bulb_scale);
}

// ---------- Main 2D profile ----------
module clip_profile2d() {
    // Build a smooth C-clip: ring minus wedge, then add rounded ends and bulb.
    union() {
        difference() {
            ring2d();
            gap_wedge2d();
        }
        end_caps2d();
        bulb2d();
    }
}

// ---------- 3D ----------
linear_extrude(height = thickness, center = true, convexity = 10)
    clip_profile2d();
}
