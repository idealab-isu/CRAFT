$fn=96;

stator_d = 14.0;
stator_h = 11.75;

motor_od = 16.0;
motor_h = stator_h;

endcap_h = 1.0;
can_h = motor_h - 2*endcap_h;

shaft_d = 2.0;
shaft_len_top = 10.0;
shaft_len_bottom = 2.0;

mount_hole_d = 2.0;
mount_hole_r = 6.0;
mount_hole_count = 4;

wire_d = 1.2;
wire_len = 8.0;
wire_spacing = 2.0;

module bolt_circle_holes(count, r, d, h){
    for(i=[0:count-1]){
        rotate([0,0,360*i/count])
            translate([r,0,0])
                cylinder(d=d, h=h, center=true);
    }
}

module motor_can(od, h, endcap_h){
    union(){
        translate([0,0,0])
            cylinder(d=od, h=h, center=true);
        translate([0,0,(h/2)-(endcap_h/2)])
            cylinder(d=od*0.98, h=endcap_h, center=true);
        translate([0,0,-(h/2)+(endcap_h/2)])
            cylinder(d=od*0.98, h=endcap_h, center=true);
    }
}

module stator(d, h){
    difference(){
        cylinder(d=d, h=h, center=true);
        cylinder(d=d*0.55, h=h+0.2, center=true);
        for(i=[0:11]){
            rotate([0,0,360*i/12])
                translate([d*0.33,0,0])
                    cylinder(d=d*0.12, h=h+0.2, center=true);
        }
    }
}

module rotor(d, h){
    difference(){
        cylinder(d=d, h=h, center=true);
        cylinder(d=d*0.25, h=h+0.2, center=true);
    }
}

module shaft(d, len_top, len_bottom, motor_h){
    union(){
        translate([0,0,(motor_h/2)+(len_top/2)])
            cylinder(d=d, h=len_top, center=true);
        translate([0,0,-(motor_h/2)-(len_bottom/2)])
            cylinder(d=d, h=len_bottom, center=true);
        cylinder(d=d*1.05, h=motor_h+0.2, center=true);
    }
}

module wires(d, len, spacing, motor_h){
    for(i=[-1,0,1]){
        translate([motor_od/2 + len/2, i*spacing, -(motor_h/2) + 2.0])
            rotate([0,90,0])
                cylinder(d=d, h=len, center=true);
    }
}

module bldc_motor(){
    difference(){
        union(){
            motor_can(motor_od, motor_h, endcap_h);
            translate([0,0,0])
                stator(stator_d, stator_h);
            translate([0,0,0])
                rotor(stator_d*0.78, stator_h*0.92);
            shaft(shaft_d, shaft_len_top, shaft_len_bottom, motor_h);
            wires(wire_d, wire_len, wire_spacing, motor_h);
        }
        translate([0,0,-(motor_h/2)+(endcap_h/2)])
            bolt_circle_holes(mount_hole_count, mount_hole_r, mount_hole_d, endcap_h+0.6);
    }
}

bldc_motor();