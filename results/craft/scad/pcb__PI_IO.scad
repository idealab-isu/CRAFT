$fn = 64;

// Exact PCB dimensions (mm)
length_mm    = 35.56;
width_mm     = 25.4;
thickness_mm = 1.6;

// Detail parameters (kept within PCB envelope)
corner_r = 1.0;     // rounded corner radius (<= min(length,width)/2)
copper_t = 0.035;   // copper thickness (typical 1 oz)
mask_t   = 0.02;    // soldermask thickness
eps      = 0.01;    // small overlap to ensure watertight unions

module rounded_rect_prism(l, w, h, r) {
    r2 = min(r, min(l, w)/2);
    linear_extrude(height=h, center=true)
        offset(r=r2)
            square([l - 2*r2, w - 2*r2], center=true);
}

module pcb() {
    // One connected solid: FR4 core + copper + soldermask, all overlapping slightly
    union() {
        // FR4 core
        color([0.0, 0.4, 0.2])
            rounded_rect_prism(length_mm, width_mm, thickness_mm, corner_r);

        // Top copper (overlaps into core by eps)
        color([0.72, 0.45, 0.2])
            translate([0, 0, thickness_mm/2 - eps + copper_t/2])
                rounded_rect_prism(length_mm, width_mm, copper_t + 2*eps, corner_r);

        // Bottom copper (overlaps into core by eps)
        color([0.72, 0.45, 0.2])
            translate([0, 0, -thickness_mm/2 + eps - copper_t/2])
                rounded_rect_prism(length_mm, width_mm, copper_t + 2*eps, corner_r);

        // Top soldermask (overlaps into copper by eps)
        color([0.0, 0.35, 0.18])
            translate([0, 0, thickness_mm/2 + copper_t - eps + mask_t/2])
                rounded_rect_prism(length_mm, width_mm, mask_t + 2*eps, corner_r);

        // Bottom soldermask (overlaps into copper by eps)
        color([0.0, 0.35, 0.18])
            translate([0, 0, -thickness_mm/2 - copper_t + eps - mask_t/2])
                rounded_rect_prism(length_mm, width_mm, mask_t + 2*eps, corner_r);
    }
}

pcb();