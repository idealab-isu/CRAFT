$fn = 64;

// LCD display 4.3" (approx) — ONE connected solid with visible front recess + bottom notch
w = 105.5;
h = 67.2;
t = 3.4;

// Front window/recess region (from provided points)
win_p1 = [-50, -26.5];
win_p2 = [ 50,  31.5];
win_corner_r = 0.5;

// Secondary feature near bottom edge (connector/notch) (from provided points)
notch_p1 = [0,  -34.5];
notch_p2 = [12, -31.5];

// Depths
front_recess_depth = 0.8;   // shallow recess from front face
notch_depth        = 1.2;   // notch cut from bottom face upward
eps = 0.02;

module rounded_rect_2d(sz=[10,10], r=1) {
    r2 = min(r, sz[0]/2, sz[1]/2);
    offset(r=r2) offset(delta=-r2) square(sz, center=true);
}

module lcd_module() {
    // Derived window dims/center
    win_w  = win_p2[0] - win_p1[0];
    win_h  = win_p2[1] - win_p1[1];
    win_cx = (win_p1[0] + win_p2[0]) / 2;
    win_cy = (win_p1[1] + win_p2[1]) / 2;

    // Derived notch dims/center (treat given points as opposite corners)
    notch_w  = abs(notch_p2[0] - notch_p1[0]);
    notch_h  = abs(notch_p2[1] - notch_p1[1]);
    notch_cx = (notch_p1[0] + notch_p2[0]) / 2;
    notch_cy = (notch_p1[1] + notch_p2[1]) / 2;

    difference() {
        // Main slab centered at origin (ensures visible geometry)
        cube([w, h, t], center=true);

        // Front window recess: cut into +Z (front) face
        translate([win_cx, win_cy, t/2 - front_recess_depth/2 + eps])
            linear_extrude(height=front_recess_depth + 2*eps, center=true)
                rounded_rect_2d([win_w, win_h], r=win_corner_r);

        // Bottom notch: cut from -Z (bottom) face upward
        translate([notch_cx, notch_cy, -t/2 + notch_depth/2 - eps])
            cube([notch_w, notch_h, notch_depth + 2*eps], center=true);
    }
}

lcd_module();