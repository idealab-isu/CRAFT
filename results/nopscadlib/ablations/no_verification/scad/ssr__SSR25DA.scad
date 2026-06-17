$fn = 64;

// Overall dimensions (mm)
length = 63.0;
width  = 45.0;
height = 23.0;

// Small edge rounding
corner_r = 1.2;

// Rounded rectangular prism, centered
module rounded_box(size=[10,10,10], r=1) {
    l = size[0]; w = size[1]; h = size[2];
    r2 = min(r, l/2, w/2);

    // Use minkowski for robust, always-visible geometry
    minkowski() {
        cube([l - 2*r2, w - 2*r2, h], center=true);
        cylinder(r=r2, h=0.01, center=true);
    }
}

// Solid State Relay module (one connected solid)
module ssr_module() {
    pad_l = length * 0.86;
    pad_w = width  * 0.78;
    pad_h = 1.6;
    overlap = 0.4;

    color("DimGray")
    union() {
        // Main body
        rounded_box([length, width, height], r=corner_r);

        // Raised top pad (connected with overlap)
        translate([0, 0, height/2 + pad_h/2 - overlap])
            rounded_box([pad_l, pad_w, pad_h], r=corner_r*0.8);
    }
}

ssr_module();