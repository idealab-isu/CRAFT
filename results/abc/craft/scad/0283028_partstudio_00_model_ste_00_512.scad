$fn = 64;

// Parameters (kept as given; units are whatever the user provided)
L = 0.14; //[0.07:0.28:0.001]
W = 0.03; //[0.015:0.06:0.001]
H = 0.02; //[0.01:0.04:0.001]

end_len = 0.025; //[0.0125:0.05:0.001]
web_thk = 0.004; //[0.002:0.008:0.0005]

cut_L = 0.09; //[0.045:0.18:0.001]
cut_W = 0.022; //[0.011:0.044:0.001]

hole_d = 0.004; //[0.002:0.008:0.0005]
hole_offset_x = 0.008; //[0.004:0.016:0.0005]
hole_offset_y = 0.006; //[0.003:0.012:0.0005]

csk_d = 0.007; //[0.0035:0.014:0.0005]
csk_depth = 0.003; //[0.0015:0.006:0.0005]

chamfer = 0.0008; //[0.0:0.0016:0.0001]

// Numerical robustness
eps = 0.002;          // also used as "overlap" for watertight booleans
overlap = eps;

// Derived / safety clamps
end_len2  = min(end_len, max(eps, (L - cut_L)/2));
cut_L2    = min(cut_L, max(eps, L - 2*end_len2));
cut_W2    = min(cut_W, max(eps, W - 2*eps));
web_thk2  = min(web_thk, max(eps, H/2 - eps));
chamfer2  = min(chamfer, min(L, min(W, H))/10);

// Make the U-channel clearly visible: remove underside material in the central span,
// leaving a top "roof" thickness = web_thk2 and two side legs.
u_recess_depth = max(eps, H - web_thk2); // depth removed from bottom upward
u_recess_w     = max(eps, cut_W2);       // recess width -> leaves side legs of thickness (W-cut_W2)/2
u_recess_L     = max(eps, cut_L2);       // recess length limited to central span (keeps end blocks solid)

// 2D rounded/chamfered rectangle via offset
module rrect2d(sz=[10,10], r=0) {
    r2 = max(0, min(r, min(sz[0], sz[1])/2));
    if (r2 <= 0)
        square(sz, center=true);
    else
        offset(r=r2) square([sz[0]-2*r2, sz[1]-2*r2], center=true);
}

module u_bridge_bracket() {
    union() {
        difference() {
            // Outer solid (single connected body)
            linear_extrude(height=H, center=true, convexity=10)
                rrect2d([L, W], chamfer2);

            // Central window cutout: remove full height (bridge opening)
            cube([cut_L2, cut_W2, H + 2*overlap], center=true);

            // Underside recess to create a true U/channel cross-section in the central span.
            // Recess starts at bottom face and goes up by u_recess_depth, leaving top web thickness ~ web_thk2.
            // Translate computed so the recess "touches" the bottom face with slight overlap.
            translate([0, 0, (-H/2) + (u_recess_depth/2) - (overlap/2)])
                cube([u_recess_L + 2*overlap, u_recess_w, u_recess_depth + overlap], center=true);

            // Through holes + counterbore on top face (one per end block near outer corner)
            for (sx = [-1, 1]) {
                xh = sx*(L/2 - hole_offset_x);
                yh = (W/2 - hole_offset_y);

                // Through hole
                translate([xh, yh, 0])
                    cylinder(h=H + 2*overlap, r=hole_d/2, center=true);

                // Counterbore (top)
                translate([xh, yh, (H/2) - (csk_depth/2) + (overlap/2)])
                    cylinder(h=csk_depth + overlap, r=csk_d/2, center=true);
            }
        }
    }
}

u_bridge_bracket();