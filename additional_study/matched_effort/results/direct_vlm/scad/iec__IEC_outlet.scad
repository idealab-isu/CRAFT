$fn=96;

// IEC power inlet module (RS 811-7193 style approximation)
// Overall flange/faceplate: 40.0mm x 32.0mm
// One connected solid: flange + rear housing + rear features + terminals (all fused).

// ---------------- Parameters ----------------
plate_w = 40.0;
plate_h = 32.0;
plate_t = 3.0;
plate_r = 2.0;

// Rear housing (behind plate)
body_w = 30.0;
body_h = 22.0;
body_d = 24.0;
body_r = 1.6;

// Front recessed "inlet face" pocket
pocket_w = 30.0;
pocket_h = 22.0;
pocket_r = 2.0;
pocket_d = 1.6;          // depth into plate from front

// IEC C14 opening (approx)
iec_w = 27.5;
iec_h = 19.5;
iec_r = 2.0;

// Add two small key notches typical of IEC inlets (approx)
key_w = 3.0;
key_h = 2.2;
key_y = 6.2;             // offset from center

// Mounting holes (2-hole flange typical)
hole_d = 3.2;            // M3 clearance
hole_x = 16.0;           // half spacing along width

// Rear terminals (3 blades) - fused to body
term_w = 6.3;            // blade width (Y)
term_t = 0.8;            // blade thickness (X)
term_len = 12.0;         // protrusion beyond rear (Z)
term_gap = 7.0;          // center-to-center spacing (X)

// Back-side distinguishable features (molded details)
boss_d = 6.0;            // rear boss depth
boss_w = 18.0;
boss_h = 14.0;
boss_r = 1.2;

rib_t = 2.0;             // ribs thickness
rib_h = 10.0;            // ribs height (Y)
rib_d = 10.0;            // ribs depth (Z)

// Small overlap to guarantee connectivity
ov = 0.6;

// ---------------- Helpers ----------------
module rounded_rect_2d(w,h,r){
    r2 = min(r, min(w,h)/2);
    offset(r=r2) offset(delta=-r2) square([w,h], center=true);
}

module rounded_prism(w,h,d,r){
    linear_extrude(height=d, center=false)
        rounded_rect_2d(w,h,r);
}

module slot_rounded(w,h,r,depth){
    linear_extrude(height=depth, center=false)
        rounded_rect_2d(w,h,r);
}

module blade_terminal_y(wY, tX, lenZ){
    // Blade oriented: thickness=X, width=Y, length=Z (rearward)
    // Built with a slight hull "softening" but remains a solid prism.
    hull(){
        cube([tX, wY, lenZ], center=false);
        translate([0.12,0.12,0.12])
            cube([max(tX-0.24,0.2), max(wY-0.24,0.2), max(lenZ-0.24,0.2)], center=false);
    }
}

// ---------------- Model ----------------
module iec_inlet_module(){
    difference(){
        union(){
            // Faceplate / flange (40 x 32)
            rounded_prism(plate_w, plate_h, plate_t, plate_r);

            // Rear housing (connected by overlap into plate)
            translate([0,0,plate_t - ov])
                rounded_prism(body_w, body_h, body_d + ov, body_r);

            // Back-side molded boss (distinct from front; makes back view different)
            // Attached to rear face of housing with overlap.
            translate([0,0,plate_t + body_d - ov])
                rounded_prism(boss_w, boss_h, boss_d + ov, boss_r);

            // Back-side ribs (two vertical ribs on rear housing)
            // Attached to rear face of housing with overlap.
            for (sx=[-1,1]){
                translate([
                    sx*(body_w/2 - rib_t/2 - 1.0),                 // near side walls
                    -rib_h/2,                                      // centered in Y
                    plate_t + body_d - ov                          // start at rear face
                ])
                    cube([rib_t, rib_h, rib_d + ov], center=false);
            }

            // Rear terminals (3), fused into rear boss by starting inside it
            // Place them centered in Y, spaced in X, protruding out the back.
            term_start_z = plate_t + body_d + boss_d - (term_len + 1.2); // ensures they start inside boss
            for (i=[-1,0,1]){
                translate([
                    i*term_gap - term_t/2,                         // X (thickness axis)
                    -term_w/2,                                     // Y (width axis)
                    term_start_z                                   // Z start (inside boss)
                ])
                    blade_terminal_y(term_w, term_t, term_len + 1.2); // +1.2 ensures fusion
            }
        }

        // Front recessed pocket (inlet face geometry)
        translate([0,0,plate_t - pocket_d])
            slot_rounded(pocket_w, pocket_h, pocket_r, pocket_d + 0.02);

        // IEC opening through plate and housing (but NOT through rear boss, so back differs)
        translate([0,0,-0.02])
            slot_rounded(iec_w, iec_h, iec_r, plate_t + body_d + 0.04);

        // Key notches (small rectangular cutouts) to suggest IEC inlet face details
        for (sy=[-1,1]){
            translate([iec_w/2 - key_w/2, sy*key_y - key_h/2, -0.02])
                cube([key_w, key_h, plate_t + pocket_d + 0.04], center=false);
        }

        // Mounting holes (2) through flange
        for (sx=[-1,1]){
            translate([sx*hole_x, 0, -0.02])
                cylinder(d=hole_d, h=plate_t + 0.04, center=false);
        }

        // Light hollowing of rear housing ONLY (keeps molded look)
        // Do not hollow the rear boss so terminals remain clearly fused and back looks different.
        wall = 2.2;
        translate([0,0,plate_t + wall])
            rounded_prism(body_w - 2*wall, body_h - 2*wall, body_d - wall + 0.02, max(body_r-0.6,0.6));
    }
}

iec_inlet_module();