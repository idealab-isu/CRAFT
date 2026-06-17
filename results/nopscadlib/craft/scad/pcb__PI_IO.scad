// Printed Circuit Board (PCB) - 35.56mm x 25.4mm x 1.6mm
// One connected solid, with subtle PCB-like edge rounding and corner chamfers.

$fn = 64;

// Parameters
pcb_L = 35.56; // length (X)
pcb_W = 25.4;  // width  (Y)
pcb_T = 1.6;   // thickness (Z)

// Edge styling (kept small relative to thickness)
edge_r = min(0.6, pcb_T/2 - 0.05);   // rounded vertical edges
chamfer = 0.35;                      // small corner chamfer on top/bottom

module pcb_solid(L, W, T, r, c) {
    // Base rounded-rectangle prism via hull of corner cylinders
    module rounded_prism() {
        hull() {
            for (sx = [-1, 1], sy = [-1, 1])
                translate([sx*(L/2 - r), sy*(W/2 - r), 0])
                    cylinder(r=r, h=T, center=true);
        }
    }

    // Add slight top/bottom corner chamfer by intersecting with a tapered hull
    // (keeps a single connected solid; no floating parts)
    intersection() {
        rounded_prism();

        // Tapered "envelope" that trims corners slightly near top/bottom
        hull() {
            // Middle section (full size)
            translate([0, 0, 0])
                cube([L, W, T - 2*c], center=true);

            // Top reduced
            translate([0, 0, (T/2 - c)])
                cube([L - 2*c, W - 2*c, 2*c], center=true);

            // Bottom reduced
            translate([0, 0, -(T/2 - c)])
                cube([L - 2*c, W - 2*c, 2*c], center=true);
        }
    }
}

// Final Output
color([0.0, 0.4, 0.2])
pcb_solid(pcb_L, pcb_W, pcb_T, edge_r, chamfer);