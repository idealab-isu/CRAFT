$fn = 48;

// Overall target envelope (must match)
W = 38.0;   // X
D = 32.0;   // Y
H = 33.0;   // Z

// Small overlap to guarantee watertight unions
ov = 0.6;

// Feature sizing (kept within envelope)
tab_h = 3.0;                 // mounting base thickness
body_h = H - tab_h;          // remaining height for transformer body

tab_w = W;                   // tabs span full width
tab_d = D;                   // base spans full depth

// Core/window (visual feature) carved into body
wall = 3.0;                  // outer wall thickness around window
window_w = W - 2*wall;       // X size of window
window_d = D - 2*wall;       // Y size of window
window_h = body_h * 0.55;    // Z size of window

// Bobbin/coil bulge (visual feature) on top
coil_w = W * 0.78;
coil_d = D * 0.70;
coil_h = body_h * 0.22;

// Leads (kept inside envelope; protrude slightly from body but not beyond overall W/D)
lead_r = 0.7;
lead_len = 4.0;
lead_pitch = 3.0;
lead_count = 4;

// Helper: rounded box
module rbox(size=[10,10,10], r=1.5, center=true){
    r2 = min(r, min(size[0], min(size[1], size[2]))/2 - 0.01);
    minkowski(){
        cube([size[0]-2*r2, size[1]-2*r2, size[2]-2*r2], center=center);
        sphere(r=r2);
    }
}

module transformer(){
    union(){
        // Mounting base (tabs)
        translate([0, 0, -H/2 + tab_h/2])
            rbox([tab_w, tab_d, tab_h], r=1.2, center=true);

        // Main body with window cutout
        translate([0, 0, -H/2 + tab_h + body_h/2])
        difference(){
            rbox([W, D, body_h], r=2.0, center=true);

            // Window cutout (centered, does not break outer shell completely)
            translate([0, 0, 0])
                cube([window_w, window_d, window_h], center=true);

            // Slight top recess to suggest laminations/bobbin seat
            translate([0, 0, body_h/2 - coil_h/2])
                cube([coil_w*0.92, coil_d*0.92, coil_h*0.55], center=true);
        }

        // Bobbin/coil bulge on top (connected)
        translate([0, 0, -H/2 + tab_h + body_h - coil_h/2 + ov/2])
            rbox([coil_w, coil_d, coil_h + ov], r=1.2, center=true);

        // Leads/terminals on one side (kept within overall depth)
        // Place them on +Y face of the main body, but not exceeding D/2.
        lead_y_center = (D/2 - lead_len/2); // stays within envelope
        lead_z_base = -H/2 + tab_h + body_h*0.25;

        for (i = [0:lead_count-1]){
            x = (-(lead_count-1)/2 + i) * lead_pitch;
            translate([x, lead_y_center, lead_z_base])
                rotate([90,0,0])
                    cylinder(h=lead_len + ov, r=lead_r, center=true);
        }
    }
}

transformer();