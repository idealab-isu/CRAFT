// 3D printer mainboard (generic) - 100.75mm x 70.25mm x 1.6mm PCB
// One connected solid, with mounting holes and representative components.
// All placements are formula-based from board dimensions.

$fn = 48;

// Parameters
length = 100.75;   // X
width  = 70.25;    // Y
thickness = 1.6;   // Z

// Small overlap to guarantee connectivity between parts
overlap = 0.25;

// Helpers
module rounded_rect_2d(l, w, r) {
    // r must be <= min(l,w)/2
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(l/2 - r), sy*(w/2 - r)]) circle(r=r);
    }
}

module pcb_with_holes(l, w, t, corner_r, hole_d, hole_edge_x, hole_edge_y) {
    // hole_edge_* are distances from board edges to hole centers
    difference() {
        linear_extrude(height=t, center=true)
            rounded_rect_2d(l, w, corner_r);

        // 4 mounting holes
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*(l/2 - hole_edge_x), sy*(w/2 - hole_edge_y), 0])
                cylinder(d=hole_d, h=t + 2, center=true);
        }
    }
}

module chip_pkg(x, y, z, pos=[0,0,0], col="Black") {
    // z is total height above PCB top; ensure overlap into PCB
    translate([pos[0], pos[1], thickness/2 + z/2 - overlap])
        color(col) cube([x, y, z], center=true);
}

module connector_block(x, y, z, pos=[0,0,0], col=[0.15,0.15,0.15]) {
    translate([pos[0], pos[1], thickness/2 + z/2 - overlap])
        color(col) cube([x, y, z], center=true);
}

module pin_header(x, y, z, pos=[0,0,0], col=[0.05,0.05,0.05]) {
    translate([pos[0], pos[1], thickness/2 + z/2 - overlap])
        color(col) cube([x, y, z], center=true);
}

module mainboard() {
    // Board features (generic but recognizable)
    corner_r = min(4, min(length, width)/10);
    hole_d = 3.2;
    hole_edge_x = 6.0;
    hole_edge_y = 6.0;

    // Component sizes (approximate)
    mcu = [14, 14, 2.2];
    driver = [16, 16, 3.0];
    usb = [12, 8, 4.5];
    sd  = [16, 14, 2.8];
    term = [40, 10, 10];
    power = [18, 12, 11];
    header_long = [50, 6, 6];
    header_short = [22, 6, 6];
    cap = [8, 8, 10];

    union() {
        // PCB
        color([0.0, 0.35, 0.18])
            pcb_with_holes(length, width, thickness, corner_r, hole_d, hole_edge_x, hole_edge_y);

        // Major connectors along edges (kept within board outline)
        // Right edge: screw terminal block
        connector_block(term[0], term[1], term[2],
            pos=[ length/2 - term[0]/2 - 2,  width/2 - term[1]/2 - 10, 0],
            col=[0.12,0.12,0.12]);

        // Left edge: power connector
        connector_block(power[0], power[1], power[2],
            pos=[-length/2 + power[0]/2 + 2,  width/2 - power[1]/2 - 10, 0],
            col=[0.12,0.12,0.12]);

        // Bottom edge: USB connector
        connector_block(usb[0], usb[1], usb[2],
            pos=[-length/2 + usb[0]/2 + 6, -width/2 + usb[1]/2 + 3, 0],
            col=[0.18,0.18,0.18]);

        // Bottom edge: SD card slot
        connector_block(sd[0], sd[1], sd[2],
            pos=[ length/2 - sd[0]/2 - 8, -width/2 + sd[1]/2 + 4, 0],
            col=[0.18,0.18,0.18]);

        // Top edge: long pin header
        pin_header(header_long[0], header_long[1], header_long[2],
            pos=[0, width/2 - header_long[1]/2 - 2, 0],
            col=[0.08,0.08,0.08]);

        // Mid-right: short header
        pin_header(header_short[0], header_short[1], header_short[2],
            pos=[ length/2 - header_short[0]/2 - 6, 0, 0],
            col=[0.08,0.08,0.08]);

        // Central MCU
        chip_pkg(mcu[0], mcu[1], mcu[2],
            pos=[-length*0.05, width*0.05, 0],
            col="Black");

        // Stepper driver packages (3x)
        for (i = [0:2]) {
            chip_pkg(driver[0], driver[1], driver[2],
                pos=[-length*0.20 + i*(driver[0] + 6), -width*0.10, 0],
                col=[0.05,0.05,0.05]);
        }

        // Capacitors (2x)
        for (sx = [-1, 1]) {
            translate([sx*(length*0.18), width*0.18, thickness/2 + cap[2]/2 - overlap])
                color([0.1,0.1,0.1])
                    cube([cap[0], cap[1], cap[2]], center=true);
        }

        // Small ICs / regulators (sprinkled)
        for (p = [
            [ length*0.10,  width*0.10],
            [ length*0.22,  width*0.02],
            [-length*0.28,  width*0.00],
            [-length*0.10, -width*0.22],
            [ length*0.05, -width*0.22]
        ]) {
            chip_pkg(10, 6, 1.8, pos=[p[0], p[1], 0], col=[0.06,0.06,0.06]);
        }
    }
}

mainboard();