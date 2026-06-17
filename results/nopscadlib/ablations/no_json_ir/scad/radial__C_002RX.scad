// Radial parameters: [2.0, 0, 6]
radial_r     = 2.0;  // radius to the centers of the radial elements
radial_inner = 0;    // inner radius (0 = solid hub)
radial_rot   = 0;    // rotation in degrees
radial_segs  = 6;    // number of radial segments/elements
radial_h     = 6;    // height

module radial_object(r=radial_r, inner=radial_inner, rot=radial_rot, segs=radial_segs, h=radial_h) {
    eps = 0.01;
    overlap = 1.0;                 // 1–2mm overlap for solid connections
    r2 = max(r, eps);
    inner2 = max(min(inner, r2 - eps), 0);

    // Make the "radial" recognizable: a central hub + distinct repeated spokes around it.
    // Interpret [2.0, 0, 6] as: radius=2.0, rotation offset=0, count=6.
    hub_r = max(inner2 + 0.9, 0.9); // ensure visible hub even when inner=0
    spoke_len = max(1.2, r2);       // extend outward to clearly show radial pattern
    spoke_w = max(0.7, r2 * 0.45);  // chunky, readable spokes

    rotate([0, 0, rot])
    union() {
        // Central hub (solid)
        cylinder(r=hub_r, h=h, center=true, $fn=64);

        // Radial spokes (distinct repeated elements)
        for (i = [0:segs-1]) {
            rotate([0, 0, i * 360 / segs])
                // Place spoke so its inner end overlaps into the hub by 'overlap'
                translate([hub_r + spoke_len/2 - overlap, 0, 0])
                    cube([spoke_len, spoke_w, h], center=true);
        }
    }
}

radial_object();