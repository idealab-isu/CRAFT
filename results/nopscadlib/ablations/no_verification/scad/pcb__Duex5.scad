$fn = 64;

// Parameters
pcb_length = 123.0;      // X
pcb_width  = 100.0;      // Y
pcb_thickness = 1.6;     // Z

// Detail parameters (kept proportional and fully connected)
corner_r = 4;
hole_d = 3.2;
hole_edge_x = 6.0;
hole_edge_y = 6.0;

overlap = 0.2; // small overlap to guarantee watertight unions

// ---------- Helpers ----------
module rounded_rect_2d(l, w, r) {
    // 2D rounded rectangle centered at origin
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(l/2 - r), sy*(w/2 - r)]) circle(r=r);
    }
}

module pcb_plate() {
    // Rounded PCB outline
    color([0.0, 0.4, 0.2])
    linear_extrude(height=pcb_thickness, center=true)
        rounded_rect_2d(pcb_length, pcb_width, corner_r);
}

module mounting_holes() {
    // Through-holes near corners
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx*(pcb_length/2 - hole_edge_x), sy*(pcb_width/2 - hole_edge_y), 0])
            cylinder(h=pcb_thickness + 2, d=hole_d, center=true);
    }
}

module component_box(size_xyz, pos_xyz, col=[0.15,0.15,0.15]) {
    // Places a component so it sits on top of the PCB and slightly overlaps into it
    // pos_xyz is XY center position on PCB; Z is computed from sizes
    sx = size_xyz[0]; sy = size_xyz[1]; sz = size_xyz[2];
    x = pos_xyz[0]; y = pos_xyz[1];
    z = pcb_thickness/2 + sz/2 - overlap;
    color(col)
        translate([x, y, z]) cube([sx, sy, sz], center=true);
}

module connector_block(size_xyz, pos_xyz, col=[0.05,0.05,0.05]) {
    component_box(size_xyz, pos_xyz, col);
}

// ---------- Model ----------
module pcb_complete_model() {
    union() {
        // PCB with holes
        difference() {
            pcb_plate();
            mounting_holes();
        }

        // Major connectors along one long edge (top edge, +Y)
        conn_y = pcb_width/2 - 6.0;
        connector_block([38, 12, 12], [-(pcb_length*0.20),  conn_y, 0], [0.05,0.05,0.05]); // power/terminal
        connector_block([28, 10, 10], [ (pcb_length*0.18),  conn_y, 0], [0.05,0.05,0.05]); // I/O header

        // USB + SD-like blocks on right edge (+X)
        edge_x = pcb_length/2 - 7.0;
        connector_block([14, 16, 8], [edge_x,  pcb_width*0.18, 0], [0.75,0.75,0.75]); // USB
        connector_block([18, 14, 6], [edge_x, -pcb_width*0.10, 0], [0.2,0.2,0.2]);     // SD

        // Stepper driver heatsink-like blocks (center area)
        component_box([16, 16, 6], [-(pcb_length*0.18),  pcb_width*0.05, 0], [0.6,0.6,0.6]);
        component_box([16, 16, 6], [-(pcb_length*0.02),  pcb_width*0.05, 0], [0.6,0.6,0.6]);
        component_box([16, 16, 6], [ (pcb_length*0.14),  pcb_width*0.05, 0], [0.6,0.6,0.6]);

        // MCU / main IC
        component_box([22, 22, 3], [-(pcb_length*0.05), -pcb_width*0.18, 0], [0.1,0.1,0.1]);

        // Capacitors (cylinders) near power area
        cap_r = 4.5; cap_h = 10;
        for (i = [0:1]) {
            translate([-(pcb_length*0.32) + i*12, pcb_width*0.22, pcb_thickness/2 + cap_h/2 - overlap])
                color([0.1,0.1,0.1]) cylinder(h=cap_h, r=cap_r, center=true);
        }

        // Small pin headers along bottom edge (-Y)
        hdr_y = -(pcb_width/2 - 5.0);
        for (i = [0:4]) {
            x = -pcb_length*0.35 + i*(pcb_length*0.18);
            connector_block([18, 6, 6], [x, hdr_y, 0], [0.05,0.05,0.05]);
        }
    }
}

// Render
pcb_complete_model();