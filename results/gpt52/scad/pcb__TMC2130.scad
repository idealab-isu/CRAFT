$fn=64;

board_x = 20.0;
board_y = 14.0;
board_t = 1.6;

module pcb(x, y, t, r=0.8){
    linear_extrude(height=t)
        offset(r=r)
            offset(delta=-r)
                square([x, y], center=true);
}

module pin_header_1xN(n=8, pitch=2.54, pin_d=0.64, pin_h=6.0, body_h=2.5, body_w=2.54, body_l_extra=0.6){
    body_l = (n-1)*pitch + body_l_extra*2;
    union(){
        translate([0,0,body_h/2])
            cube([body_w, body_l, body_h], center=true);
        for(i=[0:n-1]){
            translate([0, -((n-1)*pitch)/2 + i*pitch, body_h + pin_h/2])
                cylinder(d=pin_d, h=pin_h, center=true);
        }
    }
}

module driver_ic(qx=6.0, qy=6.0, qz=1.0){
    union(){
        translate([0,0,qz/2]) cube([qx,qy,qz], center=true);
        for(a=[0:90:270]){
            rotate([0,0,a]) translate([qx/2-0.6,0,qz+0.15])
                cube([1.0,0.8,0.3], center=true);
        }
    }
}

module trimpot(d=8.0, h=4.0, shaft_d=3.0, shaft_h=1.5){
    union(){
        translate([0,0,h/2]) cylinder(d=d, h=h, center=true);
        translate([0,0,h+shaft_h/2]) cylinder(d=shaft_d, h=shaft_h, center=true);
    }
}

module electrolytic(d=5.0, h=7.0){
    union(){
        translate([0,0,h/2]) cylinder(d=d, h=h, center=true);
        translate([0,0,h+0.4/2]) cylinder(d=d*0.7, h=0.4, center=true);
    }
}

module small_cap(d=3.0, h=2.0){
    translate([0,0,h/2]) cylinder(d=d, h=h, center=true);
}

module board_assembly(){
    union(){
        color([0.05,0.45,0.12]) pcb(board_x, board_y, board_t, r=0.8);

        // Headers along long edges
        header_n = 8;
        pitch = 2.54;
        header_body_w = 2.54;
        header_z = board_t;

        x_off = board_x/2 - header_body_w/2 - 0.6;
        translate([ x_off, 0, header_z]) pin_header_1xN(n=header_n, pitch=pitch);
        translate([-x_off, 0, header_z]) pin_header_1xN(n=header_n, pitch=pitch);

        // Main driver IC
        translate([0, 0, board_t]) driver_ic(qx=6.2, qy=6.2, qz=1.0);

        // Trimpot near one end
        translate([0, board_y/2 - 4.2, board_t]) trimpot(d=8.0, h=4.0, shaft_d=3.0, shaft_h=1.5);

        // Electrolytic capacitor near opposite end
        translate([0, -board_y/2 + 4.0, board_t]) electrolytic(d=5.0, h=7.0);

        // A couple of small caps
        translate([ board_x/2 - 5.0,  0.0, board_t]) small_cap(d=3.0, h=2.0);
        translate([-board_x/2 + 5.0,  0.0, board_t]) small_cap(d=3.0, h=2.0);
    }
}

board_assembly();