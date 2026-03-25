// A led (cube-like LED module, single connected solid)
// Fixed: ensure visible 3D geometry in all views, cube-like blocks (no through-hole LED look),
// and ONE connected solid (no separate colored parts).

// Parameters
body_w = 10;          // main body width (X)
body_d = 10;          // main body depth (Y)
body_h = 6;           // main body height (Z)

top_w  = 8;           // top block width
top_d  = 8;           // top block depth
top_h  = 3;           // top block height

base_w = 12;          // bottom flange width
base_d = 12;          // bottom flange depth
base_h = 1.5;         // bottom flange height

lead_t = 0.8;         // lead thickness (square)
lead_pitch = 2.54;    // lead spacing
lead_len = 7;         // lead length below base

overlap = 0.6;        // overlap to guarantee watertight union

module led_solid() {
    total_h = base_h + body_h + top_h;
    z0 = -total_h/2;

    union() {
        // Base flange
        translate([0, 0, z0 + base_h/2])
            cube([base_w, base_d, base_h + overlap], center=true);

        // Main body (sits on base)
        translate([0, 0, z0 + base_h + body_h/2])
            cube([body_w, body_d, body_h + overlap], center=true);

        // Top block (sits on body)
        translate([0, 0, z0 + base_h + body_h + top_h/2])
            cube([top_w, top_d, top_h + overlap], center=true);

        // Leads: start slightly inside the base to ensure connection
        lead_start_z = z0 + base_h - overlap;          // inside base
        lead_center_z = lead_start_z - lead_len/2;     // extend downward

        for (sx = [-1, 1]) {
            translate([sx*lead_pitch/2, 0, lead_center_z])
                cube([lead_t, lead_t, lead_len + overlap], center=true);
        }
    }
}

led_solid();