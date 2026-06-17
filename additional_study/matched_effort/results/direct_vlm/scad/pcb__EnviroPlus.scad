$fn = 64;

// Environmental sensor board overall size (mm)
board_len = 65.0;
board_wid = 30.6;
board_thk = 1.6;

corner_r = 2.0;

// Feature parameters (kept modest; all connected to PCB)
overlap = 0.2;                 // small overlap to guarantee manifold union
hole_d = 3.0;                  // mounting holes
hole_edge = 3.0;               // hole center offset from edges

// Components (approximate)
header_pins = 8;
pin_pitch = 2.54;
pin_d = 0.7;
pin_h = 3.0;

header_body_h = 2.5;
header_body_w = 5.0;

sensor_pkg = [10.0, 10.0, 2.2]; // L,W,H
sensor_window = [6.0, 6.0];     // cutout in sensor top

reg_pkg = [6.0, 4.0, 1.6];      // small IC
cap_d = 4.0;
cap_h = 3.0;

module rounded_rect_2d(l, w, r){
    offset(r=r) square([l-2*r, w-2*r], center=true);
}

module rounded_board(l, w, t, r){
    linear_extrude(height=t)
        rounded_rect_2d(l, w, r);
}

module pcb_with_holes(){
    difference(){
        rounded_board(board_len, board_wid, board_thk, corner_r);

        // 4 mounting holes
        for (sx = [-1, 1], sy = [-1, 1])
            translate([ sx*(board_len/2 - hole_edge),
                        sy*(board_wid/2 - hole_edge),
                        -overlap ])
                cylinder(d=hole_d, h=board_thk + 2*overlap);
    }
}

module header_1xN(n){
    // Header body sits on PCB; pins protrude downward slightly and upward a bit
    body_len = (n-1)*pin_pitch + 2.0;
    body_w   = header_body_w;
    body_h   = header_body_h;

    union(){
        // plastic body
        translate([0, 0, board_thk - overlap])
            cube([body_len, body_w, body_h], center=true);

        // pins (centered along length)
        for (i = [0:n-1]){
            x = (i - (n-1)/2) * pin_pitch;
            translate([x, 0, board_thk/2 - pin_h/2 + overlap])
                cylinder(d=pin_d, h=pin_h, center=true);
        }
    }
}

module sensor_module(){
    // Sensor package on top of PCB with a recessed "window"
    union(){
        difference(){
            translate([0, 0, board_thk - overlap])
                cube(sensor_pkg, center=true);

            // window recess from top face
            translate([0, 0, board_thk - overlap + sensor_pkg[2]/2 - 0.6])
                cube([sensor_window[0], sensor_window[1], 1.2], center=true);
        }

        // small surrounding "frame" ridge (still connected)
        frame_t = 0.6;
        frame_h = 0.6;
        translate([0, 0, board_thk - overlap + sensor_pkg[2]/2 - frame_h/2])
            difference(){
                cube([sensor_pkg[0]+2*frame_t, sensor_pkg[1]+2*frame_t, frame_h], center=true);
                cube([sensor_pkg[0], sensor_pkg[1], frame_h + 2*overlap], center=true);
            }
    }
}

module small_ic(pkg=[6,4,1.6]){
    translate([0, 0, board_thk - overlap])
        cube(pkg, center=true);
}

module capacitor_can(d=4, h=3){
    translate([0, 0, board_thk - overlap])
        cylinder(d=d, h=h);
}

module board_assembly(){
    union(){
        // PCB (green)
        color([0.05, 0.35, 0.12])
            pcb_with_holes();

        // Components (dark/neutral), all placed with formula-based offsets
        // Header along one long edge
        header_y = -(board_wid/2 - (header_body_w/2 + 1.2));
        header_x = -(board_len/2) + ( (header_pins-1)*pin_pitch/2 + 6.0 );
        color([0.08, 0.08, 0.08])
            translate([header_x, header_y, 0])
                header_1xN(header_pins);

        // Sensor near opposite side, slightly right of center
        sensor_x = board_len*0.18;
        sensor_y = board_wid*0.18;
        color([0.75, 0.75, 0.75])
            translate([sensor_x, sensor_y, 0])
                sensor_module();

        // Small regulator/IC near header
        ic_x = header_x + ( (header_pins-1)*pin_pitch/2 - 2.0 );
        ic_y = header_y + (header_body_w/2 + reg_pkg[1]/2 + 2.0);
        color([0.12, 0.12, 0.12])
            translate([ic_x, ic_y, 0])
                small_ic(reg_pkg);

        // Two capacitors near IC
        cap1_x = ic_x + reg_pkg[0]/2 + cap_d/2 + 1.5;
        cap1_y = ic_y;
        cap2_x = ic_x;
        cap2_y = ic_y + reg_pkg[1]/2 + cap_d/2 + 1.5;

        color([0.2, 0.2, 0.2]){
            translate([cap1_x, cap1_y, 0]) capacitor_can(cap_d, cap_h);
            translate([cap2_x, cap2_y, 0]) capacitor_can(cap_d, cap_h);
        }

        // A small "connector" block on the right edge (e.g., JST-like), connected
        conn = [10.0, 7.0, 4.0];
        conn_x = board_len/2 - conn[0]/2 - 1.0;
        conn_y = 0;
        color([0.92, 0.92, 0.92])
            translate([conn_x, conn_y, board_thk - overlap])
                cube(conn, center=true);
    }
}

board_assembly();