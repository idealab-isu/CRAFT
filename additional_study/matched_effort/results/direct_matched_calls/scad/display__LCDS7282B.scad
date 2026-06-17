$fn = 64;

// LCD Display Module S-7282B (approx.)
// Overall: 73.6mm x 28.7mm
// Simple representative model: PCB + bezel + viewing window + 4 mounting holes

module lcd_s_7282b(
    L = 73.6,
    W = 28.7,
    pcb_t = 1.6,
    bezel_t = 2.2,
    bezel_margin = 2.0,
    window_margin = 5.0,
    hole_d = 3.0,
    hole_edge = 3.0,
    standoff_d = 6.0,
    standoff_h = 2.0
){
    // Derived
    bezel_L = L - 2*bezel_margin;
    bezel_W = W - 2*bezel_margin;

    window_L = L - 2*window_margin;
    window_W = W - 2*window_margin;

    // Hole positions (from edges)
    hx = L/2 - hole_edge;
    hy = W/2 - hole_edge;

    module pcb(){
        color([0.05,0.35,0.12])
            translate([-L/2, -W/2, 0])
                cube([L, W, pcb_t], center=false);
    }

    module standoffs(){
        color([0.05,0.05,0.05])
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*hx, sy*hy, pcb_t])
                cylinder(d=standoff_d, h=standoff_h);
    }

    module bezel(){
        // Bezel ring with window cutout
        color([0.12,0.12,0.12])
        translate([0,0,pcb_t])
        difference(){
            translate([-bezel_L/2, -bezel_W/2, 0])
                cube([bezel_L, bezel_W, bezel_t], center=false);

            // Window opening
            translate([-window_L/2, -window_W/2, -0.1])
                cube([window_L, window_W, bezel_t+0.2], center=false);
        }
    }

    module glass(){
        // Slightly recessed "glass" in the window
        glass_t = 1.0;
        color([0.05,0.10,0.12, 0.6])
        translate([0,0,pcb_t + 0.4])
            translate([-window_L/2, -window_W/2, 0])
                cube([window_L, window_W, glass_t], center=false);
    }

    module holes(){
        // Through holes in PCB (and standoffs/bezel if overlapping)
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*hx, sy*hy, -0.5])
                cylinder(d=hole_d, h=pcb_t + standoff_h + bezel_t + 2.0);
    }

    difference(){
        union(){
            pcb();
            standoffs();
            bezel();
            glass();
        }
        holes();
    }
}

lcd_s_7282b();