// Environmental sensor board (single connected solid)
// Target: 65.0mm x 30.6mm x 1.6mm PCB with mounting holes + tab/connector extension + simple components

$fn = 64;

// Parameters
pcb_L = 65.0;
pcb_W = 30.6;
pcb_T = 1.6;

corner_fillet_r = 2.5;

mount_hole_d = 3.2;
mount_edge_offset_x = 4.5;
mount_edge_offset_y = 4.0;
hole_clearance_z = 0.8;

// Small overlap to guarantee connectivity between parts
overlap = 0.25;

// Tab/connector extension (as seen in orthographic views)
tab_L = 14.0;          // protrusion length beyond PCB edge
tab_W = 10.0;          // tab width
tab_fillet_r = 1.5;    // tab corner rounding

// Component sizes (simple but recognizable)
conn_body_L = 12.0;
conn_body_W = 8.0;
conn_body_H = 5.0;

sensor_body_L = 6.0;
sensor_body_W = 6.0;
sensor_body_H = 2.2;
sensor_port_r = 1.2;

mcu_L = 10.0;
mcu_W = 10.0;
mcu_H = 1.2;

passive_L = 3.2;
passive_W = 1.6;
passive_H = 1.0;

led_r = 1.0;
led_h = 0.8;

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Rounded-rectangle prism centered at origin
module rounded_rect_prism(L, W, T, r) {
    r2 = clamp(r, 0.01, min(L, W)/2 - 0.01);
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(L/2 - r2), sy*(W/2 - r2), 0])
                cylinder(r=r2, h=T, center=true);
    }
}

// PCB outline with a centered tab on the +X edge (single connected 2D outline extruded)
module pcb_with_tab(L, W, T, r, tabL, tabW, tabR) {
    linear_extrude(height=T, center=true, convexity=10)
        union() {
            // Main PCB
            offset(r=r) square([L - 2*r, W - 2*r], center=true);

            // Tab: attached to +X edge, centered in Y
            // Place tab so its left edge overlaps into PCB by 'overlap' (in XY) to ensure union robustness.
            translate([L/2 + tabL/2 - overlap, 0])
                offset(r=tabR) square([tabL - 2*tabR, tabW - 2*tabR], center=true);
        }
}

module mount_holes() {
    for (sx = [-1, 1], sy = [-1, 1])
        translate([sx*(pcb_L/2 - mount_edge_offset_x),
                   sy*(pcb_W/2 - mount_edge_offset_y),
                   0])
            cylinder(r=mount_hole_d/2, h=pcb_T + hole_clearance_z, center=true);
}

// Simple component primitives (all placed with computed formulas and overlapped into PCB)
module connector_block() {
    // Connector on the tab (protrudes above PCB)
    // Center it on the tab, slightly toward the outer end.
    x = pcb_L/2 + tab_L/2;
    y = 0;
    z = pcb_T/2 + conn_body_H/2 - overlap;
    translate([x, y, z])
        cube([conn_body_L, conn_body_W, conn_body_H], center=true);
}

module sensor_pkg() {
    // Sensor package near top-left
    sensor_x = -pcb_L/2 + mount_edge_offset_x + sensor_body_L/2;
    sensor_y =  pcb_W/2 - mount_edge_offset_y - sensor_body_W/2;
    translate([sensor_x, sensor_y, pcb_T/2 + sensor_body_H/2 - overlap]) {
        difference() {
            cube([sensor_body_L, sensor_body_W, sensor_body_H], center=true);
            cylinder(r=sensor_port_r, h=sensor_body_H + hole_clearance_z, center=true);
        }
    }
}

module mcu_pkg() {
    // Central-ish MCU
    translate([0, 0, pcb_T/2 + mcu_H/2 - overlap])
        cube([mcu_L, mcu_W, mcu_H], center=true);
}

module passives_row() {
    // A few passives near bottom edge
    n = 4;
    pitch = 5.0;
    y = -pcb_W/2 + mount_edge_offset_y + passive_W/2 + 1.0;
    for (i = [0:n-1]) {
        x = (-(n-1)/2 + i) * pitch;
        translate([x, y, pcb_T/2 + passive_H/2 - overlap])
            cube([passive_L, passive_W, passive_H], center=true);
    }
}

module led_indicator() {
    // Small LED near top-right of main PCB (not on tab)
    x = pcb_L/2 - mount_edge_offset_x - 2.0;
    y = pcb_W/2 - mount_edge_offset_y - 2.0;
    translate([x, y, pcb_T/2 + led_h/2 - overlap])
        cylinder(r=led_r, h=led_h, center=true);
}

// Final model: ONE connected solid (components overlap into PCB)
module complete_board() {
    union() {
        difference() {
            pcb_with_tab(pcb_L, pcb_W, pcb_T, corner_fillet_r, tab_L, tab_W, tab_fillet_r);
            mount_holes();
        }
        connector_block();
        sensor_pkg();
        mcu_pkg();
        passives_row();
        led_indicator();
    }
}

color([0.0, 0.4, 0.2]) complete_board();