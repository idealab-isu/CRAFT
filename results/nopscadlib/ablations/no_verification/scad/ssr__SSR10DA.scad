// Solid State Relay (SSR) module - one connected solid
// Overall size: 58.0mm x 45.0mm x 33.0mm (X x Y x Z)

length_mm = 58.0;
width_mm  = 45.0;
height_mm = 33.0;

$fn = 72;

// Rounded box helper (works with r=0 too)
module rounded_box(size=[10,10,10], r=0, center=true) {
    l = size[0]; w = size[1]; h = size[2];
    rr = max(0, min(r, min(l,w)/2 - 0.01));
    if (rr <= 0) {
        cube([l,w,h], center=center);
    } else {
        // 2D offset then extrude
        translate(center ? [0,0,0] : [l/2,w/2,h/2])
            linear_extrude(height=h, center=true)
                offset(r=rr)
                    square([l-2*rr, w-2*rr], center=true);
    }
}

module ssr_module() {
    // Base body (kept exact overall dimensions)
    body_l = length_mm;
    body_w = width_mm;
    body_h = height_mm;

    // Feature sizing (all derived from overall dimensions)
    corner_r = min(body_l, body_w) * 0.06;          // subtle rounding
    overlap  = 0.6;                                  // ensures watertight unions

    // Top terminal block (raised area)
    top_h = body_h * 0.22;                           // ~7.26mm
    top_l = body_l * 0.70;
    top_w = body_w * 0.62;

    // Side mounting ears (common SSR look)
    ear_t = body_w * 0.12;                           // thickness in Y
    ear_l = body_l * 0.18;                           // extension in X
    ear_h = body_h * 0.55;                           // height in Z

    // Bottom base flange (slight step)
    flange_h = body_h * 0.10;
    flange_l = body_l * 0.92;
    flange_w = body_w * 0.92;

    // Front face shallow recess (label plate area) - recessed, not text
    recess_d = body_h * 0.06;                        // depth into body (Z direction from front face)
    recess_l = body_l * 0.78;
    recess_h = body_h * 0.42;

    // Terminal posts (simple blocks) on top
    post_h = top_h * 0.70;
    post_w = top_w * 0.18;
    post_l = top_l * 0.22;
    post_gap = top_l * 0.08;

    // Place "front" as +Y face for recess
    difference() {
        union() {
            // Main body
            rounded_box([body_l, body_w, body_h], r=corner_r, center=true);

            // Bottom flange: sits on bottom face, overlaps into body
            translate([0, 0, -body_h/2 + flange_h/2 - overlap/2])
                rounded_box([flange_l, flange_w, flange_h + overlap], r=corner_r*0.8, center=true);

            // Top terminal block: sits on top face, overlaps into body
            translate([0, 0, body_h/2 - top_h/2 + overlap/2])
                rounded_box([top_l, top_w, top_h + overlap], r=corner_r*0.7, center=true);

            // Two side mounting ears (left/right in X), centered in Y, mid-height
            for (sx = [-1, 1]) {
                translate([sx*(body_l/2 + ear_l/2 - overlap), 0, -body_h*0.05])
                    rounded_box([ear_l + overlap, ear_t, ear_h], r=corner_r*0.6, center=true);
            }

            // Terminal posts on top block (4 posts)
            z_posts = body_h/2 - top_h + post_h/2 + overlap/2; // within top block, connected
            x0 = -( (2*post_l + post_gap) / 2 );
            for (i = [0:3]) {
                xi = x0 + (i%2)*(post_l + post_gap);
                yi = (i<2 ? -1 : 1) * (top_w*0.22);
                translate([xi, yi, z_posts])
                    rounded_box([post_l, post_w, post_h + overlap], r=corner_r*0.25, center=true);
            }
        }

        // Front face recess (shallow pocket) - subtract from +Y face
        // Positioned so it cuts into the body but does not break through.
        translate([0, body_w/2 - recess_d/2 + 0.01, 0])
            cube([recess_l, recess_d + 0.02, recess_h], center=true);

        // Indications of mounting holes on ears (shallow dimples, not through-holes)
        // Subtracted from outer faces of ears to suggest holes while keeping one solid.
        dimple_r = min(ear_t, ear_h) * 0.22;
        dimple_d = ear_t * 0.55; // depth into ear from its outer Y face
        for (sx = [-1, 1]) {
            // Outer Y face of ear is at +/- ear_t/2 relative to ear center (ear centered at Y=0)
            // We dimple from +Y side only to keep consistent "front" direction.
            translate([sx*(body_l/2 + ear_l/2 - overlap), ear_t/2 - dimple_d/2 + 0.01, -body_h*0.05])
                rotate([90,0,0])
                    cylinder(h=dimple_d + 0.02, r=dimple_r, center=true);
        }
    }
}

ssr_module();