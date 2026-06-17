$fn = 64;

// Single-board computer overall size (PCB)
board_x = 65.0;
board_y = 56.0;
board_z = 1.4;

// Small overlap to guarantee connectivity between parts
overlap = 0.2;

// Helper: rounded rectangle prism (for PCB with rounded corners)
module rounded_box(size=[10,10,1], r=2, center=false) {
    x = size[0]; y = size[1]; z = size[2];
    translate(center ? [-x/2, -y/2, -z/2] : [0,0,0])
        linear_extrude(height=z)
            offset(r=r)
                square([x-2*r, y-2*r], center=false);
}

// Helper: place a part on top of the PCB with slight overlap
module on_top(h) {
    translate([0, 0, board_z - overlap]) children();
}

// PCB corner radius
pcb_r = 3.0;

// Mounting holes (typical SBC style) - cut through PCB
hole_d = 2.8;
hole_edge_x = 3.5;
hole_edge_y = 3.5;

// Connector/component approximations (kept within board outline)
usb_w = 14.0;   // along X
usb_d = 16.0;   // along Y (inward from edge)
usb_h = 8.0;

hdmi_w = 15.0;
hdmi_d = 12.0;
hdmi_h = 6.0;

gpio_w = 51.0;
gpio_d = 6.0;
gpio_h = 8.5;

chip_w = 14.0;
chip_d = 14.0;
chip_h = 2.0;

cam_w = 22.0;
cam_d = 6.0;
cam_h = 3.0;

union() {
    // PCB with mounting holes
    difference() {
        rounded_box([board_x, board_y, board_z], r=pcb_r, center=false);

        // 4 mounting holes
        for (px = [hole_edge_x, board_x - hole_edge_x])
            for (py = [hole_edge_y, board_y - hole_edge_y])
                translate([px, py, -0.1])
                    cylinder(d=hole_d, h=board_z + 0.2, center=false);
    }

    // Components/connectors on top (all connected via overlap)
    on_top(0) {
        // USB connector on right edge
        translate([board_x - usb_w, (board_y - usb_d)/2, 0])
            cube([usb_w, usb_d, usb_h], center=false);

        // HDMI connector on left edge
        translate([0, (board_y - hdmi_d)/2, 0])
            cube([hdmi_w, hdmi_d, hdmi_h], center=false);

        // GPIO header along top edge
        translate([(board_x - gpio_w)/2, board_y - gpio_d, 0])
            cube([gpio_w, gpio_d, gpio_h], center=false);

        // Camera/FFC connector along bottom edge
        translate([(board_x - cam_w)/2, 0, 0])
            cube([cam_w, cam_d, cam_h], center=false);

        // Main chip near center
        translate([(board_x - chip_w)/2, (board_y - chip_d)/2, 0])
            cube([chip_w, chip_d, chip_h], center=false);
    }
}