$fn=64;

board_l = 50.0;
board_w = 26.0;
board_t = 1.6;

module rounded_board(l, w, t, r=1.5){
    linear_extrude(height=t)
        offset(r=r)
            square([l-2*r, w-2*r], center=true);
}

module hole(d=3.0, t=10){
    cylinder(d=d, h=t, center=true);
}

module pin_header_1xN(n=3, pitch=2.54, pin_w=0.64, pin_h=6.0, body_h=2.5, body_w=2.54, body_l_extra=0.6){
    body_l = (n-1)*pitch + body_l_extra*2;
    union(){
        translate([0,0,board_t + body_h/2])
            cube([body_l, body_w, body_h], center=true);
        for(i=[0:n-1]){
            x = -((n-1)*pitch)/2 + i*pitch;
            translate([x,0,board_t + body_h + pin_h/2])
                cube([pin_w, pin_w, pin_h], center=true);
        }
    }
}

module screw_terminal_2p(pitch=5.08, body_l=10.5, body_w=8.5, body_h=10.0){
    union(){
        translate([0,0,board_t + body_h/2])
            cube([body_l, body_w, body_h], center=true);
        for(i=[-0.5,0.5]){
            translate([i*pitch,0,board_t + body_h*0.55])
                rotate([90,0,0])
                    cylinder(d=3.2, h=body_w+0.2, center=true);
        }
    }
}

module relay_block(l=19.0, w=15.5, h=15.0){
    translate([0,0,board_t + h/2])
        cube([l,w,h], center=true);
}

module transistor_block(l=6.0, w=4.0, h=3.0){
    translate([0,0,board_t + h/2])
        cube([l,w,h], center=true);
}

module led(d=3.0, h=2.0){
    translate([0,0,board_t + h/2])
        cylinder(d=d, h=h, center=true);
}

module relay_module(){
    difference(){
        union(){
            color([0,0.5,0])
                rounded_board(board_l, board_w, board_t, r=1.5);

            translate([-6.0, 0.0, 0])
                relay_block();

            translate([18.0, 0.0, 0])
                screw_terminal_2p();

            translate([-18.0, -9.0, 0])
                pin_header_1xN(n=3);

            translate([-18.0, 9.0, 0])
                transistor_block();

            translate([0.0, 9.0, 0])
                led(d=3.0, h=2.0);

            translate([0.0, 12.0, 0])
                led(d=3.0, h=2.0);
        }

        for(x=[-board_l/2+3.0, board_l/2-3.0])
            for(y=[-board_w/2+3.0, board_w/2-3.0])
                translate([x,y,0])
                    hole(d=3.0, t=20);
    }
}

relay_module();