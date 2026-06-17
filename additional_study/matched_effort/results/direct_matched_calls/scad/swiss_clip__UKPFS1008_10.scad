$fn=96;

// Swiss-style spring clip (approximation)
// Units: mm

// ---------- Parameters ----------
clip_len = 70;
clip_w   = 18;
clip_t   = 2.2;

jaw_gap  = 6.0;     // opening between jaws at the tip
jaw_len  = 22;      // length of the jaw section
nose_r   = 2.2;     // rounded nose radius

hinge_r  = 6.5;     // outer radius of hinge loop
hinge_w  = clip_w;  // width of hinge loop
hinge_pin_r = 2.2;  // inner hole radius

handle_len = clip_len - jaw_len - 2*hinge_r;
handle_curve = 18;  // curvature amount for handles

rib_h = 1.0;        // grip ribs height
rib_w = 1.2;
rib_pitch = 3.2;

// ---------- Helpers ----------
module rounded_bar(len, w, t, r=2) {
    // 2D rounded rectangle extruded
    linear_extrude(height=t)
        offset(r=r)
            square([len-2*r, w-2*r], center=true);
}

module capsule2d(len, w) {
    // centered capsule along X
    hull() {
        translate([-(len-w)/2,0]) circle(d=w);
        translate([ (len-w)/2,0]) circle(d=w);
    }
}

module jaw_profile(len, w, nose_r=2.2) {
    // 2D jaw outline (capsule-ish with tapered inner edge)
    difference() {
        capsule2d(len, w);
        // inner relief to create a thinner tip
        translate([len*0.15, 0])
            scale([1.0, 0.75])
                capsule2d(len*0.9, w*0.9);
    }
}

module grip_ribs(len, w, t, start=0, end=1) {
    // ribs along X on top surface
    rib_count = floor((len)/rib_pitch);
    for (i=[0:rib_count]) {
        x = -len/2 + i*rib_pitch;
        if (x > -len/2 + len*start && x < -len/2 + len*end)
            translate([x, 0, t])
                cube([rib_w, w*0.75, rib_h], center=true);
    }
}

module arm(is_top=true) {
    // One arm of the clip, built in XY then extruded in Z
    // Coordinate system: hinge center at origin, arms extend +X
    sign = is_top ? 1 : -1;

    // Handle centerline offset in Y
    y0 = sign*(jaw_gap/2 + clip_t/2);

    // 2D arm shape
    module arm2d() {
        union() {
            // Handle (slightly curved via hull of circles)
            hull() {
                translate([hinge_r*0.2, y0]) circle(r=clip_w/2);
                translate([hinge_r + handle_len*0.55, y0 + sign*handle_curve*0.25]) circle(r=clip_w/2);
                translate([hinge_r + handle_len, y0]) circle(r=clip_w/2);
            }

            // Jaw section (tapered)
            translate([hinge_r + handle_len + jaw_len/2, y0])
                scale([1, 0.85])
                    jaw_profile(jaw_len, clip_w*0.95, nose_r);

            // Hinge loop outer
            translate([0,0]) circle(r=hinge_r);
        }
    }

    // Cutouts for hinge hole and inner clearance
    module arm2d_cut() {
        union() {
            // Hinge pin hole
            circle(r=hinge_pin_r);

            // Inner clearance near hinge to allow spring action
            translate([hinge_r*0.9, 0])
                rotate(0)
                    scale([1.2, 0.9])
                        circle(r=hinge_r*0.75);

            // Inner jaw relief to create biting edges
            translate([hinge_r + handle_len + jaw_len*0.55, y0])
                scale([1.0, 0.55])
                    capsule2d(jaw_len*0.9, clip_w*0.75);
        }
    }

    // Extrude arm
    difference() {
        linear_extrude(height=clip_t)
            difference() {
                arm2d();
                arm2d_cut();
            }

        // Add a small notch at the jaw tip for grip
        translate([hinge_r + handle_len + jaw_len - 2.5, y0, -0.1])
            rotate([0,0,0])
                cylinder(h=clip_t+0.2, r=1.2, center=false);
    }

    // Grip ribs on outer face (top arm gets ribs on top; bottom arm gets ribs on bottom)
    if (is_top) {
        translate([hinge_r + handle_len*0.55, y0, 0])
            grip_ribs(handle_len*0.95, clip_w*0.9, clip_t, start=0.15, end=0.95);
    } else {
        // ribs on underside
        translate([hinge_r + handle_len*0.55, y0, -rib_h])
            grip_ribs(handle_len*0.95, clip_w*0.9, 0, start=0.15, end=0.95);
    }
}

module swiss_clip() {
    // Assemble two arms with slight pre-load (crossing at hinge)
    preload_deg = 6;

    union() {
        // Bottom arm
        rotate([0,0,-preload_deg])
            arm(false);

        // Top arm
        rotate([0,0, preload_deg])
            arm(true);

        // Hinge pin (optional solid pin for printability)
        // Comment out if you want a functional hole only.
        translate([0,0,0])
            cylinder(h=clip_t, r=hinge_pin_r*0.65, center=false);
    }
}

// ---------- Render ----------
swiss_clip();