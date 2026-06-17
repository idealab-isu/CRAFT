$fn = 64;

// Target dimensions (mm)
pcb_length    = 100.75;
pcb_width     = 70.25;
pcb_thickness = 1.6;

// Board details
corner_radius           = 4;
mounting_hole_diameter  = 3.5;
mounting_hole_offset_x  = 5.0;
mounting_hole_offset_y  = 5.0;

// Small overlap to guarantee one connected solid
overlap = 0.25;

// Tab/ear geometry to match reference silhouette (protrusions on edges)
tab_w = 12;   // width along edge
tab_d = 8;    // protrusion depth outward from board edge

// ---------- Helpers ----------
module rounded_rect_2d(L, W, R) {
    hull() {
        translate([ R,     R]) circle(r=R);
        translate([L - R,  R]) circle(r=R);
        translate([ R, W - R]) circle(r=R);
        translate([L - R, W - R]) circle(r=R);
    }
}

module pcb_outline_2d() {
    // Base rounded rectangle + 4 edge tabs (top, bottom, left, right)
    union() {
        rounded_rect_2d(pcb_length, pcb_width, corner_radius);

        // Top tab (centered)
        translate([pcb_length/2 - tab_w/2, pcb_width - overlap])
            square([tab_w, tab_d + overlap], center=false);

        // Bottom tab (centered)
        translate([pcb_length/2 - tab_w/2, -tab_d])
            square([tab_w, tab_d + overlap], center=false);

        // Left tab (centered)
        translate([-tab_d, pcb_width/2 - tab_w/2])
            square([tab_d + overlap, tab_w], center=false);

        // Right tab (centered)
        translate([pcb_length - overlap, pcb_width/2 - tab_w/2])
            square([tab_d + overlap, tab_w], center=false);
    }
}

module pcb_body() {
    // PCB with mounting holes
    difference() {
        linear_extrude(height=pcb_thickness)
            pcb_outline_2d();

        for (x = [mounting_hole_offset_x, pcb_length - mounting_hole_offset_x])
            for (y = [mounting_hole_offset_y, pcb_width - mounting_hole_offset_y])
                translate([x, y, pcb_thickness/2])
                    cylinder(h=pcb_thickness + 2, d=mounting_hole_diameter, center=true);
    }
}

// Generic component that is guaranteed to touch the PCB top surface
module component_box(pos=[0,0], size=[10,10,5]) {
    translate([pos[0], pos[1], pcb_thickness - overlap])
        cube([size[0], size[1], size[2] + overlap], center=false);
}

// Edge connector that protrudes beyond the PCB outline but remains connected
module edge_connector(side="right", along=10, body=[14, 10, 9], protrude=6) {
    // body = [size_x, size_y, height] (only size_y used for left/right; size_x used for top/bottom)
    if (side == "right") {
        translate([pcb_length - overlap, along, pcb_thickness - overlap])
            cube([protrude + overlap, body[1], body[2] + overlap], center=false);
    } else if (side == "left") {
        translate([-protrude, along, pcb_thickness - overlap])
            cube([protrude + overlap, body[1], body[2] + overlap], center=false);
    } else if (side == "top") {
        translate([along, pcb_width - overlap, pcb_thickness - overlap])
            cube([body[0], protrude + overlap, body[2] + overlap], center=false);
    } else if (side == "bottom") {
        translate([along, -protrude, pcb_thickness - overlap])
            cube([body[0], protrude + overlap, body[2] + overlap], center=false);
    }
}

// ---------- Assembly (ONE connected solid) ----------
module mainboard_assembly() {
    union() {
        // PCB (100.75 x 70.25 x 1.6) with tabs and mounting holes
        pcb_body();

        // Major IC / MCU
        component_box(
            pos=[pcb_length*0.42, pcb_width*0.38],
            size=[18, 18, 3.2]
        );

        // Stepper driver area (blocky representation)
        component_box(
            pos=[pcb_length*0.12, pcb_width*0.55],
            size=[28, 12, 4.0]
        );

        // Power section / heatsink block
        component_box(
            pos=[pcb_length*0.68, pcb_width*0.18],
            size=[22, 18, 10.0]
        );

        // USB / comms connector on right edge (connected)
        edge_connector(
            side="right",
            along=pcb_width*0.18,
            body=[0, 14, 8],
            protrude=8
        );

        // Power input connector on left edge (connected)
        edge_connector(
            side="left",
            along=pcb_width*0.15,
            body=[0, 12, 10],
            protrude=10
        );

        // Endstop / IO header on top edge (connected)
        edge_connector(
            side="top",
            along=pcb_length*0.18,
            body=[12, 0, 6],
            protrude=6
        );

        // Motor header block on bottom edge (connected)
        edge_connector(
            side="bottom",
            along=pcb_length*0.55,
            body=[14, 0, 7],
            protrude=7
        );

        // A few small capacitors/regulators (simple blocks)
        component_box(
            pos=[pcb_length*0.30, pcb_width*0.18],
            size=[8, 6, 5.5]
        );
        component_box(
            pos=[pcb_length*0.58, pcb_width*0.62],
            size=[10, 8, 4.5]
        );
        component_box(
            pos=[pcb_length*0.78, pcb_width*0.55],
            size=[8, 8, 6.0]
        );
    }
}

mainboard_assembly();