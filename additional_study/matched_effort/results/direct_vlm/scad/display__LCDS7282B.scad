$fn=64;

// LCD Display Module S-7282B (approx.)
// Overall: 73.6mm x 28.7mm
// Simple representative geometry: PCB + bezel + viewing window + 4 mounting holes

module lcd_s7282b(
    pcb_l=73.6,
    pcb_w=28.7,
    pcb_t=1.6,

    bezel_l=60.0,
    bezel_w=20.0,
    bezel_t=3.2,

    window_l=52.0,
    window_w=14.0,
    window_depth=1.2,

    hole_d=3.0,
    hole_edge=3.0,

    standoff_d=6.0,
    standoff_h=2.0
){
    // Derived hole positions (near corners)
    hx = pcb_l/2 - hole_edge;
    hy = pcb_w/2 - hole_edge;

    difference() {
        union() {
            // PCB
            color([0.05,0.35,0.12])
                translate([0,0,pcb_t/2])
                    cube([pcb_l, pcb_w, pcb_t], center=true);

            // Optional standoffs around holes (small bosses on top)
            color([0.05,0.35,0.12])
            for (sx=[-hx, hx], sy=[-hy, hy])
                translate([sx, sy, pcb_t])
                    cylinder(d=standoff_d, h=standoff_h);

            // Bezel / frame on top of PCB
            color([0.15,0.15,0.15])
                translate([0,0,pcb_t + bezel_t/2])
                    cube([bezel_l, bezel_w, bezel_t], center=true);

            // Glass area (slightly recessed into bezel)
            color([0.2,0.35,0.45,0.6])
                translate([0,0,pcb_t + bezel_t - window_depth/2])
                    cube([window_l, window_w, window_depth], center=true);
        }

        // Mounting holes through PCB (and standoffs)
        for (sx=[-hx, hx], sy=[-hy, hy])
            translate([sx, sy, -1])
                cylinder(d=hole_d, h=pcb_t + standoff_h + bezel_t + 3);

        // Viewing window cutout through bezel (to show glass)
        translate([0,0,pcb_t + bezel_t/2])
            cube([window_l, window_w, bezel_t + 0.2], center=true);
    }
}

// Render
lcd_s7282b();