$fn=96;

stator_d = 28.0;
stator_h = 17.25;

motor_body_d = 30.0;
motor_body_h = stator_h;

endcap_th = 1.2;
endcap_d = motor_body_d;

shaft_d = 3.0;
shaft_len_front = 12.0;
shaft_len_back = 3.0;

mount_hole_count = 4;
mount_hole_d = 3.0;
mount_hole_circle_d = 19.0;

wire_exit_w = 6.0;
wire_exit_h = 3.0;
wire_exit_depth = 4.0;

module ring(od, id, h){
    difference(){
        cylinder(d=od, h=h, center=true);
        cylinder(d=id, h=h+0.2, center=true);
    }
}

module mount_holes(h, circle_d, hole_d){
    for(i=[0:mount_hole_count-1]){
        rotate([0,0, i*360/mount_hole_count])
            translate([circle_d/2, 0, 0])
                cylinder(d=hole_d, h=h+0.4, center=true);
    }
}

module motor(){
    difference(){
        union(){
            cylinder(d=motor_body_d, h=motor_body_h, center=true);
            translate([0,0, motor_body_h/2 + endcap_th/2])
                cylinder(d=endcap_d, h=endcap_th, center=true);
            translate([0,0, -motor_body_h/2 - endcap_th/2])
                cylinder(d=endcap_d, h=endcap_th, center=true);

            translate([0,0, motor_body_h/2 + endcap_th + shaft_len_front/2])
                cylinder(d=shaft_d, h=shaft_len_front, center=true);
            translate([0,0, -motor_body_h/2 - endcap_th - shaft_len_back/2])
                cylinder(d=shaft_d, h=shaft_len_back, center=true);
        }

        cylinder(d=stator_d, h=stator_h+0.2, center=true);

        translate([0,0, motor_body_h/2 + endcap_th/2])
            mount_holes(endcap_th, mount_hole_circle_d, mount_hole_d);

        translate([motor_body_d/2 - wire_exit_depth/2, 0, -motor_body_h/2 + wire_exit_h/2 + 2.0])
            cube([wire_exit_depth, wire_exit_w, wire_exit_h], center=true);
    }
}

motor();