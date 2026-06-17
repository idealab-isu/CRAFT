$fn = 64;

//====================
// Parameters (mm)
//====================
pcb_length    = 123.0;
pcb_width     = 100.0;
pcb_thickness = 1.6;

corner_radius = 5.0;

// Mounting holes
mount_hole_diameter    = 3.2;
mount_hole_edge_offset = 5.0;

// Connectivity / booleans
overlap         = 0.6;   // intentional overlap to guarantee connectivity
hole_cut_height = 30.0;  // must exceed pcb_thickness

// Visual PCB features (kept low-profile so it reads like a PCB in ortho views)
copper_thickness    = 0.08;
silkscreen_thickness= 0.12;
mask_margin         = 2.5;

// Connector/component sizing (kept realistic-ish)
usb_conn_length = 14.0;
usb_conn_width  = 12.0;
usb_conn_height = 6.0;

power_conn_length = 16.0;
power_conn_width  = 14.0;
power_conn_height = 8.0;

header_length = 40.0;
header_width  = 6.0;
header_height = 6.0;

mcu_length = 18.0;
mcu_width  = 18.0;
chip_body_height = 1.6;

driver_length = 10.0;
driver_width  = 10.0;
driver_count  = 4;

heatsink_length = 14.0;
heatsink_width  = 14.0;
heatsink_height = 4.0;

//====================
// Helpers
//====================
module rounded_rect_2d(L, W, R) {
    offset(r=R)
        square([L - 2*R, W - 2*R], center=true);
}

module rounded_rect_prism(L, W, H, R) {
    linear_extrude(height=H, center=true)
        rounded_rect_2d(L, W, R);
}

module mount_hole(pos) {
    translate(pos)
        cylinder(d=mount_hole_diameter, h=hole_cut_height, center=true);
}

module block(size_xyz, pos_xyz) {
    translate(pos_xyz) cube(size_xyz, center=true);
}

module cap_cyl(d, h, pos_xyz) {
    translate(pos_xyz) cylinder(d=d, h=h, center=true);
}

//====================
// PCB core + holes (verifiable 123 x 100 x 1.6)
//====================
module pcb_core() {
    difference() {
        rounded_rect_prism(pcb_length, pcb_width, pcb_thickness, corner_radius);

        // 4 mounting holes (through)
        mount_hole([-pcb_length/2 + mount_hole_edge_offset, -pcb_width/2 + mount_hole_edge_offset, 0]);
        mount_hole([ pcb_length/2 - mount_hole_edge_offset, -pcb_width/2 + mount_hole_edge_offset, 0]);
        mount_hole([ pcb_length/2 - mount_hole_edge_offset,  pcb_width/2 - mount_hole_edge_offset, 0]);
        mount_hole([-pcb_length/2 + mount_hole_edge_offset,  pcb_width/2 - mount_hole_edge_offset, 0]);
    }
}

//====================
// Low-profile PCB surface features (still ONE solid via overlap)
//====================
module copper_pads() {
    // Simple "pads" near edges to read as PCB in orthographic views
    zc = pcb_thickness/2 + copper_thickness/2 - overlap;

    // Long pad strips near top/bottom
    block([pcb_length - 2*mask_margin, 2.0, copper_thickness],
          [0,  pcb_width/2 - mask_margin - 1.0, zc]);
    block([pcb_length - 2*mask_margin, 2.0, copper_thickness],
          [0, -pcb_width/2 + mask_margin + 1.0, zc]);

    // A few rectangular pads near left/right
    for (i=[0:3]) {
        y = (i-1.5) * 10;
        block([6.0, 3.0, copper_thickness],
              [-pcb_length/2 + mask_margin + 6.0, y, zc]);
        block([6.0, 3.0, copper_thickness],
              [ pcb_length/2 - mask_margin - 6.0, y, zc]);
    }
}

module silkscreen_layer() {
    // Thin raised layer on top, overlapping slightly into PCB for single-solid union
    zc = pcb_thickness/2 + silkscreen_thickness/2 - overlap;
    linear_extrude(height=silkscreen_thickness, center=true)
        translate([0,0,0])
            // Use a slightly inset rounded rectangle
            translate([0,0,0])
                offset(r=max(corner_radius-1.0, 0.5))
                    square([pcb_length - 2*mask_margin - 2*(corner_radius-1.0),
                            pcb_width  - 2*mask_margin - 2*(corner_radius-1.0)], center=true);

    // Move to correct Z (done as separate translate to keep 2D clean)
    // Wrapped to keep it a single module output
    // (OpenSCAD doesn't allow post-translate of previous geometry, so we re-emit with translate)
}

module silkscreen_layer_z() {
    zc = pcb_thickness/2 + silkscreen_thickness/2 - overlap;
    translate([0,0,zc])
        linear_extrude(height=silkscreen_thickness, center=true)
            offset(r=max(corner_radius-1.0, 0.5))
                square([pcb_length - 2*mask_margin - 2*max(corner_radius-1.0, 0.5),
                        pcb_width  - 2*mask_margin - 2*max(corner_radius-1.0, 0.5)], center=true);
}

//====================
// Connectors/components (all connected; no floating; modest heights)
//====================
module connectors() {
    // Place connectors so they overlap into the PCB by "overlap"
    // Z placement: bottom of connector slightly intersects top of PCB
    // center z = pcb_thickness/2 + h/2 - overlap
    // X/Y placement: sit on edges with slight overlap into board outline
    // center x = -pcb_length/2 + L/2 - overlap  (left)
    // center x =  pcb_length/2 - L/2 + overlap  (right)
    // center y =  pcb_width/2 - W/2 + overlap   (top)
    // center y = -pcb_width/2 + W/2 - overlap   (bottom)

    // USB connector on left edge, near top
    block([usb_conn_length, usb_conn_width, usb_conn_height],
          [-pcb_length/2 + usb_conn_length/2 - overlap,
            pcb_width/2 - usb_conn_width/2 - mask_margin,
            pcb_thickness/2 + usb_conn_height/2 - overlap]);

    // Power connector on right edge, near bottom
    block([power_conn_length, power_conn_width, power_conn_height],
          [ pcb_length/2 - power_conn_length/2 + overlap,
           -pcb_width/2 + power_conn_width/2 + mask_margin,
            pcb_thickness/2 + power_conn_height/2 - overlap]);

    // Two long headers along bottom/top edges
    block([header_length, header_width, header_height],
          [0,
           -pcb_width/2 + header_width/2 + mask_margin,
            pcb_thickness/2 + header_height/2 - overlap]);

    block([header_length, header_width, header_height],
          [0,
            pcb_width/2 - header_width/2 - mask_margin,
            pcb_thickness/2 + header_height/2 - overlap]);
}

module chips_components() {
    // MCU
    block([mcu_length, mcu_width, chip_body_height],
          [-pcb_length*0.15, 0,
           pcb_thickness/2 + chip_body_height/2 - overlap]);

    // Stepper drivers (row)
    for (i = [0:driver_count-1]) {
        y = pcb_width*0.20 - i*(pcb_width*0.15);
        block([driver_length, driver_width, chip_body_height],
              [pcb_length*0.20, y,
               pcb_thickness/2 + chip_body_height/2 - overlap]);
    }

    // Capacitors
    cap_cyl(7.0, 6.0,
            [-pcb_length*0.35, pcb_width*0.25,
             pcb_thickness/2 + 6.0/2 - overlap]);
    cap_cyl(7.0, 6.0,
            [-pcb_length*0.35, pcb_width*0.10,
             pcb_thickness/2 + 6.0/2 - overlap]);

    // Inductor block
    block([10.0, 10.0, 3.5],
          [-pcb_length*0.05, pcb_width*0.30,
           pcb_thickness/2 + 3.5/2 - overlap]);
}

module heatsinks() {
    for (i = [0:driver_count-1]) {
        y = pcb_width*0.20 - i*(pcb_width*0.15);
        block([heatsink_length, heatsink_width, heatsink_height],
              [pcb_length*0.20, y,
               pcb_thickness/2 + heatsink_height/2 - overlap]);
    }
}

//====================
// Final (ONE connected solid)
//====================
module pcb_complete_model() {
    union() {
        pcb_core();

        // Low-profile PCB features (readable in ortho)
        copper_pads();
        silkscreen_layer_z();

        // Board population
        connectors();
        chips_components();
        heatsinks();
    }
}

color([0.0, 0.4, 0.2]) pcb_complete_model();