$fn = 64;

// =====================
// Mainboard parameters
// =====================
pcb_length = 100.75;
pcb_width  = 70.25;
pcb_thickness = 1.6;

// Mounting holes
hole_diameter = 3.2;
hole_edge_margin_x = 6.0;
hole_edge_margin_y = 6.0;

// Visual/feature parameters (kept simple but recognizable)
corner_r = 2.0;                 // rounded corners
copper_keepout = 0.0;           // not used; placeholder

// Component heights (top side)
connector_height = 10.0;
chip_height = 2.0;
cap_height = 6.0;
silkscreen_thickness = 0.2;

// Overlaps to guarantee ONE connected solid
z_overlap = 0.25;               // overlap into PCB
xy_overlap = 0.5;               // overlap into PCB edge for side connectors

// Connector sizes
conn1_length = 18.0;
conn1_width  = 12.0;

conn2_length = 22.0;
conn2_width  = 10.0;

conn3_length = 14.0;
conn3_width  = 8.0;

// Chips/components sizes
chip1_length = 18.0;
chip1_width  = 18.0;

chip2_length = 12.0;
chip2_width  = 10.0;

cap_radius = 3.0;

// Silkscreen
silkscreen_inset = 3.0;

// =====================
// Helpers
// =====================
module rounded_rect_2d(L, W, R) {
    // Robust rounded rectangle (no text)
    R2 = min(R, min(L, W)/2);
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(L/2 - R2), sy*(W/2 - R2)])
                circle(r=R2);
    }
}

module pcb_solid() {
    color([0.0, 0.4, 0.2])
    linear_extrude(height=pcb_thickness, center=true)
        rounded_rect_2d(pcb_length, pcb_width, corner_r);
}

module mounting_holes_cut() {
    // Cut cylinders slightly taller than PCB to ensure clean subtraction
    h = pcb_thickness + 2.0;
    r = hole_diameter/2;

    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx*(pcb_length/2 - hole_edge_margin_x),
                   sy*(pcb_width/2  - hole_edge_margin_y),
                   0])
            cylinder(h=h, r=r, center=true);
    }
}

// Place a top-side component so it is guaranteed to intersect the PCB
module place_on_top(pos=[0,0], size=[10,10,5]) {
    // size = [x,y,z]
    translate([pos[0], pos[1], pcb_thickness/2 + size[2]/2 - z_overlap])
        cube(size, center=true);
}

module place_cyl_on_top(pos=[0,0], r=3, h=6) {
    translate([pos[0], pos[1], pcb_thickness/2 + h/2 - z_overlap])
        cylinder(r=r, h=h, center=true);
}

// Side connector that protrudes outward from an edge but overlaps into PCB
// edge: "left","right","top","bottom"
module side_connector(edge="left", len=18, wid=12, h=10, offset=0) {
    // len runs along the edge direction, wid is perpendicular in-plane
    // For left/right: len along Y, wid along X
    // For top/bottom: len along X, wid along Y
    if (edge == "left") {
        // protrude to -X
        translate([-(pcb_length/2) - (wid/2) + xy_overlap,
                   offset,
                   pcb_thickness/2 + h/2 - z_overlap])
            cube([wid, len, h], center=true);
    } else if (edge == "right") {
        translate([(pcb_length/2) + (wid/2) - xy_overlap,
                   offset,
                   pcb_thickness/2 + h/2 - z_overlap])
            cube([wid, len, h], center=true);
    } else if (edge == "top") {
        translate([offset,
                   (pcb_width/2) + (wid/2) - xy_overlap,
                   pcb_thickness/2 + h/2 - z_overlap])
            cube([len, wid, h], center=true);
    } else if (edge == "bottom") {
        translate([offset,
                   -(pcb_width/2) - (wid/2) + xy_overlap,
                   pcb_thickness/2 + h/2 - z_overlap])
            cube([len, wid, h], center=true);
    }
}

// Simple silkscreen as a thin raised layer (still connected via overlap)
module silkscreen() {
    // Border ring
    outerL = pcb_length - 2*silkscreen_inset;
    outerW = pcb_width  - 2*silkscreen_inset;
    innerL = outerL - 2.0;
    innerW = outerW - 2.0;

    translate([0,0, pcb_thickness/2 + silkscreen_thickness/2 - z_overlap])
    difference() {
        linear_extrude(height=silkscreen_thickness, center=true)
            rounded_rect_2d(outerL, outerW, max(0.5, corner_r-0.5));
        linear_extrude(height=silkscreen_thickness + 0.2, center=true)
            rounded_rect_2d(innerL, innerW, max(0.5, corner_r-0.8));
    }

    // A couple of blocks to suggest markings
    translate([0,0, pcb_thickness/2 + silkscreen_thickness/2 - z_overlap])
    linear_extrude(height=silkscreen_thickness, center=true) {
        translate([-pcb_length/6, -pcb_width/4])
            square([pcb_length/6, pcb_width/10], center=true);
        translate([ pcb_length/5,  pcb_width/6])
            square([pcb_length/8, pcb_width/12], center=true);
    }
}

// =====================
// Mainboard assembly
// =====================
module complete_mainboard() {
    union() {
        // PCB with holes (still one solid after union with components)
        difference() {
            pcb_solid();
            mounting_holes_cut();
        }

        // Edge connectors/ports (recognizable features)
        // Left edge: larger connector
        side_connector("left",  len=conn1_length, wid=conn1_width, h=connector_height, offset=0);

        // Right edge: medium connector, offset downward
        side_connector("right", len=conn2_length, wid=conn2_width, h=connector_height, offset=-pcb_width/4);

        // Top edge: smaller connector
        side_connector("top",   len=conn3_length, wid=conn3_width, h=connector_height*0.8, offset=0);

        // Bottom edge: small power/IO block to add realism
        side_connector("bottom", len=16, wid=10, h=connector_height*0.7, offset=0);

        // Main IC and secondary IC
        place_on_top([0, 0], [chip1_length, chip1_width, chip_height]);
        place_on_top([-pcb_length/4, pcb_width/5], [chip2_length, chip2_width, chip_height*0.9]);

        // Capacitors
        place_cyl_on_top([ pcb_length/4,  pcb_width/5], r=cap_radius, h=cap_height);
        place_cyl_on_top([ pcb_length/4, -pcb_width/6], r=cap_radius*0.9, h=cap_height*0.9);

        // A couple of low-profile parts to suggest component layout
        place_on_top([ pcb_length/6, -pcb_width/8], [10, 6, 1.2]);
        place_on_top([-pcb_length/8,  pcb_width/4], [8,  5, 1.0]);

        // Silkscreen
        color([1,1,1]) silkscreen();
    }
}

complete_mainboard();