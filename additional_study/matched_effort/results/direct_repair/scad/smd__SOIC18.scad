// SMD package: [11.40, 7.50, 2.00] (L, W, H) in mm

L = 11.40;
W = 7.50;
H = 2.00;

$fn = 64;

module smd_body(l=L, w=W, h=H) {
    // Slight edge rounding via minkowski with a small sphere
    r = min(0.35, h*0.25, w*0.05, l*0.05);
    minkowski() {
        translate([0,0,r])
            cube([l-2*r, w-2*r, h-2*r], center=true);
        sphere(r=r);
    }
}

module smd_mark(l=L, w=W, h=H) {
    // Simple pin-1 style dot on top near one corner
    dot_r = min(0.6, w*0.08, l*0.08);
    inset = dot_r*1.6;
    translate([ -l/2 + inset,  w/2 - inset,  h/2 + 0.01 ])
        cylinder(h=0.2, r=dot_r, center=false);
}

difference() {
    color([0.12,0.12,0.12]) smd_body();
    // Engrave mark slightly
    smd_mark();
}