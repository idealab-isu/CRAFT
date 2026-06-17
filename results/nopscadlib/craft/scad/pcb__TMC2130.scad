// Stepper motor driver board (PCB) 20.0mm x 14.0mm x 1.6mm
// Single connected solid (all parts overlap slightly into PCB)

$fn = 48;

// --- Parameters (mm) ---
pcb_L = 20.0;
pcb_W = 14.0;
pcb_T = 1.6;

corner_R = 1.0;

overlap = 0.25;          // small overlap to guarantee connectivity
eps = 0.01;

// Mount holes (typical small PCB)
mount_hole_d = 2.2;
mount_hole_edge = 2.5;

// Header pins (two 1x8 rows along long edges)
pin_pitch = 2.54;
pins_per_side = 8;
pin_d = 0.7;
pin_h = 3.0;

header_body_T = 2.5;     // plastic thickness (in Y)
header_body_H = 2.6;     // plastic height (in Z)
header_body_inset = 0.6; // inset from PCB edge

// Main IC (driver)
ic_L = 10.0;
ic_W = 10.0;
ic_H = 1.8;

// Small trimpot (common on stepper driver boards)
trimp_L = 6.0;
trimp_W = 6.0;
trimp_H = 3.0;

// A couple of passives
passive_L = 3.2;
passive_W = 1.6;
passive_H = 1.0;

// Silkscreen rim
silk_T = 0.12;
silk_margin = 0.6;

// --- Helpers ---
module rounded_rect_prism(L, W, H, R) {
    // Minkowski rounded rectangle prism
    minkowski() {
        cube([L - 2*R, W - 2*R, H], center=true);
        cylinder(r=R, h=eps, center=true);
    }
}

module pcb_body() {
    color([0.0, 0.35, 0.18])
    rounded_rect_prism(pcb_L, pcb_W, pcb_T, corner_R);
}

module mount_holes_cut() {
    for (x = [-1, 1], y = [-1, 1]) {
        translate([x*(pcb_L/2 - mount_hole_edge),
                   y*(pcb_W/2 - mount_hole_edge),
                   0])
            cylinder(d=mount_hole_d, h=pcb_T + 2, center=true);
    }
}

module header_row(side=1) {
    // side = +1 (top edge, +Y) or -1 (bottom edge, -Y)
    row_len = (pins_per_side - 1) * pin_pitch;
    y_center = side*(pcb_W/2 - header_body_inset - header_body_T/2);

    // Plastic body (overlaps into PCB)
    color("Black")
    translate([0,
               y_center,
               pcb_T/2 + header_body_H/2 - overlap])
        cube([row_len + pin_pitch, header_body_T, header_body_H], center=true);

    // Pins (overlap into PCB and extend below)
    color([0.85, 0.75, 0.2])
    for (i = [0:pins_per_side-1]) {
        x = -row_len/2 + i*pin_pitch;
        translate([x,
                   y_center,
                   -pcb_T/2 - pin_h/2 + overlap])
            cylinder(d=pin_d, h=pin_h + pcb_T, center=true);
    }
}

module ic_pkg() {
    color("DimGray")
    translate([0, 0, pcb_T/2 + ic_H/2 - overlap])
        cube([ic_L, ic_W, ic_H], center=true);
}

module trimpot() {
    // Place near one corner, but keep within board outline
    x = pcb_L/2 - mount_hole_edge - trimp_L/2;
    y = 0;
    color([0.1, 0.35, 0.75])
    translate([x, y, pcb_T/2 + trimp_H/2 - overlap])
        cube([trimp_L, trimp_W, trimp_H], center=true);
}

module passives() {
    color([0.75, 0.75, 0.78])
    union() {
        // Left side passive
        translate([-pcb_L/2 + mount_hole_edge + passive_L/2,
                   0,
                   pcb_T/2 + passive_H/2 - overlap])
            cube([passive_L, passive_W, passive_H], center=true);

        // Near top edge passive
        translate([0,
                   pcb_W/2 - mount_hole_edge - passive_W/2,
                   pcb_T/2 + passive_H/2 - overlap])
            cube([passive_L, passive_W, passive_H], center=true);
    }
}

module silkscreen_rim() {
    // Thin rim on top surface; overlaps into PCB
    color("White")
    difference() {
        translate([0, 0, pcb_T/2 + silk_T/2 - overlap])
            rounded_rect_prism(pcb_L - 2*silk_margin, pcb_W - 2*silk_margin, silk_T, max(0.2, corner_R*0.6));
        translate([0, 0, pcb_T/2 + silk_T/2 - overlap])
            rounded_rect_prism(pcb_L - 2*(silk_margin + 0.7),
                               pcb_W - 2*(silk_margin + 0.7),
                               silk_T + 2*eps,
                               max(0.2, corner_R*0.6));
    }
}

// --- Complete connected model ---
module complete_model() {
    union() {
        // PCB with holes
        difference() {
            pcb_body();
            mount_holes_cut();
        }

        // Components (all overlap slightly into PCB)
        header_row(+1);
        header_row(-1);
        ic_pkg();
        trimpot();
        passives();
        silkscreen_rim();
    }
}

complete_model();