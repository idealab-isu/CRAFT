$fn=96;

stator_d = 17.75;
stator_h = 14.5;

motor_body_d = 20.0;
motor_body_h = 16.0;

endcap_h = 1.0;

shaft_d = 2.0;
shaft_h = 10.0;

mount_hole_d = 2.0;
mount_hole_r = 7.0;
mount_hole_depth = 3.0;

wire_exit_w = 4.0;
wire_exit_h = 2.0;
wire_exit_depth = 3.0;

module ring(od, id, h){
    difference(){
        cylinder(d=od, h=h, center=true);
        cylinder(d=id, h=h+0.2, center=true);
    }
}

module mount_holes(z_face){
    for(a=[0:90:270]){
        rotate([0,0,a])
            translate([mount_hole_r,0,z_face - mount_hole_depth/2])
                cylinder(d=mount_hole_d, h=mount_hole_depth+0.2, center=true);
    }
}

module motor(){
    difference(){
        union(){
            cylinder(d=motor_body_d, h=motor_body_h, center=true);
            translate([0,0,motor_body_h/2 + endcap_h/2])
                cylinder(d=motor_body_d*0.98, h=endcap_h, center=true);
            translate([0,0,-motor_body_h/2 - endcap_h/2])
                cylinder(d=motor_body_d*0.98, h=endcap_h, center=true);

            translate([0,0,0])
                cylinder(d=stator_d, h=stator_h, center=true);

            translate([0,0,motor_body_h/2 + endcap_h + shaft_h/2])
                cylinder(d=shaft_d, h=shaft_h, center=true);
        }

        translate([0,0,0])
            ring(od=stator_d*0.78, id=stator_d*0.45, h=stator_h+0.2);

        mount_holes(z_face=-motor_body_h/2);

        translate([motor_body_d/2 - wire_exit_depth/2, 0, -motor_body_h/2 + wire_exit_h/2 + 1.0])
            cube([wire_exit_depth, wire_exit_w, wire_exit_h], center=true);
    }
}

motor();