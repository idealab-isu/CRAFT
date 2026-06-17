$fn=96;

// Ruideng-style panel meter / power supply module (generic approximation)
// Units: mm

// ---------- Parameters ----------
module_params();

module module_params() {
    // Overall body
    body_w = 71.0;
    body_h = 39.0;
    body_d = 24.0;

    // Front bezel / lip
    bezel_w = 74.0;
    bezel_h = 42.0;
    bezel_t = 2.2;
    bezel_r = 2.0;

    // Front face inset (screen window area)
    screen_w = 50.0;
    screen_h = 26.0;
    screen_inset = 1.2;

    // Screen window cutout (through bezel)
    window_w = 46.0;
    window_h = 22.0;

    // Side mounting ears (approx)
    ear_w = 6.0;
    ear_h = 10.0;
    ear_t = 2.0;
    ear_offset_y = 0.0;

    // Mounting holes in ears
    hole_d = 3.2;

    // Rear connectors (approx)
    term_block_w = 18.0;
    term_block_h = 12.0;
    term_block_d = 10.0;

    // Rear heatsink-ish ribs (visual)
    rib_count = 6;
    rib_w = 2.0;
    rib_gap = 2.0;
    rib_h = 10.0;
    rib_d = 1.6;

    // Corner radius for main body
    body_r = 1.5;

    // ---------- Build ----------
    panel_meter(
        body_w, body_h, body_d,
        bezel_w, bezel_h, bezel_t, bezel_r,
        screen_w, screen_h, screen_inset,
        window_w, window_h,
        ear_w, ear_h, ear_t, ear_offset_y,
        hole_d,
        term_block_w, term_block_h, term_block_d,
        rib_count, rib_w, rib_gap, rib_h, rib_d,
        body_r
    );
}

// ---------- Helpers ----------
module rounded_box(size=[10,10,10], r=1.0, center=false) {
    // Minkowski rounded rectangular prism
    sx=size[0]; sy=size[1]; sz=size[2];
    rr = min(r, min(sx,sy)/2);
    translate(center ? [-sx/2,-sy/2,-sz/2] : [0,0,0])
        minkowski() {
            cube([sx-2*rr, sy-2*rr, sz-2*rr], center=false);
            sphere(r=rr);
        }
}

module rounded_rect_2d(w,h,r) {
    rr = min(r, min(w,h)/2);
    offset(r=rr) offset(delta=-rr) square([w,h], center=true);
}

module countersunk_hole(d=3.2, h=10, cs_d=6.0, cs_h=2.0) {
    union() {
        cylinder(d=d, h=h, center=false);
        translate([0,0,h-cs_h]) cylinder(d1=d, d2=cs_d, h=cs_h, center=false);
    }
}

// ---------- Main Model ----------
module panel_meter(
    body_w, body_h, body_d,
    bezel_w, bezel_h, bezel_t, bezel_r,
    screen_w, screen_h, screen_inset,
    window_w, window_h,
    ear_w, ear_h, ear_t, ear_offset_y,
    hole_d,
    term_block_w, term_block_h, term_block_d,
    rib_count, rib_w, rib_gap, rib_h, rib_d,
    body_r
) {

    // Coordinate system:
    // Front face at z=0, body extends to +z
    // Centered in X/Y
    difference() {
        union() {
            // Main body
            translate([-body_w/2, -body_h/2, bezel_t])
                rounded_box([body_w, body_h, body_d], r=body_r, center=false);

            // Front bezel
            translate([0,0,bezel_t/2])
                linear_extrude(height=bezel_t, center=true)
                    rounded_rect_2d(bezel_w, bezel_h, bezel_r);

            // Side ears (left/right)
            for (sx=[-1,1]) {
                translate([sx*(bezel_w/2 + ear_w/2 - 0.2), ear_offset_y, bezel_t/2])
                    linear_extrude(height=ear_t, center=true)
                        rounded_rect_2d(ear_w, ear_h, r=1.0);
            }

            // Rear terminal blocks (two)
            for (sx=[-1,1]) {
                translate([sx*(body_w*0.22), -body_h/2 - term_block_h/2 + 1.0, bezel_t + body_d - term_block_d])
                    rounded_box([term_block_w, term_block_h, term_block_d], r=1.0, center=true);
            }

            // Rear ribs (visual)
            rib_span = rib_count*rib_w + (rib_count-1)*rib_gap;
            start_x = -rib_span/2 + rib_w/2;
            for (i=[0:rib_count-1]) {
                x = start_x + i*(rib_w + rib_gap);
                translate([x, body_h/2 - 4.0, bezel_t + body_d - rib_d])
                    cube([rib_w, rib_h, rib_d], center=true);
            }

            // Small rear protrusion (USB-ish / programming header look)
            translate([0, body_h/2 - 6.0, bezel_t + body_d - 6.0])
                rounded_box([14, 10, 6], r=1.0, center=true);
        }

        // Screen window cutout through bezel
        translate([0,0,0])
            linear_extrude(height=bezel_t + 0.5, center=false)
                rounded_rect_2d(window_w, window_h, r=1.2);

        // Screen recess (shallow pocket on front face)
        translate([0,0,0.2])
            linear_extrude(height=screen_inset, center=false)
                rounded_rect_2d(screen_w, screen_h, r=1.5);

        // Ear mounting holes
        for (sx=[-1,1]) {
            translate([sx*(bezel_w/2 + ear_w/2 - 0.2), ear_offset_y, 0])
                countersunk_hole(d=hole_d, h=bezel_t + ear_t + 2, cs_d=6.2, cs_h=1.6);
        }

        // Slight chamfer-like relief on bezel underside (to suggest snap-in)
        translate([0,0,bezel_t-0.6])
            linear_extrude(height=1.2, center=true)
                difference() {
                    rounded_rect_2d(bezel_w-1.0, bezel_h-1.0, r=max(0.5,bezel_r-0.5));
                    rounded_rect_2d(bezel_w-6.0, bezel_h-6.0, r=max(0.5,bezel_r-1.0));
                }
    }

    // Front "LCD" plate (separate visual insert)
    color([0.05,0.05,0.06])
    translate([0,0,0.25])
        linear_extrude(height=0.8, center=false)
            rounded_rect_2d(window_w-1.0, window_h-1.0, r=1.0);

    // Front printed area (blue-ish)
    color([0.05,0.25,0.55])
    translate([0,0,0.05])
        linear_extrude(height=0.2, center=false)
            rounded_rect_2d(screen_w, screen_h, r=1.5);

    // Tiny "buttons" (approx) on right side of screen
    color([0.15,0.15,0.15])
    for (j=[-1,0,1]) {
        translate([screen_w/2 + 6.5, j*7.0, 0.6])
            cylinder(d=4.2, h=1.2, center=false);
    }

    // Small indicator dot
    color([0.8,0.1,0.1])
    translate([-screen_w/2 - 6.0, screen_h/2 - 4.0, 0.6])
        cylinder(d=2.0, h=1.0, center=false);
}