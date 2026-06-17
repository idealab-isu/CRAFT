$fn=96;

module rounded_box(size=[100,80,60], r=6, center=true){
    sx=size[0]; sy=size[1]; sz=size[2];
    rr=min(r, min(sx,sy)/2);
    translate(center ? [-sx/2,-sy/2,-sz/2] : [0,0,0])
    minkowski(){
        cube([sx-2*rr, sy-2*rr, sz-2*rr], center=false);
        sphere(r=rr);
    }
}

module screw_hole(d=4, h=20){
    cylinder(d=d, h=h, center=true);
}

module knob(d=58, h=22, skirt=3){
    union(){
        cylinder(d=d, h=h, center=true);
        translate([0,0,h/2 - skirt/2])
            cylinder(d=d*0.92, h=skirt, center=true);
        translate([0,0,-h/2 + 4])
            cylinder(d=d*0.35, h=8, center=true);
    }
}

module pointer(len=26, w=6, t=2){
    translate([len/2,0,0])
        cube([len,w,t], center=true);
    translate([len,0,0])
        cylinder(d=w, h=t, center=true);
}

module dial_ring(od=86, id=66, t=2.2){
    difference(){
        cylinder(d=od, h=t, center=true);
        cylinder(d=id, h=t+0.4, center=true);
    }
}

module vent_slot(w=3, l=22, t=3){
    cube([l,w,t], center=true);
}

module variac_body(){
    body=[150,120,85];
    wall=3.2;
    r=10;

    difference(){
        rounded_box(body, r=r, center=true);

        translate([0,0,wall])
            rounded_box([body[0]-2*wall, body[1]-2*wall, body[2]-2*wall], r=max(2,r-4), center=true);

        translate([0,0, body[2]/2 - 2.2])
            cylinder(d=92, h=6, center=true);

        translate([0,0, body[2]/2 - 2.2])
            cylinder(d=10, h=10, center=true);

        translate([0,0, body[2]/2 - 2.2])
            rotate([0,0,0])
                translate([0,0,0])
                    cube([2.2, 92, 6], center=true);

        translate([0,0, body[2]/2 - 2.2])
            rotate([0,0,90])
                cube([2.2, 92, 6], center=true);

        translate([0,0, body[2]/2 - 2.2])
            rotate([0,0,45])
                cube([2.2, 92, 6], center=true);

        translate([0,0, body[2]/2 - 2.2])
            rotate([0,0,-45])
                cube([2.2, 92, 6], center=true);

        for(x=[-body[0]/2+18, body[0]/2-18])
        for(y=[-body[1]/2+18, body[1]/2-18])
            translate([x,y,-body[2]/2+10])
                screw_hole(d=4.2, h=30);

        translate([0, body[1]/2 + 0.01, -5])
            rotate([90,0,0])
                cylinder(d=10, h=10, center=true);

        translate([0, body[1]/2 + 0.01, -20])
            rotate([90,0,0])
                cube([28,14,10], center=true);

        translate([0, -body[1]/2 - 0.01, -10])
            rotate([90,0,0])
                cube([40,18,10], center=true);

        for(i=[-4:4]){
            translate([i*10, -body[1]/2 - 0.01, 18])
                rotate([90,0,0])
                    vent_slot(w=3.2, l=26, t=10);
        }
        for(i=[-3:3]){
            translate([i*12, body[1]/2 + 0.01, 22])
                rotate([90,0,0])
                    vent_slot(w=3.2, l=22, t=10);
        }
    }

    for(x=[-body[0]/2+18, body[0]/2-18])
    for(y=[-body[1]/2+18, body[1]/2-18])
        translate([x,y,-body[2]/2+6])
            cylinder(d=10, h=4, center=true);
}

module top_assembly(){
    translate([0,0, 85/2 - 2.2])
        dial_ring(od=90, id=68, t=2.2);

    translate([0,0, 85/2 + 10])
        knob(d=58, h=22, skirt=3);

    translate([0,0, 85/2 + 22])
        rotate([0,0,20])
            translate([0,0,0])
                pointer(len=28, w=6, t=2);
}

module label_plate(){
    plate=[70,22,1.6];
    translate([0,-120/2+18,-85/2+18])
        rotate([90,0,0])
            difference(){
                rounded_box([plate[0], plate[1], plate[2]], r=2, center=true);
                translate([0,0,0.2])
                    linear_extrude(height=1.2, center=true)
                        text("RAVISTAT 1F-1", size=6.2, halign="center", valign="center", font="Liberation Sans:style=Bold");
            }
}

module feet(){
    d=14; h=6;
    for(x=[-150/2+22, 150/2-22])
    for(y=[-120/2+22, 120/2-22])
        translate([x,y,-85/2 - h/2])
            difference(){
                cylinder(d=d, h=h, center=true);
                translate([0,0,0])
                    cylinder(d=4.2, h=h+1, center=true);
            }
}

union(){
    variac_body();
    top_assembly();
    label_plate();
    feet();
}