$fn = 64;

// Parameters
length_mm = 40; //[20:80:1]
width_mm  = 16; //[8:32:1]
thickness_mm = 1.6; //[0.8:3.2:0.1]

// Feature parameters
corner_r = 1.2;                 // rounded corner radius
hole_d = 3.0;                   // mounting hole diameter
hole_edge_x = 3.0;              // hole center offset from left/right edge
hole_edge_y = 3.0;              // hole center offset from bottom/top edge

copper_t = 0.08;                // copper thickness (visual)
silk_t   = 0.06;                // silkscreen thickness (visual)

// Structural overlap to guarantee attachment (1-2mm as required)
overlap_mm = 1.0;

// Simple connector block on top side
conn_w = 12.0;
conn_d = 6.0;
conn_h = 5.0;

// Helper: rounded rectangle prism (centered)
module rounded_plate(l, w, h, r) {
    linear_extrude(height=h, center=true)
        offset(r=r)
            square([l - 2*r, w - 2*r], center=true);
}

module RAMPSEndstop() {

    // Derived Z positions (centered model)
    pcb_top_z =  thickness_mm/2;

    // --- FIX: Ensure connector is physically attached (overlaps PCB in Z by overlap_mm)
    // Bottom of connector = pcb_top_z - overlap_mm
    // Center Z = bottom + conn_h/2
    conn_center_z = (pcb_top_z - overlap_mm) + conn_h/2;

    // --- FIX: Ensure connector is not offset away from PCB in Y.
    // Place it centered in Y so it visibly sits on the PCB in all views.
    conn_center_y = 0;

    // Pins: ensure they intersect the connector body (and optionally the PCB)
    pin_d = 1.0;
    pin_h = 3.0;
    pin_pitch = 2.54;

    // Put pins so their TOP penetrates into connector by overlap_mm
    // pin_top_z = conn_center_z + conn_h/2 - overlap_mm
    // => pin_center_z = pin_top_z - pin_h/2
    pin_center_z = (conn_center_z + conn_h/2 - overlap_mm) - pin_h/2;

    // Put pins under the connector in Y, slightly inside the connector depth
    pin_center_y = conn_center_y - conn_d/2 + pin_d/2 + overlap_mm;

    union() {

        // PCB body with mounting holes
        color([0.0, 0.4, 0.2])
        difference() {
            rounded_plate(length_mm, width_mm, thickness_mm, corner_r);

            // 4 corner mounting holes (through)
            for (sx = [-1, 1], sy = [-1, 1]) {
                translate([ sx*(length_mm/2 - hole_edge_x),
                            sy*(width_mm/2  - hole_edge_y),
                            0 ])
                    cylinder(d=hole_d, h=thickness_mm + 2, center=true);
            }
        }

        // Copper pads/traces (top) - thin raised features, overlapped into PCB
        color([0.75, 0.45, 0.1])
        translate([0, 0, pcb_top_z + copper_t/2 - 0.2])  // small embed for manifold
        union() {
            cube([length_mm*0.75, 1.2, copper_t], center=true);

            for (i = [-2:2]) {
                translate([i*(length_mm*0.12), width_mm*0.18, 0])
                    cube([2.2, 2.2, copper_t], center=true);
            }
        }

        // Silkscreen outline (top) - thin raised border, overlapped into PCB
        color([0.95, 0.95, 0.95])
        translate([0, 0, pcb_top_z + silk_t/2 - 0.2])    // small embed for manifold
        difference() {
            rounded_plate(length_mm*0.98, width_mm*0.98, silk_t, max(0.6, corner_r*0.8));
            rounded_plate(length_mm*0.90, width_mm*0.90, silk_t + 0.2, max(0.4, corner_r*0.6));
        }

        // Connector block (black) - FIXED: overlaps PCB in Z and is centered in Y (no side offset)
        color([0.1, 0.1, 0.1])
        translate([0, conn_center_y, conn_center_z])
            cube([conn_w, conn_d, conn_h], center=true);

        // Pins - intersect connector (and can reach into PCB depending on dimensions)
        for (k = [-1, 0, 1]) {
            color([0.8, 0.8, 0.8])
            translate([k*pin_pitch, pin_center_y, pin_center_z])
                cylinder(d=pin_d, h=pin_h, center=true);
        }
    }
}

// Assembly
module assembly() {
    RAMPSEndstop();
}

assembly();