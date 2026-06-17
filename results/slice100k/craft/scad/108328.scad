// Hex prismatic spacer/fixture block with:
// - flat-to-flat hex body (W) and controlled overall length (L) via clipping
// - single small circular through-hole near center
// - diagonal recessed band/groove on the top face
// - slight end steps/chamfers (top face) near both ends
// - small notch-like relief on one end
// Bounding box target: 46.2 x 40.0 x 7.0 mm

$fn = 128;

// Target bounding box
L = 46.2;     // X
W = 40.0;     // Y (flat-to-flat)
H = 7.0;      // Z

eps = 0.05;

// Hex geometry (flat-to-flat = W)
apothem = W/2;
R = apothem / cos(30);   // circumradius

// Features
hole_d = 4.0;

groove_w = 6.0;
groove_depth = 1.0;
groove_angle = 30;       // degrees
groove_y_offset = 0.0;

step_len = 3.0;          // length of end step region (each end)
step_inset = 1.0;        // in-plane inset for step
step_drop = 0.5;         // depth of step from top face

notch_w = 6.0;           // along Y
notch_d = 3.0;           // into part from end (along X)
notch_z = H;             // through thickness

// 2D regular hex with flats horizontal (flat-to-flat = W)
module hex2d(ap) {
    RR = ap / cos(30);
    polygon(points=[
        [ RR, 0],
        [ RR/2,  RR*sqrt(3)/2],
        [-RR/2,  RR*sqrt(3)/2],
        [-RR, 0],
        [-RR/2, -RR*sqrt(3)/2],
        [ RR/2, -RR*sqrt(3)/2]
    ]);
}

// Base hex prism, clipped to exact length L in X
module clipped_hex_prism(h) {
    intersection() {
        linear_extrude(height=h, center=true)
            hex2d(apothem);
        cube([L, 2*R + 2*eps, h + 2*eps], center=true);
    }
}

// End top steps (shallow recessed pads) to suggest chamfer/step at ends
module end_top_steps() {
    zc = H/2 - step_drop/2 + eps/2;
    for (sx = [-1, 1]) {
        translate([sx*(L/2 - step_len/2), 0, zc])
            intersection() {
                // limit to end region
                cube([step_len + 2*eps, 2*R + 2*eps, step_drop + eps], center=true);
                // inset hex footprint
                linear_extrude(height=step_drop + eps, center=true)
                    hex2d(max(0.01, apothem - step_inset));
            }
    }
}

// Main solid body (one connected solid)
module body() {
    union() {
        clipped_hex_prism(H);
        end_top_steps();
    }
}

// Through-hole
module through_hole() {
    cylinder(d=hole_d, h=H + 4*eps, center=true);
}

// Diagonal recessed groove on top face
module top_groove() {
    zc = H/2 - groove_depth/2 + eps/2;
    translate([0, groove_y_offset, zc])
        rotate([0, 0, groove_angle])
            cube([L + 4*eps, groove_w, groove_depth + 2*eps], center=true);
}

// Notch-like relief on +X end
module end_notch() {
    x0 = L/2 - notch_d/2 + eps/2; // ensure it bites into the end
    translate([x0, 0, 0])
        cube([notch_d + 2*eps, notch_w, notch_z + 4*eps], center=true);
}

// Final model
difference() {
    body();
    through_hole();
    top_groove();
    end_notch();
}