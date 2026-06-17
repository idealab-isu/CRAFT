$fn = 64;

// Target SBC envelope (exact)
pcb_length = 65.0;
pcb_width  = 30.0;
pcb_thickness = 1.4;

// Keep outline simple rectangular to match 65x30 footprint intent
corner_radius = 0.0;          // set >0 if you explicitly want rounded corners
mount_hole_diameter = 3.0;
mount_hole_edge_offset = 4.0;
hole_cut_extra = 0.6;

// Components (kept, but forced to be physically connected to PCB with overlap)
connector_height = 6.0;
connector_depth  = 8.0;
connector_length = 18.0;

chip1_length = 14.0;
chip1_width  = 14.0;
chip1_height = 2.0;

chip2_length = 10.0;
chip2_width  = 8.0;
chip2_height = 1.6;

component_height = 1.2;
component_length = 6.0;
component_width  = 3.0;

silkscreen_thickness = 0.2;
silkscreen_line_width = 1.0;
silkscreen_margin = 2.0;

// Small overlap to guarantee one connected solid (no floating parts)
z_overlap = 0.2;   // mm

module pcb_outline_2d() {
    // Exact 65x30 rectangle (optionally rounded if corner_radius > 0)
    if (corner_radius <= 0)
        square([pcb_length, pcb_width], center=true);
    else
        offset(r=corner_radius)
            square([pcb_length - 2*corner_radius, pcb_width - 2*corner_radius], center=true);
}

module pcb_main_body() {
    color([0.0, 0.4, 0.2])
    difference() {
        linear_extrude(height=pcb_thickness, center=true)
            pcb_outline_2d();

        // Mounting holes (through)
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(pcb_length/2 - mount_hole_edge_offset),
                       sy*(pcb_width/2  - mount_hole_edge_offset),
                       0])
                cylinder(h=pcb_thickness + hole_cut_extra, r=mount_hole_diameter/2, center=true);
    }
}

module edge_connectors() {
    color([0.1, 0.1, 0.6])
    union() {
        // Top edge connector (positive Y), connected by z_overlap into PCB
        translate([0,
                   pcb_width/2 + connector_depth/2,
                   pcb_thickness/2 + connector_height/2 - z_overlap])
            cube([connector_length, connector_depth, connector_height], center=true);

        // Bottom edge connector (negative Y), slightly smaller, connected by z_overlap
        translate([pcb_length/2 - mount_hole_edge_offset - (connector_length*0.8)/2,
                   -pcb_width/2 - (connector_depth*0.8)/2,
                   pcb_thickness/2 + (connector_height*0.8)/2 - z_overlap])
            cube([connector_length*0.8, connector_depth*0.8, connector_height*0.8], center=true);
    }
}

module chips_components() {
    color([0.4, 0.4, 0.43])
    union() {
        // Chip 1
        translate([-pcb_length/2 + mount_hole_edge_offset + chip1_length/2,
                   0,
                   pcb_thickness/2 + chip1_height/2 - z_overlap])
            cube([chip1_length, chip1_width, chip1_height], center=true);

        // Chip 2
        translate([pcb_length/2 - mount_hole_edge_offset - chip2_length/2,
                   -pcb_width/2 + mount_hole_edge_offset + chip2_width/2,
                   pcb_thickness/2 + chip2_height/2 - z_overlap])
            cube([chip2_length, chip2_width, chip2_height], center=true);

        // Small component near top edge
        translate([0,
                   pcb_width/2 - mount_hole_edge_offset - component_width/2,
                   pcb_thickness/2 + component_height/2 - z_overlap])
            cube([component_length, component_width, component_height], center=true);

        // Side component near right edge
        translate([pcb_length/2 - mount_hole_edge_offset - (component_length*0.8)/2,
                   0,
                   pcb_thickness/2 + component_height/2 - z_overlap])
            cube([component_length*0.8, component_width*1.2, component_height], center=true);
    }
}

module silkscreen_markings() {
    color([0.85, 0.85, 0.8])
    union() {
        // Place silkscreen slightly embedded so it unions (single solid)
        z = pcb_thickness/2 + silkscreen_thickness/2 - z_overlap;

        translate([0, pcb_width/2 - silkscreen_margin, z])
            cube([pcb_length - 2*silkscreen_margin, silkscreen_line_width, silkscreen_thickness], center=true);

        translate([0, -pcb_width/2 + silkscreen_margin, z])
            cube([pcb_length - 2*silkscreen_margin, silkscreen_line_width, silkscreen_thickness], center=true);

        translate([-pcb_length/2 + silkscreen_margin, 0, z])
            cube([silkscreen_line_width, pcb_width - 2*silkscreen_margin, silkscreen_thickness], center=true);

        translate([pcb_length/2 - silkscreen_margin, 0, z])
            cube([silkscreen_line_width, pcb_width - 2*silkscreen_margin, silkscreen_thickness], center=true);
    }
}

module sbc_complete_model() {
    // One connected solid: all parts overlap into PCB by z_overlap
    union() {
        pcb_main_body();
        edge_connectors();
        chips_components();
        silkscreen_markings();
    }
}

sbc_complete_model();