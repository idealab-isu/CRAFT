$fn = 64;

board_x = 26.3;
board_y = 19.5;
board_t = 1.6;

corner_r = 1.5;

module rounded_rect_2d(x, y, r){
    r2 = min(r, min(x,y)/2);
    hull(){
        translate([ r2, r2]) circle(r=r2);
        translate([ x-r2, r2]) circle(r=r2);
        translate([ r2, y-r2]) circle(r=r2);
        translate([ x-r2, y-r2]) circle(r=r2);
    }
}

module pcb(){
    color([0.05, 0.35, 0.18])
    linear_extrude(height=board_t)
        rounded_rect_2d(board_x, board_y, corner_r);
}

module mounting_holes(){
    hole_d = 3.0;
    edge = 2.2;
    for (p = [
        [edge, edge],
        [board_x-edge, edge],
        [edge, board_y-edge],
        [board_x-edge, board_y-edge]
    ])
        translate([p[0], p[1], -0.2])
            cylinder(d=hole_d, h=board_t+0.4);
}

module header_pins(){
    // 5-pin header along one long edge
    n = 5;
    pitch = 2.54;
    pin_d = 0.64;
    pin_h = 6.0;
    body_h = 2.5;
    body_t = 2.5;
    body_w = (n-1)*pitch + 2.0;

    x0 = (board_x - (n-1)*pitch)/2;
    y0 = 2.0;

    // plastic header body
    color([0.05,0.05,0.05])
    translate([x0-1.0, y0-1.25, board_t])
        cube([body_w, body_t, body_h], center=false);

    // pins
    color([0.8,0.75,0.6])
    for(i=[0:n-1]){
        translate([x0 + i*pitch, y0, board_t-2.0])
            cylinder(d=pin_d, h=pin_h+2.0);
    }
}

module encoder_body(){
    // Approximate rotary encoder footprint/body
    body_x = 12.0;
    body_y = 13.0;
    body_z = 7.0;

    shaft_d = 6.0;
    shaft_h = 12.0;

    // place near opposite edge from header
    cx = board_x/2;
    cy = board_y - 7.5;

    // encoder can
    color([0.75,0.75,0.78])
    translate([cx - body_x/2, cy - body_y/2, board_t])
        cube([body_x, body_y, body_z], center=false);

    // shaft
    color([0.65,0.65,0.68])
    translate([cx, cy, board_t + body_z])
        cylinder(d=shaft_d, h=shaft_h);

    // small knob cap
    color([0.55,0.55,0.58])
    translate([cx, cy, board_t + body_z + shaft_h])
        cylinder(d=shaft_d*0.9, h=2.0);
}

difference(){
    pcb();
    mounting_holes();
}

header_pins();
encoder_body();