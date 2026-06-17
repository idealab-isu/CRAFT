// PCB: 21.0mm x 18.0mm x 1.2mm (one connected solid)

$fn = 64;

// Parameters
pcb_length = 21.0;
pcb_width  = 18.0;
pcb_thickness = 1.2;

corner_radius = 2.0;

hole_diameter = 1.5;
hole_offset   = 2.0;

pad_diameter  = 2.0;
pad_thickness = 0.12;   // slightly thicker so it renders clearly
pad_offset_x  = 5.0;
pad_offset_y  = 5.0;

edge_connector_width = 10.0;
edge_connector_depth = 0.6;  // make it visible and ensure union connectivity
edge_connector_raise = 0.10; // protrude slightly above top surface

silk_thickness = 0.08;
silk_width     = 0.25;

// Rounded rectangle prism using 2D offset + linear_extrude (robust)
module rounded_rect_prism(l, w, h, r) {
    linear_extrude(height=h, center=true, convexity=10)
        offset(r=r)
            square([l - 2*r, w - 2*r], center=true);
}

module pcb_body() {
    difference() {
        rounded_rect_prism(pcb_length, pcb_width, pcb_thickness, corner_radius);

        // Mounting holes (through)
        for (x = [-pcb_length/2 + hole_offset, pcb_length/2 - hole_offset])
            for (y = [-pcb_width/2 + hole_offset, pcb_width/2 - hole_offset])
                translate([x, y, 0])
                    cylinder(h=pcb_thickness + 0.6, d=hole_diameter, center=true);
    }
}

module copper_pads() {
    // Pads are UNIONED to the board (single connected solid)
    for (x = [-pad_offset_x, pad_offset_x])
        for (y = [-pad_offset_y, pad_offset_y])
            translate([x, y, pcb_thickness/2 + pad_thickness/2 - 0.02]) // slight overlap into board
                cylinder(h=pad_thickness, d=pad_diameter, center=true);
}

module edge_connector() {
    // Attached along +Y edge, protruding slightly above top surface, overlapping into board
    translate([0,
               pcb_width/2 - edge_connector_depth/2 + 0.02, // overlap into board
               pcb_thickness/2 + edge_connector_raise/2 - 0.02])
        cube([edge_connector_width, edge_connector_depth, edge_connector_raise], center=true);
}

module silkscreen_markings() {
    // Simple silkscreen bar on top, slightly embedded for connectivity
    translate([-pcb_length/4,
               0,
               pcb_thickness/2 + silk_thickness/2 - 0.02]) // overlap into board
        cube([pcb_length/2, silk_width, silk_thickness], center=true);
}

union() {
    pcb_body();
    copper_pads();
    edge_connector();
    silkscreen_markings();
}