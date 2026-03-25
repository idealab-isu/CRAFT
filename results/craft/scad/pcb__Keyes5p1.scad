// Microcontroller development board (generic) - 68.58mm x 53.34mm x 1.6mm PCB
// Fixed: ensure visible geometry and ONE connected solid (no floating parts)

$fn = 64;

// Parameters
length = 68.58;      // X
width  = 53.34;      // Y
thickness = 1.6;     // Z (PCB)
corner_radius = 3.0; // rounded PCB corners

// Small overlap to guarantee connectivity between parts
overlap = 0.30;

// Rounded rectangle prism (centered at origin)
module rounded_box(size=[10,10,1], r=1) {
    x = size[0]; y = size[1]; z = size[2];
    rr = min(r, x/2, y/2);
    // Use minkowski for robust 3D rounded corners (always produces solid geometry)
    minkowski() {
        cube([x-2*rr, y-2*rr, z], center=true);
        cylinder(r=rr, h=0.01, center=true);
    }
}

// Component block that sits on top of PCB and overlaps slightly into it
module top_block(sz=[10,10,5], pos=[0,0], z_above=0) {
    translate([pos[0], pos[1], thickness/2 + sz[2]/2 - overlap + z_above])
        cube(sz, center=true);
}

// Component block that sits on bottom of PCB and overlaps slightly into it
module bottom_block(sz=[10,10,5], pos=[0,0], z_below=0) {
    translate([pos[0], pos[1], -(thickness/2 + sz[2]/2 - overlap + z_below)])
        cube(sz, center=true);
}

// Side connector protruding from X edge, overlapping into PCB
module side_connector_x(side=1, body=[12,10,6], y=0, z_center=0) {
    translate([side*(length/2 + body[0]/2 - overlap), y, z_center])
        cube(body, center=true);
}

// Side connector protruding from Y edge, overlapping into PCB
module side_connector_y(side=1, body=[10,12,6], x=0, z_center=0) {
    translate([x, side*(width/2 + body[1]/2 - overlap), z_center])
        cube(body, center=true);
}

module dev_board() {
    union() {
        // PCB
        rounded_box([length, width, thickness], r=corner_radius);

        // USB connector (right edge, centered on PCB thickness)
        side_connector_x(
            side=+1,
            body=[12, 10, 6],
            y=0,
            z_center=0
        );

        // Power jack / large connector (top edge)
        side_connector_y(
            side=+1,
            body=[14, 12, 8],
            x=-(length*0.18),
            z_center=0
        );

        // Pin header strips (two long blocks near left/right edges)
        header_h = 6;
        header_w = 5;
        header_len = width - 10;

        // Left header
        top_block(
            sz=[header_w, header_len, header_h],
            pos=[-(length/2 - header_w/2 - 4), 0]
        );

        // Right header
        top_block(
            sz=[header_w, header_len, header_h],
            pos=[+(length/2 - header_w/2 - 4), 0]
        );

        // Main MCU (center-ish)
        top_block(sz=[14, 14, 3], pos=[-6, 0]);

        // Secondary IC
        top_block(sz=[10, 8, 2.5], pos=[10, -10]);

        // A few small components (caps/resistors) for visual detail
        top_block(sz=[4, 2, 1.5], pos=[-18, 14]);
        top_block(sz=[4, 2, 1.5], pos=[-18, 10]);
        top_block(sz=[3, 3, 2.0], pos=[-2, 18]);
        top_block(sz=[3, 3, 2.0], pos=[6, 18]);

        // Reset button (small)
        top_block(sz=[6, 6, 3], pos=[-24, -18]);

        // Bottom-side components to match underside detail and ensure connectivity
        bottom_block(sz=[16, 12, 3.0], pos=[-10, -6]);
        bottom_block(sz=[10, 10, 2.5], pos=[12, 8]);
        bottom_block(sz=[6, 4, 2.0], pos=[-22, 16]);
    }
}

dev_board();