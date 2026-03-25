// Dimension-calibrated (target: 0.31 x 0.08 x 0.31 mm)
scale([0.914797, 0.592924, 3.070049])
{
$fn = 64;

// Bounding box target (mm): 0.3 x 0.1 x 0.3, elongated along one axis
// Make it a SHALLOW tray: long in X, narrow in Y, shallow in Z
L = 0.30;   // X (elongated axis)
W = 0.10;   // Y
H = 0.10;   // Z (shallow height)

corner_r = 0.012;
wall_t   = 0.006;
bottom_t = 0.010;

flange_w = 0.020;   // outward lip width
flange_t = 0.004;

side_opening_bottom_margin = 0.012;
side_opening_top_margin    = 0.012;

hole_diamond_w = 0.018;  // along horizontal direction on each face
hole_diamond_h = 0.012;  // along vertical direction
hole_pitch_u   = 0.026;
hole_pitch_z   = 0.020;

eps = 0.001;

// Ensure through-holes fully cut the wall even with rounding/offsets
hole_depth = wall_t + 4*eps;

// ---------- Helpers ----------
module rounded_rect_2d(x, y, r) {
    offset(r=r)
        square([max(eps, x-2*r), max(eps, y-2*r)], center=true);
}

module rounded_rect_prism(x, y, z, r) {
    linear_extrude(height=z, center=true)
        rounded_rect_2d(x, y, r);
}

module diamond_prism(depth, w, h) {
    linear_extrude(height=depth, center=true)
        polygon(points=[
            [0,  h/2],
            [w/2, 0],
            [0, -h/2],
            [-w/2, 0]
        ]);
}

// ---------- Main solids ----------
module outer_body() {
    rounded_rect_prism(L, W, H, corner_r);
}

module inner_cavity() {
    // Open top, solid bottom
    inner_h = H - bottom_t + eps; // cavity reaches near top; flange is separate
    translate([0, 0, -H/2 + bottom_t + inner_h/2])
        rounded_rect_prism(L - 2*wall_t, W - 2*wall_t, inner_h, max(eps, corner_r - wall_t));
}

module flange() {
    // Wide outward lip around top perimeter, connected to body
    zf = H/2 - flange_t/2;
    difference() {
        translate([0, 0, zf])
            rounded_rect_prism(L + 2*flange_w, W + 2*flange_w, flange_t, corner_r + flange_w);
        translate([0, 0, zf])
            rounded_rect_prism(L + 2*eps, W + 2*eps, flange_t + 2*eps, corner_r);
    }
}

module tray_solid() {
    union() {
        difference() {
            outer_body();
            inner_cavity();
        }
        flange();
    }
}

// ---------- Perforations (SIDE WALLS ONLY) ----------
module side_hole_field_on_face(face="x+") {
    // Z band for holes (avoid bottom and flange/top rim)
    z0 = -H/2 + bottom_t + side_opening_bottom_margin + hole_diamond_h/2;
    z1 =  H/2 - flange_t - side_opening_top_margin - hole_diamond_h/2;

    // usable spans along face direction (avoid rounded corners)
    x_span = L - 2*corner_r - 2*wall_t;
    y_span = W - 2*corner_r - 2*wall_t;

    if (z1 <= z0) children(); // no holes if margins too large

    if (face=="x+" || face=="x-") {
        // holes distributed along Y and Z, cut through X wall
        nu = max(1, floor(y_span / hole_pitch_u));
        nz = max(1, floor((z1 - z0) / hole_pitch_z));
        for (iu = [0:nu]) for (iz = [0:nz]) {
            u = -y_span/2 + iu*hole_pitch_u;
            z = z0 + iz*hole_pitch_z;
            u2 = u + ((iz % 2) ? hole_pitch_u/2 : 0);
            if (abs(u2) <= y_span/2)
                translate([0, u2, z])
                    rotate([0, 90, 0])
                        diamond_prism(hole_depth, hole_diamond_w, hole_diamond_h);
        }
    } else if (face=="y+" || face=="y-") {
        // holes distributed along X and Z, cut through Y wall
        nu = max(1, floor(x_span / hole_pitch_u));
        nz = max(1, floor((z1 - z0) / hole_pitch_z));
        for (iu = [0:nu]) for (iz = [0:nz]) {
            u = -x_span/2 + iu*hole_pitch_u;
            z = z0 + iz*hole_pitch_z;
            u2 = u + ((iz % 2) ? hole_pitch_u/2 : 0);
            if (abs(u2) <= x_span/2)
                translate([u2, 0, z])
                    rotate([90, 0, 0])
                        diamond_prism(hole_depth, hole_diamond_w, hole_diamond_h);
        }
    }
}

module all_side_holes() {
    union() {
        // Place cutters centered on each wall thickness so they pass through
        translate([ L/2 - wall_t/2, 0, 0]) side_hole_field_on_face("x+");
        translate([-L/2 + wall_t/2, 0, 0]) side_hole_field_on_face("x-");

        translate([0,  W/2 - wall_t/2, 0]) side_hole_field_on_face("y+");
        translate([0, -W/2 + wall_t/2, 0]) side_hole_field_on_face("y-");
    }
}

// Clip holes to side-wall band only AND exclude bottom area explicitly
module hole_band_clip() {
    z_low  = -H/2 + bottom_t + side_opening_bottom_margin;
    z_high =  H/2 - flange_t - side_opening_top_margin;

    // Only allow cutters in a thin shell region around the outside (prevents any bottom perforation artifacts)
    intersection() {
        // Z band
        translate([0, 0, (z_low+z_high)/2])
            cube([L + 2*flange_w + 4*eps, W + 2*flange_w + 4*eps, (z_high - z_low) + 4*eps], center=true);

        // Radial shell around outer body (approx via difference of two rounded prisms)
        difference() {
            rounded_rect_prism(L + 2*eps, W + 2*eps, H + 4*eps, corner_r);
            rounded_rect_prism(L - 2*wall_t - 2*eps, W - 2*wall_t - 2*eps, H + 6*eps, max(eps, corner_r - wall_t));
        }
    }
}

// ---------- Final ----------
difference() {
    tray_solid();
    intersection() {
        all_side_holes();
        hole_band_clip();
    }
}
}
