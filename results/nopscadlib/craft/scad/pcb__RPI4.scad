$fn = 48;

// Board parameters (requested)
pcb_length = 85.0;
pcb_width  = 56.0;
pcb_thickness = 1.4;

// Detail parameters (generic SBC-like features)
corner_r = 3.0;

// Mounting holes (typical SBC pattern, generic)
hole_d = 2.75;
hole_edge_x = 3.5;
hole_edge_y = 3.5;

// Component heights (kept small but visible)
soldermask_lip = 0.2;          // slight top lip to ensure union connectivity
chip_h = 1.2;
usb_h  = 4.5;
eth_h  = 5.5;
hdmi_h = 3.5;
audio_h = 3.5;
gpio_h = 3.0;

// Small overlap to guarantee connected solid
ov = 0.2;

// ---------- Helpers ----------
module rounded_rect_2d(L, W, r){
    r2 = min(r, min(L, W)/2);
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(L/2 - r2), sy*(W/2 - r2)]) circle(r=r2);
    }
}

module pcb_plate(){
    // Rounded PCB with mounting holes cut out
    difference() {
        linear_extrude(height=pcb_thickness, center=true)
            rounded_rect_2d(pcb_length, pcb_width, corner_r);

        // Mounting holes (through)
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*(pcb_length/2 - hole_edge_x), sy*(pcb_width/2 - hole_edge_y), 0])
                cylinder(d=hole_d, h=pcb_thickness + 2, center=true);
        }
    }
}

module top_component(size_xyz, pos_xyz, col=[0.2,0.2,0.2]){
    // Places a component so its bottom slightly intersects the PCB top surface
    // PCB top surface z = +pcb_thickness/2
    translate([
        pos_xyz[0],
        pos_xyz[1],
        pcb_thickness/2 + size_xyz[2]/2 - ov
    ])
        color(col) cube(size_xyz, center=true);
}

module side_connector(size_xyz, side="right", y=0, z_h=4, col=[0.75,0.75,0.75]){
    // Places a connector protruding from a board edge, with overlap into PCB
    // size_xyz = [protrusion_x, width_y, height_z]
    x_in = size_xyz[0]/2 - ov;
    x_edge = pcb_length/2;
    x_pos = (side=="right")
        ? (x_edge + x_in)
        : (-x_edge - x_in);

    translate([x_pos, y, pcb_thickness/2 + size_xyz[2]/2 - ov])
        color(col) cube(size_xyz, center=true);
}

module end_connector(size_xyz, end="top", x=0, col=[0.75,0.75,0.75]){
    // Places a connector protruding from a board end (along Y), with overlap into PCB
    // size_xyz = [width_x, protrusion_y, height_z]
    y_in = size_xyz[1]/2 - ov;
    y_edge = pcb_width/2;
    y_pos = (end=="top")
        ? (y_edge + y_in)
        : (-y_edge - y_in);

    translate([x, y_pos, pcb_thickness/2 + size_xyz[2]/2 - ov])
        color(col) cube(size_xyz, center=true);
}

// ---------- Model ----------
module single_board_computer(){
    union() {
        // PCB
        color([0.0, 0.4, 0.2]) pcb_plate();

        // Slight top soldermask lip (ensures visible thickness and helps union)
        translate([0,0, pcb_thickness/2 + soldermask_lip/2 - ov])
            color([0.0, 0.35, 0.18])
            cube([pcb_length-2*corner_r, pcb_width-2*corner_r, soldermask_lip], center=true);

        // Major chips (generic)
        top_component([14, 14, chip_h], [ -10,  5, 0], [0.15,0.15,0.15]); // SoC
        top_component([10, 12, chip_h], [  10,  8, 0], [0.18,0.18,0.18]); // RAM
        top_component([12, 10, chip_h], [  18, -8, 0], [0.12,0.12,0.12]); // PMIC

        // GPIO header block (top edge)
        end_connector([52, 6, gpio_h], end="top", x=-2, col=[0.05,0.05,0.05]);

        // Right-side connectors (USB + Ethernet style)
        // Ethernet (larger)
        side_connector([16, 16, eth_h], side="right", y= 10, col=[0.7,0.7,0.7]);
        // USB stack (two blocks)
        side_connector([14, 14, usb_h], side="right", y= -6, col=[0.72,0.72,0.72]);
        side_connector([14, 14, usb_h], side="right", y= -22, col=[0.72,0.72,0.72]);

        // Bottom edge connectors (HDMI + audio)
        end_connector([14, 10, hdmi_h], end="bottom", x= 10, col=[0.65,0.65,0.65]); // HDMI
        end_connector([10, 10, audio_h], end="bottom", x=-18, col=[0.1,0.1,0.1]);    // Audio jack block

        // Small status LED bump (still connected)
        top_component([3, 2, 0.8], [pcb_length/2 - 8, pcb_width/2 - 6, 0], [0.8,0.1,0.1]);
    }
}

single_board_computer();