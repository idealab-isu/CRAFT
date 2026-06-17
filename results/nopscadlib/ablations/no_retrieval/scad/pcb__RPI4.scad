$fn = 64;

// Target dimensions (verified)
pcb_L = 85.0;
pcb_W = 56.0;
pcb_T = 1.4;

// Geometry controls
corner_R = 3.0;
overlap  = 0.6;     // intentional intersections to ensure ONE connected solid
hole_r   = 1.6;
hole_edge_offset = 3.5;

// Simple SBC-like components/connectors (recognizable)
usb_L = 16.0;   // protrusion length out of board edge (X)
usb_W = 14.0;   // along Y
usb_H = 8.0;    // above PCB

eth_L = 18.0;
eth_W = 16.0;
eth_H = 13.0;

hdmi_L = 12.0;
hdmi_W = 15.0;
hdmi_H = 6.0;

gpio_L = 52.0;
gpio_W = 6.0;
gpio_H = 8.0;

soc_L = 14.0;
soc_W = 14.0;
soc_H = 2.2;

ram_L = 18.0;
ram_W = 14.0;
ram_H = 2.0;

usbC_L = 10.0;
usbC_W = 9.0;
usbC_H = 4.0;

audio_L = 8.0;
audio_W = 8.0;
audio_H = 6.0;

sd_L = 16.0;   // underside SD slot
sd_W = 14.0;
sd_H = 3.0;

// Rounded-rectangle PCB
module pcb_solid() {
    linear_extrude(height=pcb_T, center=true)
        hull() {
            for (sx = [-1, 1], sy = [-1, 1])
                translate([sx*(pcb_L/2 - corner_R), sy*(pcb_W/2 - corner_R)])
                    circle(r=corner_R);
        }
}

// Mounting holes cut through PCB
module pcb_with_holes() {
    difference() {
        pcb_solid();
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(pcb_L/2 - hole_edge_offset), sy*(pcb_W/2 - hole_edge_offset), 0])
                cylinder(r=hole_r, h=pcb_T + 2, center=true);
    }
}

// Helpers: place parts with computed connectivity (no arbitrary offsets)
module on_top(pos=[0,0], size=[10,10,5]) {
    translate([pos[0], pos[1], pcb_T/2 + size[2]/2 - overlap])
        cube(size, center=true);
}
module under(pos=[0,0], size=[10,10,5]) {
    translate([pos[0], pos[1], -pcb_T/2 - size[2]/2 + overlap])
        cube(size, center=true);
}
module on_right_edge(y=0, size=[10,10,5]) {
    translate([pcb_L/2 + size[0]/2 - overlap, y, pcb_T/2 + size[2]/2 - overlap])
        cube(size, center=true);
}
module on_left_edge(y=0, size=[10,10,5]) {
    translate([-pcb_L/2 - size[0]/2 + overlap, y, pcb_T/2 + size[2]/2 - overlap])
        cube(size, center=true);
}
module on_top_edge(x=0, size=[10,10,5]) {
    translate([x, pcb_W/2 + size[1]/2 - overlap, pcb_T/2 + size[2]/2 - overlap])
        cube(size, center=true);
}
module on_bottom_edge(x=0, size=[10,10,5]) {
    translate([x, -pcb_W/2 - size[1]/2 + overlap, pcb_T/2 + size[2]/2 - overlap])
        cube(size, center=true);
}

// Complete SBC model: ONE connected solid
union() {
    // PCB
    pcb_with_holes();

    // Main SoC (top, central-ish)
    on_top([0, 0], [soc_L, soc_W, soc_H]);

    // RAM (top, near SoC)
    on_top([-(soc_L/2 + ram_L/2 - 2), 0], [ram_L, ram_W, ram_H]);

    // GPIO header along +Y edge (top)
    on_top([0, pcb_W/2 - gpio_W/2], [gpio_L, gpio_W, gpio_H]);

    // Right-side connectors (+X edge): Ethernet + USB stack (top)
    on_right_edge( (eth_W/2 - usb_W/2), [eth_L, eth_W, eth_H]);
    on_right_edge(-(eth_W/2 - usb_W/2), [usb_L, usb_W, usb_H]);

    // Left-side HDMI (-X edge, top)
    on_left_edge(0, [hdmi_L, hdmi_W, hdmi_H]);

    // Bottom edge connectors (-Y edge, top): USB-C power + audio
    on_bottom_edge(-(usbC_W/2 + audio_W/2 - 2), [usbC_W, usbC_L, usbC_H]); // rotated footprint: X=width, Y=length
    on_bottom_edge( (usbC_W/2 + audio_W/2 - 2), [audio_W, audio_L, audio_H]);

    // Underside SD slot (under, near -Y edge)
    under([0, -pcb_W/2 + sd_W/2], [sd_L, sd_W, sd_H]);
}