$fn=64;

board_x = 35.0;
board_y = 32.0;
board_t = 1.6;

module rounded_board(x, y, t, r=2.0){
    linear_extrude(height=t)
        offset(r=r)
            square([x-2*r, y-2*r], center=true);
}

module hole(d=3.0, t=10){
    cylinder(d=d, h=t, center=true);
}

module pin_header_1xN(n=8, pitch=2.54, pin_d=0.64, pin_h=6.0, body_h=2.5, body_w=2.54, body_l=2.54){
    union(){
        translate([0,0,body_h/2])
            cube([pitch*(n-1)+body_l, body_w, body_h], center=true);
        for(i=[0:n-1]){
            translate([(-pitch*(n-1)/2)+i*pitch, 0, -pin_h/2])
                cylinder(d=pin_d, h=pin_h, center=true);
        }
    }
}

module screw_terminal_2p(pitch=5.08, w=10.2, d=8.0, h=10.0){
    union(){
        translate([0,0,h/2])
            cube([w, d, h], center=true);
        for(i=[-0.5,0.5]){
            translate([i*pitch, 0, h*0.55])
                cylinder(d=3.2, h=h*0.6, center=true);
        }
    }
}

module ic_chip(body_x=10.0, body_y=10.0, body_z=2.0){
    translate([0,0,body_z/2])
        cube([body_x, body_y, body_z], center=true);
}

module electrolytic_cap(d=8.0, h=12.0){
    union(){
        translate([0,0,h/2])
            cylinder(d=d, h=h, center=true);
        translate([0,0,h+0.6])
            cylinder(d1=d*0.9, d2=d*0.7, h=1.2, center=true);
    }
}

module small_cap(d=5.0, h=6.0){
    translate([0,0,h/2])
        cylinder(d=d, h=h, center=true);
}

module heatsink_block(x=14.0, y=12.0, z=8.0, fin_n=7, fin_t=1.0, gap=1.0){
    union(){
        translate([0,0,z/2])
            cube([x, y, z], center=true);
        for(i=[0:fin_n-1]){
            y0 = -y/2 + fin_t/2 + i*(fin_t+gap);
            if(y0 <= y/2 - fin_t/2)
                translate([0, y0, z + 3.0/2])
                    cube([x*0.95, fin_t, 3.0], center=true);
        }
    }
}

module motor_driver_module(){
    r = 2.0;
    hole_d = 3.0;
    hole_off_x = board_x/2 - 3.0;
    hole_off_y = board_y/2 - 3.0;

    difference(){
        color([0.0,0.45,0.0])
            rounded_board(board_x, board_y, board_t, r);

        for(sx=[-1,1], sy=[-1,1]){
            translate([sx*hole_off_x, sy*hole_off_y, board_t/2])
                hole(d=hole_d, t=20);
        }
    }

    // Components (approximate)
    translate([0, 0, board_t])
        color([0.15,0.15,0.15])
            ic_chip(10, 10, 2.0);

    translate([0, 0, board_t+2.0])
        color([0.2,0.2,0.2])
            heatsink_block(14, 12, 8, fin_n=7, fin_t=1.0, gap=0.8);

    translate([board_x/2 - 6.0, 0, board_t])
        color([0.0,0.0,0.0])
            screw_terminal_2p();

    translate([-board_x/2 + 6.0, 0, board_t])
        color([0.05,0.05,0.05])
            rotate([0,0,90])
                pin_header_1xN(n=8);

    translate([0, -board_y/2 + 7.0, board_t])
        color([0.1,0.1,0.1])
            electrolytic_cap(8.0, 12.0);

    translate([-8.0, board_y/2 - 7.0, board_t])
        color([0.1,0.1,0.1])
            small_cap(5.0, 6.0);

    translate([8.0, board_y/2 - 7.0, board_t])
        color([0.1,0.1,0.1])
            small_cap(5.0, 6.0);
}

motor_driver_module();