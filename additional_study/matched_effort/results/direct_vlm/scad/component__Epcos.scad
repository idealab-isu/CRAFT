$fn = 64;

// Thermistor: EPCOS/TDK B57560G104F (100k, 1%)
// Radial epoxy-coated NTC bead with two leads.
// Single connected solid (body + leads fused with slight overlaps).

module thermistor_epcos_B57560G104F(
    bead_d = 2.2,          // epoxy bead diameter (mm)
    bead_l = 3.2,          // epoxy bead length along lead axis (mm)
    lead_d = 0.45,         // lead wire diameter (mm)
    lead_pitch = 2.54,     // lead spacing (mm)
    lead_len = 28,         // lead length from bead exit to end (mm)
    body_color = [0.08,0.08,0.08],
    lead_color = [0.75,0.75,0.78]
){
    // Geometry conventions:
    // - Bead axis along Y, centered at origin.
    // - Leads run along +Y from bead, spaced along X by lead_pitch.
    // - No bends (avoids rotate_extrude artifacts / floating fragments).
    // - Slight overlaps ensure watertight union.

    overlap = 0.15;                 // small overlap to guarantee connectivity
    x_off = lead_pitch/2;
    y_bead_front = bead_l/2;        // bead front face (toward +Y)

    // Build as one connected solid; color is cosmetic only.
    union() {
        // Body (capsule)
        color(body_color)
        union() {
            rotate([90,0,0])
                cylinder(d=bead_d, h=bead_l, center=true);
            translate([0,  y_bead_front, 0]) sphere(d=bead_d);
            translate([0, -y_bead_front, 0]) sphere(d=bead_d);
        }

        // Leads (two straight wires), slightly embedded into bead
        color(lead_color)
        for (sx = [-1, 1]) {
            x = sx * x_off;

            // Start slightly inside bead to fuse; extend outwards along +Y
            y0 = y_bead_front - overlap;
            y1 = y_bead_front + lead_len;

            translate([x, (y0 + y1)/2, 0])
                rotate([90,0,0])
                    cylinder(d=lead_d, h=(y1 - y0), center=true);
        }
    }
}

// Render
thermistor_epcos_B57560G104F();