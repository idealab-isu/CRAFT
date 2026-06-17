$fn = 64;

// Parameters (mm)
pcb_L = 67.0;
pcb_W = 31.0;
pcb_T = 1.7;

corner_r = 2.0;          // rounded PCB corners
hole_d = 3.2;            // mounting hole diameter
hole_edge = 3.5;         // hole center offset from each edge

copper_thickness = 0.035;
silkscreen_thickness = 0.02;

// Helper: rounded rectangle prism (centered)
module rounded_box(L, W, H, R) {
    R2 = min(R, min(L, W)/2 - 0.01);
    linear_extrude(height=H, center=true)
        offset(r=R2)
            square([L - 2*R2, W - 2*R2], center=true);
}

// Helper: simple component block (centered)
module comp_block(l, w, h) {
    cube([l, w, h], center=true);
}

// PCB with holes (single connected solid will be ensured by later union overlap)
module pcb_with_holes() {
    difference() {
        rounded_box(pcb_L, pcb_W, pcb_T, corner_r);

        // 4 mounting holes
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*(pcb_L/2 - hole_edge), sy*(pcb_W/2 - hole_edge), 0])
                cylinder(d=hole_d, h=pcb_T + 0.6, center=true);
        }
    }
}

// Copper pads/traces as shallow raised features (kept connected via overlap into PCB)
module copper_features() {
    z = pcb_T/2 + copper_thickness/2 - 0.01; // slight overlap into PCB
    color([0.75, 0.45, 0.1])
    translate([0, 0, z]) {
        // A few "bus" bars
        translate([0,  pcb_W*0.22, 0]) cube([pcb_L*0.78, 1.2, copper_thickness], center=true);
        translate([0, -pcb_W*0.22, 0]) cube([pcb_L*0.78, 1.2, copper_thickness], center=true);

        // Some pad groups near ends
        for (i = [-3:3]) {
            translate([-(pcb_L/2 - 10), i*2.2, 0]) cube([2.2, 1.6, copper_thickness], center=true);
            translate([ (pcb_L/2 - 10), i*2.2, 0]) cube([2.2, 1.6, copper_thickness], center=true);
        }
    }
}

// Silkscreen as shallow raised features (kept connected via overlap into PCB)
module silkscreen_features() {
    z = pcb_T/2 + copper_thickness + silkscreen_thickness/2 - 0.01; // overlap into copper/pcb stack
    color([0.95, 0.95, 0.95])
    translate([0, 0, z]) {
        // Border line
        difference() {
            rounded_box(pcb_L*0.96, pcb_W*0.92, silkscreen_thickness, max(0.5, corner_r-0.6));
            rounded_box(pcb_L*0.92, pcb_W*0.88, silkscreen_thickness+0.2, max(0.5, corner_r-0.9));
        }

        // A couple of rectangles suggesting component outlines
        translate([-(pcb_L*0.18), 0, 0]) cube([18, 12, silkscreen_thickness], center=true);
        translate([(pcb_L*0.18), 0, 0]) cube([16, 10, silkscreen_thickness], center=true);
    }
}

// Components/connectors (all connected to PCB by slight overlap into top surface)
module components_and_connectors() {
    top_z = pcb_T/2;

    union() {
        // DC barrel jack-like block on left edge
        jack_l = 14; jack_w = 12; jack_h = 11;
        translate([-(pcb_L/2 - jack_l/2), 0, top_z + jack_h/2 - 0.2])
            comp_block(jack_l, jack_w, jack_h);

        // Screw terminal block on right edge
        term_l = 12; term_w = 10; term_h = 9;
        translate([(pcb_L/2 - term_l/2), 0, top_z + term_h/2 - 0.2])
            comp_block(term_l, term_w, term_h);

        // Large electrolytic capacitor (cylinder)
        cap_d = 10; cap_h = 14;
        translate([-(pcb_L*0.12), pcb_W*0.18, top_z + cap_h/2 - 0.2])
            cylinder(d=cap_d, h=cap_h, center=true);

        // Inductor-like block
        ind_l = 12; ind_w = 12; ind_h = 7;
        translate([0, -pcb_W*0.12, top_z + ind_h/2 - 0.2])
            comp_block(ind_l, ind_w, ind_h);

        // IC/regulator block
        ic_l = 10; ic_w = 8; ic_h = 3;
        translate([pcb_L*0.18, pcb_W*0.18, top_z + ic_h/2 - 0.2])
            comp_block(ic_l, ic_w, ic_h);

        // A few small SMD parts
        smd_l = 3.2; smd_w = 1.6; smd_h = 1.2;
        for (i = [-2:2]) {
            translate([-(pcb_L*0.05) + i*5.0, pcb_W*0.02, top_z + smd_h/2 - 0.2])
                comp_block(smd_l, smd_w, smd_h);
        }
    }
}

// Complete model: one connected solid (components overlap into PCB)
module power_supply_board() {
    union() {
        color([0.0, 0.4, 0.2]) pcb_with_holes();
        copper_features();
        silkscreen_features();
        color([0.15, 0.15, 0.15]) components_and_connectors();
    }
}

power_supply_board();