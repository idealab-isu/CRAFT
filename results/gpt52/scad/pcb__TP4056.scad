$fn=64;

module pcb(size=[26.2,17.5,1.0], corner_r=1.2){
    x=size[0]; y=size[1]; z=size[2];
    linear_extrude(height=z, center=true)
        offset(r=corner_r)
            square([x-2*corner_r, y-2*corner_r], center=true);
}

module mount_hole(d=2.2, h=3.0){
    cylinder(d=d, h=h, center=true);
}

module pad(w=3.0, l=5.0, t=0.15){
    translate([0,0,0.5 + t/2])
        cube([l,w,t], center=true);
}

module usb_micro_outline(w=7.5, l=6.8, h=2.6){
    translate([0,0,0.5 + h/2])
        cube([l,w,h], center=true);
}

module chip(w=4.0, l=6.0, h=1.2){
    translate([0,0,0.5 + h/2])
        cube([l,w,h], center=true);
}

module led(d=1.8, h=0.8){
    translate([0,0,0.5 + h/2])
        cylinder(d=d, h=h, center=true);
}

module battery_charger_module(){
    difference(){
        pcb([26.2,17.5,1.0], corner_r=1.2);

        translate([ 11.0,  7.0, 0]) mount_hole(d=2.2, h=4.0);
        translate([-11.0,  7.0, 0]) mount_hole(d=2.2, h=4.0);
        translate([ 11.0, -7.0, 0]) mount_hole(d=2.2, h=4.0);
        translate([-11.0, -7.0, 0]) mount_hole(d=2.2, h=4.0);
    }

    translate([ 0,  0, 0]) chip(w=4.2, l=6.2, h=1.2);

    translate([ 10.2, 0, 0]) usb_micro_outline(w=7.6, l=6.8, h=2.6);

    translate([-10.5,  4.5, 0]) pad(w=3.2, l=5.2, t=0.15);
    translate([-10.5,  0.0, 0]) pad(w=3.2, l=5.2, t=0.15);
    translate([-10.5, -4.5, 0]) pad(w=3.2, l=5.2, t=0.15);

    translate([ 2.5,  6.0, 0]) led(d=1.8, h=0.8);
    translate([ 5.5,  6.0, 0]) led(d=1.8, h=0.8);
}

battery_charger_module();