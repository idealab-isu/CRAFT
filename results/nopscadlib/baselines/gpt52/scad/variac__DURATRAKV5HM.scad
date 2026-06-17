$fn=96;

module rounded_box(size=[100,80,40], r=6, center=true){
    sx=size[0]; sy=size[1]; sz=size[2];
    translate(center ? [-sx/2,-sy/2,-sz/2] : [0,0,0])
    minkowski(){
        cube([sx-2*r, sy-2*r, sz-2*r], center=false);
        sphere(r=r);
    }
}

module screw_post(h=10, od=8, id=3.2){
    difference(){
        cylinder(h=h, d=od);
        translate([0,0,-0.2]) cylinder(h=h+0.4, d=id);
    }
}

module knob(d=52, h=22, skirt=2.5, pointer_len=10, pointer_w=4, bore=6.35){
    difference(){
        union(){
            cylinder(h=h, d=d);
            translate([0,0,h-6]) cylinder(h=6, d=d-6);
            translate([0,0,0]) cylinder(h=skirt, d=d+4);
            translate([d/2-6,0,h-4])
                rotate([0,90,0])
                    cylinder(h=pointer_len, d=pointer_w);
        }
        translate([0,0,-0.2]) cylinder(h=h+0.4, d=bore);
        translate([0,0,h/2]) rotate([0,90,0]) cylinder(h=d, d=2.2);
    }
}

module dial_ring(od=70, id=56, h=2.2){
    difference(){
        cylinder(h=h, d=od);
        translate([0,0,-0.2]) cylinder(h=h+0.4, d=id);
    }
}

module vent_slots(area=[70,18], slot_w=3, slot_gap=3, depth=2.2){
    w=area[0]; h=area[1];
    n=floor((w+slot_gap)/(slot_w+slot_gap));
    total = n*slot_w + (n-1)*slot_gap;
    x0 = -total/2 + slot_w/2;
    for(i=[0:n-1]){
        translate([x0 + i*(slot_w+slot_gap), 0, 0])
            cube([slot_w, h, depth], center=true);
    }
}

module label_plate(size=[46,16,1.2]){
    rounded_box([size[0], size[1], size[2]], r=1.5, center=true);
}

module variac_body(){
    body=[160,130,95];
    corner_r=10;

    difference(){
        union(){
            rounded_box(body, r=corner_r, center=true);

            translate([0,0,body[2]/2 - 2.5])
                rounded_box([150,120,5], r=8, center=true);

            translate([0,0,-body[2]/2 + 2.5])
                rounded_box([150,120,5], r=8, center=true);

            translate([0,0,body[2]/2 + 1.1])
                dial_ring(od=74, id=58, h=2.2);

            translate([0,0,body[2]/2 + 3.3])
                knob(d=52, h=22, skirt=2.5, pointer_len=10, pointer_w=4, bore=6.35);

            translate([0, body[1]/2 - 18, -body[2]/2 + 18])
                rotate([90,0,0])
                    cylinder(h=6, d=18);

            translate([0, -body[1]/2 + 18, -body[2]/2 + 18])
                rotate([90,0,0])
                    cylinder(h=6, d=18);

            translate([0, body[1]/2 - 18, -body[2]/2 + 18])
                rotate([90,0,0])
                    cylinder(h=6, d=10);

            translate([0, -body[1]/2 + 18, -body[2]/2 + 18])
                rotate([90,0,0])
                    cylinder(h=6, d=10);

            translate([0, -body[1]/2 + 0.8, -body[2]/2 + 30])
                rotate([90,0,0])
                    label_plate([60,18,1.2]);
        }

        translate([0,0,0])
            rounded_box([150,120,85], r=8, center=true);

        translate([0,0,body[2]/2 - 1.2])
            cylinder(h=30, d=8.2);

        translate([0,0,body[2]/2 - 0.6])
            cylinder(h=3.0, d=18);

        translate([0, body[1]/2 + 0.1, -body[2]/2 + 18])
            rotate([90,0,0])
                cylinder(h=10, d=12);

        translate([0, -body[1]/2 - 10.1, -body[2]/2 + 18])
            rotate([90,0,0])
                cylinder(h=20, d=12);

        translate([0, body[1]/2 + 0.1, -body[2]/2 + 18])
            rotate([90,0,0])
                cylinder(h=10, d=20);

        translate([0, -body[1]/2 - 10.1, -body[2]/2 + 18])
            rotate([90,0,0])
                cylinder(h=20, d=20);

        translate([0, body[1]/2 - 0.8, -body[2]/2 + 18])
            rotate([90,0,0])
                cylinder(h=6.5, d=18);

        translate([0, -body[1]/2 + 0.8, -body[2]/2 + 18])
            rotate([90,0,0])
                cylinder(h=6.5, d=18);

        translate([0, body[1]/2 - 0.8, -body[2]/2 + 18])
            rotate([90,0,0])
                cylinder(h=6.5, d=10);

        translate([0, -body[1]/2 + 0.8, -body[2]/2 + 18])
            rotate([90,0,0])
                cylinder(h=6.5, d=10);

        translate([0, -body[1]/2 + 0.2, -body[2]/2 + 30])
            rotate([90,0,0])
                rounded_box([56,14,2.0], r=2, center=true);

        translate([0,0,-body[2]/2 + 2.5])
            cylinder(h=6, d=6);

        translate([0,0,body[2]/2 - 2.5])
            cylinder(h=6, d=6);

        translate([0,0,0])
            for(sx=[-1,1], sy=[-1,1]){
                translate([sx*(body[0]/2-18), sy*(body[1]/2-18), -body[2]/2+6])
                    cylinder(h=20, d=3.6);
            }

        translate([0,0,0])
            for(sx=[-1,1], sy=[-1,1]){
                translate([sx*(body[0]/2-18), sy*(body[1]/2-18), body[2]/2-6])
                    cylinder(h=20, d=3.6);
            }

        translate([0,0,0])
            for(sx=[-1,1], sy=[-1,1]){
                translate([sx*(body[0]/2-18), sy*(body[1]/2-18), body[2]/2-2.2])
                    cylinder(h=3.0, d=7.2);
            }

        translate([0,0,0])
            for(sx=[-1,1], sy=[-1,1]){
                translate([sx*(body[0]/2-18), sy*(body[1]/2-18), -body[2]/2-0.8])
                    cylinder(h=3.0, d=7.2);
            }

        translate([0,0,0])
            for(side=[-1,1]){
                translate([0, side*(body[1]/2-1.2), 10])
                    rotate([90,0,0])
                        vent_slots([90,20], slot_w=3, slot_gap=3, depth=3.0);
            }

        translate([0,0,0])
            for(side=[-1,1]){
                translate([0, side*(body[1]/2-1.2), -10])
                    rotate([90,0,0])
                        vent_slots([90,20], slot_w=3, slot_gap=3, depth=3.0);
            }
    }

    for(sx=[-1,1], sy=[-1,1]){
        translate([sx*(160/2-18), sy*(130/2-18), -95/2+6])
            screw_post(h=12, od=9, id=3.2);
    }

    for(sx=[-1,1], sy=[-1,1]){
        translate([sx*(160/2-18), sy*(130/2-18), 95/2-18])
            screw_post(h=12, od=9, id=3.2);
    }

    for(sx=[-1,1], sy=[-1,1]){
        translate([sx*(160/2-22), sy*(130/2-22), -95/2-1.5])
            cylinder(h=3, d=14);
    }
}

variac_body();