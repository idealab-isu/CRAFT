$fn=64;

// Motor driver module (generic) 35.0mm x 32.0mm x 1.6mm PCB with connected features
module motor_driver_module(
    L=35.0,   // length (X)
    W=32.0,   // width  (Y)
    T=1.6,    // PCB thickness (Z)
    corner_r=1.5
){
    // ---- Feature dimensions (generic, but dimension-driven placement) ----
    hole_d = 3.0;
    hole_edge = 3.0;                 // hole center offset from each edge

    // Terminal block (2-pin) on +Y edge
    term_L = 12.0;
    term_W = 8.0;
    term_H = 10.0;

    // Pin header (1x6) on -Y edge
    hdr_L = 16.0;
    hdr_W = 5.0;
    hdr_H = 8.0;

    // Main driver IC
    ic_L = 14.0;
    ic_W = 12.0;
    ic_H = 2.2;

    // Small components (caps/resistors)
    smd_H = 1.2;
    cap_d = 6.0;
    cap_H = 7.0;

    // Overlap to guarantee single connected solid
    overlap = 0.25;

    // ---- Helpers ----
    module rounded_board_2d(l, w, r){
        offset(r=r) square([l-2*r, w-2*r], center=true);
    }

    module pcb(){
        color([0.05,0.35,0.12])
        linear_extrude(height=T)
            rounded_board_2d(L, W, corner_r);
    }

    module mounting_holes(){
        // Through-holes in PCB (subtracted)
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([ sx*(L/2 - hole_edge), sy*(W/2 - hole_edge), -0.1 ])
                cylinder(d=hole_d, h=T+0.2);
        }
    }

    module terminal_block(){
        // Sits on top, centered on +Y edge, overlaps into PCB
        translate([0, (W/2 - term_W/2), T/2 + term_H/2 - overlap])
            cube([term_L, term_W, term_H], center=true);
        // Two wire entry cylinders (subtracted later from the block via difference in union not needed;
        // keep as solid detail by adding shallow recess bumps instead)
        for (i=[-1,1]) {
            translate([ i*(term_L*0.25), (W/2 - term_W*0.15), T + term_H*0.55 - overlap ])
                rotate([90,0,0])
                    cylinder(d=3.2, h=term_W*0.6, center=true);
        }
    }

    module pin_header(){
        // Plastic base
        translate([0, -(W/2 - hdr_W/2), T/2 + hdr_H/2 - overlap])
            cube([hdr_L, hdr_W, hdr_H], center=true);

        // Pins (6)
        pin_pitch = hdr_L/6;
        pin_d = 1.0;
        pin_h = hdr_H + 3.0;
        for (i=[0:5]) {
            x = -hdr_L/2 + pin_pitch/2 + i*pin_pitch;
            translate([x, -(W/2 - hdr_W*0.55), T/2 + pin_h/2 - overlap])
                cylinder(d=pin_d, h=pin_h, center=true);
        }
    }

    module driver_ic(){
        // Main IC centered
        translate([0, 0, T/2 + ic_H/2 - overlap])
            cube([ic_L, ic_W, ic_H], center=true);

        // Simple "pins" as side ribs (connected)
        rib_t = 0.8;
        rib_h = 1.0;
        rib_len = ic_L*0.9;
        for (sy=[-1,1]) {
            translate([0, sy*(ic_W/2 + rib_t/2 - overlap), T/2 + rib_h/2 - overlap])
                cube([rib_len, rib_t, rib_h], center=true);
        }
    }

    module passives(){
        // Electrolytic cap near terminal block
        cap_x = -L*0.22;
        cap_y =  W*0.18;
        translate([cap_x, cap_y, T/2 + cap_H/2 - overlap])
            cylinder(d=cap_d, h=cap_H, center=true);

        // Two small SMD blocks near IC
        smd_L = 4.0;
        smd_W = 2.0;
        translate([ L*0.22,  W*0.10, T/2 + smd_H/2 - overlap])
            cube([smd_L, smd_W, smd_H], center=true);
        translate([ L*0.22, -W*0.05, T/2 + smd_H/2 - overlap])
            cube([smd_L, smd_W, smd_H], center=true);

        // Small heatsink-like block near IC (still connected)
        hs_L = 10.0;
        hs_W = 8.0;
        hs_H = 3.0;
        translate([0, -W*0.18, T/2 + hs_H/2 - overlap])
            cube([hs_L, hs_W, hs_H], center=true);
    }

    // ---- Build: one connected solid (holes subtracted) ----
    difference(){
        union(){
            pcb();
            color([0.15,0.15,0.15]) terminal_block();
            color([0.10,0.10,0.10]) pin_header();
            color([0.08,0.08,0.08]) driver_ic();
            color([0.20,0.20,0.20]) passives();
        }
        mounting_holes();
    }
}

motor_driver_module();