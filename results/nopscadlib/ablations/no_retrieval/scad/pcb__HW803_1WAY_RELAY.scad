$fn = 48;

// Target PCB dimensions
pcb_L = 50.0;
pcb_W = 26.0;
pcb_T = 1.6;

// Small overlap to guarantee one connected solid
eps = 0.25;

// --- Feature sizes (approximate relay module components) ---
corner_r = 1.2;

// Mounting holes (typical 2-hole relay board)
hole_d = 3.2;
hole_edge_x = 3.0;
hole_edge_y = 3.0;

// Relay body
relay_L = 19.0;
relay_W = 15.5;
relay_H = 15.0;

// Screw terminal block
term_L = 15.0;
term_W = 10.0;
term_H = 12.0;

// Pin header block (3-pin)
hdr_L = 8.0;
hdr_W = 6.0;
hdr_H = 8.5;

// Small components (caps/resistors)
comp1_L = 8.0; comp1_W = 5.0; comp1_H = 4.0;
comp2_L = 6.0; comp2_W = 4.0; comp2_H = 3.0;

// Helper: rounded rectangle prism
module rounded_box(size=[10,10,2], r=1, center=true) {
    l = size[0]; w = size[1]; h = size[2];
    translate(center ? [0,0,0] : [l/2, w/2, h/2])
        linear_extrude(height=h, center=true)
            offset(r=r)
                square([l-2*r, w-2*r], center=true);
}

// Helper: place a part on top of PCB with guaranteed overlap
module on_top(part_h) {
    translate([0,0, pcb_T/2 + part_h/2 - eps])
        children();
}

module relay_module() {
    union() {
        // PCB with mounting holes (holes are subtracted but overall remains one solid)
        color([0.0, 0.4, 0.2])
        difference() {
            rounded_box([pcb_L, pcb_W, pcb_T], r=corner_r, center=true);

            // Two mounting holes along the long axis
            for (sx = [-1, 1]) {
                translate([ sx*(pcb_L/2 - hole_edge_x), (pcb_W/2 - hole_edge_y), 0 ])
                    cylinder(d=hole_d, h=pcb_T + 2, center=true);
            }
        }

        // Relay body (top side)
        color([0.15, 0.15, 0.15])
        translate([ -pcb_L*0.10, 0, 0 ])
            on_top(relay_H)
                rounded_box([relay_L, relay_W, relay_H], r=1.0, center=true);

        // Screw terminal block near one end
        color([0.0, 0.35, 0.75])
        translate([ pcb_L/2 - term_L/2 - 2.0, 0, 0 ])
            on_top(term_H)
                rounded_box([term_L, term_W, term_H], r=0.8, center=true);

        // Pin header block near opposite end
        color([0.05, 0.05, 0.05])
        translate([ -pcb_L/2 + hdr_L/2 + 2.0, -pcb_W/2 + hdr_W/2 + 2.0, 0 ])
            on_top(hdr_H)
                rounded_box([hdr_L, hdr_W, hdr_H], r=0.6, center=true);

        // A couple of small components to make it recognizable
        color([0.85, 0.75, 0.15])
        translate([ -pcb_L*0.05, pcb_W*0.28, 0 ])
            on_top(comp1_H)
                rounded_box([comp1_L, comp1_W, comp1_H], r=0.6, center=true);

        color([0.75, 0.75, 0.75])
        translate([ pcb_L*0.05, -pcb_W*0.10, 0 ])
            on_top(comp2_H)
                rounded_box([comp2_L, comp2_W, comp2_H], r=0.5, center=true);

        // Simple "pins" under the header (kept connected by overlapping into PCB)
        pin_d = 1.0;
        pin_h = 4.0;
        pin_pitch = 2.54;
        for (i = [-1, 0, 1]) {
            color([0.8, 0.8, 0.8])
            translate([ -pcb_L/2 + 2.0 + hdr_L/2 + i*pin_pitch, -pcb_W/2 + 2.0 + hdr_W/2, 0 ])
                translate([0, 0, -pcb_T/2 - pin_h/2 + eps])
                    cylinder(d=pin_d, h=pin_h, center=true);
        }
    }
}

relay_module();