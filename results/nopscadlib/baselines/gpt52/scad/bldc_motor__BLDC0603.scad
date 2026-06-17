$fn=96;

stator_d = 9.0;
stator_h = 8.0;

motor_body_d = 11.0;
motor_body_h = 10.0;

endcap_h = 1.0;

shaft_d = 2.0;
shaft_h = 12.0;

mount_hole_d = 1.6;
mount_hole_r = 3.5;
mount_hole_count = 4;

wire_d = 1.0;
wire_len = 8.0;
wire_spacing = 1.6;

module bolt_holes(h, d, r, n){
    for(i=[0:n-1]){
        rotate([0,0,360*i/n])
            translate([r,0,0])
                cylinder(h=h, d=d, center=true);
    }
}

module motor_can(d, h, endcap){
    difference(){
        union(){
            cylinder(h=h, d=d, center=true);
            translate([0,0,h/2 - endcap/2]) cylinder(h=endcap, d=d*0.98, center=true);
            translate([0,0,-h/2 + endcap/2]) cylinder(h=endcap, d=d*0.98, center=true);
        }
        translate([0,0,0]) cylinder(h=h-2*endcap, d=d*0.92, center=true);
        translate([0,0,-h/2 + endcap/2]) bolt_holes(h=endcap+0.2, d=mount_hole_d, r=mount_hole_r, n=mount_hole_count);
    }
}

module stator(d, h){
    difference(){
        cylinder(h=h, d=d, center=true);
        cylinder(h=h+0.2, d=d*0.45, center=true);
        for(i=[0:11]){
            rotate([0,0,360*i/12])
                translate([d*0.33,0,0])
                    cube([d*0.18, d*0.10, h+0.4], center=true);
        }
    }
}

module rotor(d, h){
    difference(){
        cylinder(h=h, d=d, center=true);
        cylinder(h=h+0.2, d=d*0.35, center=true);
    }
}

module shaft(d, h){
    translate([0,0,(motor_body_h/2) + h/2 - 1.0])
        cylinder(h=h, d=d, center=true);
}

module wires(){
    for(i=[-1:1]){
        translate([-(motor_body_d/2 + wire_len/2), i*wire_spacing, -motor_body_h/2 + 1.5])
            rotate([0,90,0])
                cylinder(h=wire_len, d=wire_d, center=true);
    }
}

module bldc_motor(){
    union(){
        color([0.75,0.75,0.78]) motor_can(motor_body_d, motor_body_h, endcap_h);
        color([0.55,0.35,0.15]) translate([0,0,0]) stator(stator_d, stator_h);
        color([0.2,0.2,0.22]) translate([0,0,0]) rotor(stator_d*0.88, stator_h*0.95);
        color([0.85,0.85,0.88]) shaft(shaft_d, shaft_h);
        color([0.1,0.1,0.1]) wires();
    }
}

bldc_motor();