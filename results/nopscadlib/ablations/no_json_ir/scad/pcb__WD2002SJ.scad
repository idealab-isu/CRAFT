// DC-DC power converter module (single connected solid)
// Overall PCB: 78.0mm x 47.0mm x 1.6mm

pcb_length = 78.0;
pcb_width  = 47.0;
pcb_thickness = 1.6;

corner_r = 0.8;   // modest rounding
$fn = 64;

// Use a real overlap (1-2mm) to guarantee watertight connections
overlap = 1.2;

// --- Helper: rounded rectangle prism (exact outer size) ---
module rounded_rect_prism(L, W, H, R) {
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(L/2 - R), sy*(W/2 - R), 0])
                cylinder(r=R, h=H, center=true);
    }
}

// --- Helper: place a component so it is guaranteed to intersect the PCB by `overlap` ---
module on_pcb(shape_h, child_geom) {
    // PCB top surface is at +pcb_thickness/2 (because PCB is centered at z=0)
    // Put component so its bottom goes `overlap` into the PCB:
    // z_center = pcb_top + shape_h/2 - overlap
    translate([0, 0, pcb_thickness/2 + shape_h/2 - overlap])
        children();
}

// --- Main assembly: PCB + representative components (all connected) ---
module dcdc_module() {

    // Component sizing (representative, not brand-specific)
    // Add a "bond pad" that actually intersects the PCB by `overlap`
    bond_h = 1.6; // thick enough to be robust; will be sunk into PCB by overlap

    // Inductor (large block)
    ind_L = 18;
    ind_W = 18;
    ind_H = 10;

    // Electrolytic capacitors (cylinders)
    cap_r = 5.0;
    cap_H = 12.0;

    // Terminal blocks (input/output)
    term_L = 14;
    term_W = 10;
    term_H = 12;

    // IC / controller
    ic_L = 12;
    ic_W = 10;
    ic_H = 3.0;

    // Small parts cluster
    smd_L = 10;
    smd_W = 8;
    smd_H = 2.0;

    // Positions (kept as in original design intent)
    out_term_pos = [ pcb_length/2 - term_L/2,  pcb_width*0.22, 0];
    in_term_pos  = [-pcb_length/2 + term_L/2, -pcb_width*0.22, 0];
    ind_pos      = [ pcb_length*0.10,         pcb_width*0.10, 0];
    cap1_pos     = [ pcb_length*0.22,        -pcb_width*0.18, 0];
    cap2_pos     = [ pcb_length*0.34,        -pcb_width*0.18, 0];
    ic_pos       = [-pcb_length*0.05,        -pcb_width*0.18, 0];
    smd_pos      = [-pcb_length*0.22,        -pcb_width*0.05, 0];

    // Ensure the paired cylinders are truly merged (remove seam/gap):
    // Make them overlap slightly by reducing center-to-center spacing.
    cap_pair_dx = (cap_r * 2) - overlap; // overlap by `overlap` mm

    union() {
        // PCB
        rounded_rect_prism(pcb_length, pcb_width, pcb_thickness, corner_r);

        // --- Output terminal block (right edge) ---
        translate(out_term_pos)
            on_pcb(term_H)
                cube([term_L, term_W, term_H], center=true);
        // Bond pad (guaranteed intersection into PCB)
        translate(out_term_pos)
            on_pcb(bond_h)
                cube([term_L, term_W, bond_h], center=true);

        // --- Input terminal block (left edge) ---
        translate(in_term_pos)
            on_pcb(term_H)
                cube([term_L, term_W, term_H], center=true);
        translate(in_term_pos)
            on_pcb(bond_h)
                cube([term_L, term_W, bond_h], center=true);

        // --- Inductor (upper middle) ---
        translate(ind_pos)
            on_pcb(ind_H)
                cube([ind_L, ind_W, ind_H], center=true);
        translate(ind_pos)
            on_pcb(bond_h)
                cube([ind_L, ind_W, bond_h], center=true);

        // --- Two capacitors (near right side) ---
        // Build as a single fused solid (pair union) + a fused bond pad under them.
        translate([cap1_pos[0] + cap_pair_dx/2, cap1_pos[1], 0]) {
            // Capacitor bodies fused
            on_pcb(cap_H)
                union() {
                    translate([-cap_pair_dx/2, 0, 0]) cylinder(r=cap_r, h=cap_H, center=true);
                    translate([ cap_pair_dx/2, 0, 0]) cylinder(r=cap_r, h=cap_H, center=true);
                }
            // Bond pad fused (also overlaps into PCB)
            on_pcb(bond_h)
                union() {
                    translate([-cap_pair_dx/2, 0, 0]) cylinder(r=cap_r, h=bond_h, center=true);
                    translate([ cap_pair_dx/2, 0, 0]) cylinder(r=cap_r, h=bond_h, center=true);
                }
        }

        // --- Controller IC (lower middle) ---
        translate(ic_pos)
            on_pcb(ic_H)
                cube([ic_L, ic_W, ic_H], center=true);
        translate(ic_pos)
            on_pcb(bond_h)
                cube([ic_L, ic_W, bond_h], center=true);

        // --- Small SMD cluster (near IC) ---
        translate(smd_pos)
            on_pcb(smd_H)
                cube([smd_L, smd_W, smd_H], center=true);
        translate(smd_pos)
            on_pcb(bond_h)
                cube([smd_L, smd_W, bond_h], center=true);
    }
}

dcdc_module();