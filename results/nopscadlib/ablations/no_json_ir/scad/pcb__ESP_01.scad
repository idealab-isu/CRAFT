// Simple PCB slab: 24.8mm x 14.6mm x 1.0mm (one connected solid)

length = 24.8;
width  = 14.6;
thickness = 1.0;

// Rounded corner radius (kept modest; set to 0 for sharp corners)
corner_radius = 2.0;

$fn = 64;

module rounded_rect_2d(l, w, r) {
    r2 = min(r, l/2, w/2);
    if (r2 <= 0)
        square([l, w], center=true);
    else
        offset(r=r2)
            square([l - 2*r2, w - 2*r2], center=true);
}

module pcb() {
    linear_extrude(height=thickness, center=true, convexity=10)
        rounded_rect_2d(length, width, corner_radius);
}

pcb();