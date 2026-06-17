// Motor driver module PCB
// Target size: 35.0mm x 32.0mm x 1.6mm (one connected solid)

length_mm    = 35.0;
width_mm     = 32.0;
thickness_mm = 1.6;

$fn = 64;

module pcb_module() {
    corner_r = min(2.0, min(length_mm, width_mm)/6);

    // Robust, always-visible solid using a 3D rounded-rectangle (no 2D offset/eps issues)
    color([0.0, 0.4, 0.2])
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(length_mm/2 - corner_r), sy*(width_mm/2 - corner_r), 0])
                cylinder(r = corner_r, h = thickness_mm, center = true);
    }
}

pcb_module();