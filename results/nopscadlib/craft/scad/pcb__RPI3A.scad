// Single-board computer (SBC) proxy model
// Target PCB: 65.0mm x 56.0mm x 1.4mm
// One connected solid (PCB + connectors/components fused with slight overlaps)

$fn = 64;

// Parameters
pcb_length = 65.0;
pcb_width  = 56.0;
pcb_thickness = 1.4;

eps_overlap = 0.8;          // intentional overlap to guarantee connectivity
corner_r = 3.0;             // rounded PCB corners

// Helper: rounded rectangle prism (centered)
module rounded_box_xy(size=[10,10,2], r=1, center=true) {
    x = size[0]; y = size[1]; z = size[2];
    translate(center ? [0,0,0] : [x/2, y/2, z/2])
        linear_extrude(height=z, center=true)
            offset(r=r)
                square([x-2*r, y-2*r], center=true);
}

// PCB with mounting holes (holes are cut, but model remains one connected solid)
module pcb() {
    hole_r = 1.6; // ~3.2mm dia
    hole_edge_x = 3.5;
    hole_edge_y = 3.5;

    difference() {
        color([0.0, 0.4, 0.2])
            rounded_box_xy([pcb_length, pcb_width, pcb_thickness], r=corner_r, center=true);

        // 4 mounting holes near corners
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([
                sx*(pcb_length/2 - hole_edge_x),
                sy*(pcb_width/2  - hole_edge_y),
                0
            ])
            cylinder(h=pcb_thickness + 2, r=hole_r, center=true);
        }
    }
}

// Generic component block placed on top surface, fused by overlap
module top_block(pos=[0,0], size=[10,10,5], z_clear=0) {
    translate([
        pos[0],
        pos[1],
        pcb_thickness/2 + size[2]/2 - eps_overlap + z_clear
    ])
    cube(size, center=true);
}

// Side connector that protrudes from an edge, fused by overlap into PCB
// edge: "right","left","top","bottom" relative to +X,-X,+Y,-Y
module side_connector(edge="right", along=0, size=[16,14,8]) {
    // size = [protrude_len (out of board), width_along_edge, height]
    protrude = size[0];
    along_w  = size[1];
    h        = size[2];

    if (edge == "right") {
        translate([
            pcb_length/2 + protrude/2 - eps_overlap,
            along,
            pcb_thickness/2 + h/2 - eps_overlap
        ])
        cube([protrude, along_w, h], center=true);
    } else if (edge == "left") {
        translate([
            -pcb_length/2 - protrude/2 + eps_overlap,
            along,
            pcb_thickness/2 + h/2 - eps_overlap
        ])
        cube([protrude, along_w, h], center=true);
    } else if (edge == "top") {
        translate([
            along,
            pcb_width/2 + protrude/2 - eps_overlap,
            pcb_thickness/2 + h/2 - eps_overlap
        ])
        cube([along_w, protrude, h], center=true);
    } else if (edge == "bottom") {
        translate([
            along,
            -pcb_width/2 - protrude/2 + eps_overlap,
            pcb_thickness/2 + h/2 - eps_overlap
        ])
        cube([along_w, protrude, h], center=true);
    }
}

// Main SBC model (single connected solid)
module sbc_complete_model() {
    union() {
        pcb();

        // Major connectors (simple proxies), all fused to PCB with calculated placement
        // USB-A like block on right edge
        color([0.75,0.75,0.75])
            side_connector("right", along= pcb_width*0.18, size=[16, 14, 8]);

        // Ethernet-like block on right edge (larger)
        color([0.70,0.70,0.70])
            side_connector("right", along= -pcb_width*0.18, size=[18, 16, 12]);

        // HDMI-like block on bottom edge
        color([0.65,0.65,0.65])
            side_connector("bottom", along= pcb_length*0.10, size=[12, 14, 5]);

        // USB-C / power-like block on bottom edge
        color([0.65,0.65,0.65])
            side_connector("bottom", along= -pcb_length*0.22, size=[10, 10, 4]);

        // 40-pin header proxy on top surface near left side
        color([0.10,0.10,0.10])
            top_block(
                pos=[-pcb_length*0.18, pcb_width*0.18],
                size=[52, 6, 8]
            );

        // Main SoC package
        color([0.15,0.15,0.15])
            top_block(
                pos=[pcb_length*0.10, 0],
                size=[14, 14, 2.2]
            );

        // RAM / secondary IC
        color([0.18,0.18,0.18])
            top_block(
                pos=[pcb_length*0.10, -pcb_width*0.22],
                size=[12, 10, 1.8]
            );

        // Small components cluster (kept connected by being on PCB top)
        color([0.25,0.25,0.25])
            top_block(
                pos=[-pcb_length*0.30, -pcb_width*0.22],
                size=[18, 10, 1.6]
            );

        // Camera/Display connector proxy on top edge
        color([0.85,0.85,0.85])
            side_connector("top", along= pcb_length*0.22, size=[6, 18, 3.5]);

        // MicroSD-like protrusion on left edge (thin)
        color([0.60,0.60,0.60])
            side_connector("left", along= -pcb_width*0.05, size=[10, 16, 2.8]);
    }
}

sbc_complete_model();