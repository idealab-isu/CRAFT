$fn = 64;

// Target board dimensions (mm)
pcb_length = 203.2;
pcb_width  = 49.53;
pcb_thickness = 1.6;

// Connectivity / robustness
overlap = 0.6;          // intentional interpenetration to guarantee one connected solid
eps = 0.01;

// Mounting holes (visual only; NOT subtracted to keep one solid)
hole_radius = 1.6;      // slightly larger so they read in renders
hole_rim_h  = 0.8;      // small boss height above PCB

// Feature sizes (approximate control-board look)
edge_rail_w = 2.2;      // raised rail along long edges
edge_rail_h = 0.6;

usb_len = 16;
usb_w   = 14;
usb_h   = 8;

power_len = 18;
power_w   = 12;
power_h   = 10;

header_len = 60;
header_w   = 6;
header_h   = 6;

chip_len = 18;
chip_w   = 18;
chip_h   = 3.2;

cap_r = 3.2;
cap_h = 7.5;

driver_len = 15;
driver_w   = 20;
driver_h   = 4.5;

silk_th = 0.25;
silk_margin = 3.0;

// Helpers
module add_on_top(size, pos_xy) {
    // Places a centered cube on top of PCB with guaranteed overlap
    translate([pos_xy[0], pos_xy[1], pcb_thickness/2 + size[2]/2 - overlap])
        cube(size, center=true);
}

module add_on_bottom(size, pos_xy) {
    // Places a centered cube on bottom of PCB with guaranteed overlap
    translate([pos_xy[0], pos_xy[1], -pcb_thickness/2 - size[2]/2 + overlap])
        cube(size, center=true);
}

module add_cyl_on_top(r, h, pos_xy) {
    translate([pos_xy[0], pos_xy[1], pcb_thickness/2 + h/2 - overlap])
        cylinder(r=r, h=h, center=true);
}

// Main PCB slab
module pcb_body() {
    color([0.0, 0.4, 0.2])
        cube([pcb_length, pcb_width, pcb_thickness], center=true);
}

// Raised edge rails (gives board some recognizable detail)
module edge_rails() {
    // Along long edges (Y = +/-)
    rail_len = pcb_length;
    rail_w = edge_rail_w;
    rail_h = edge_rail_h;

    translate([0,  pcb_width/2 - rail_w/2, pcb_thickness/2 + rail_h/2 - overlap])
        cube([rail_len, rail_w, rail_h], center=true);

    translate([0, -pcb_width/2 + rail_w/2, pcb_thickness/2 + rail_h/2 - overlap])
        cube([rail_len, rail_w, rail_h], center=true);
}

// Silkscreen plate (thin raised area)
module silkscreen() {
    sx = pcb_length - 2*silk_margin;
    sy = pcb_width  - 2*silk_margin;
    translate([0, 0, pcb_thickness/2 + silk_th/2 - overlap])
        cube([sx, sy, silk_th], center=true);
}

// Mounting hole rims (visual bosses; keep solid)
module mounting_hole_rims() {
    // Keep inside board outline
    inset = 4.0;
    x = pcb_length/2 - inset;
    y = pcb_width/2  - inset;

    for (sx = [-1, 1], sy = [-1, 1])
        add_cyl_on_top(hole_radius, hole_rim_h, [sx*x, sy*y]);
}

// Connectors and components (all connected via overlap into PCB)
module connectors_and_components() {
    // USB-like connector on left edge
    usb_x = -pcb_length/2 + usb_len/2 - overlap;
    add_on_top([usb_len, usb_w, usb_h], [usb_x, 0]);

    // Power terminal on right edge
    pwr_x = pcb_length/2 - power_len/2 + overlap;
    add_on_top([power_len, power_w, power_h], [pwr_x, 0]);

    // Long pin header along top edge (near +Y)
    hdr_y = pcb_width/2 - header_w/2 + overlap;
    add_on_top([header_len, header_w, header_h], [0, hdr_y]);

    // Main MCU chip near center-left
    chip_x = -pcb_length*0.15;
    add_on_top([chip_len, chip_w, chip_h], [chip_x, 0]);

    // Stepper driver modules (3 blocks) near bottom edge (-Y)
    drv_y = -pcb_width/2 + driver_w/2 - overlap;
    drv_spacing = 28;
    for (i = [-1, 0, 1]) {
        add_on_top([driver_len, driver_w, driver_h], [i*drv_spacing, drv_y]);
    }

    // Capacitors (cylinders) near power side
    cap_x0 = pcb_length*0.28;
    cap_y0 = pcb_width*0.12;
    add_cyl_on_top(cap_r, cap_h, [cap_x0, cap_y0]);
    add_cyl_on_top(cap_r*0.9, cap_h*0.85, [cap_x0 + 10, cap_y0 - 8]);

    // A couple of underside features (solder blob / connector backs) to show bottom detail
    add_on_bottom([18, 10, 2.2], [usb_x + 6, -pcb_width*0.18]);
    add_on_bottom([22, 8, 2.0], [0, pcb_width*0.05]);
}

// Final: ONE connected solid (no subtractions)
union() {
    pcb_body();
    edge_rails();
    silkscreen();
    mounting_hole_rims();
    connectors_and_components();
}