$fn=64;

size = 70;
r = 35;
facet = 18;
wall = 3.2;

slot_w = 14;
slot_h = 10;
slot_len = 90;

cap_h = 14;
cap_r = 22;

tip_h = 18;
tip_r = 10;

module lowpoly_sphere(rr=35, f=18){
    intersection(){
        sphere(r=rr);
        union(){
            for (a=[0:180/f:180-180/f])
                for (b=[0:360/f:360-360/f])
                    rotate([a,b,0]) translate([0,0,rr*0.55])
                        cube([rr*2.2, rr*2.2, rr*1.2], center=true);
        }
    }
}

module shell(){
    difference(){
        lowpoly_sphere(r, facet);
        lowpoly_sphere(r-wall, facet);
    }
}

module long_horizontal_slot(){
    translate([0,0,0])
        cube([slot_len, slot_w, slot_h], center=true);
}

module planar_cutout(angle=0, tilt=0, w=18, h=90, t=40, z=0){
    translate([0,0,z])
        rotate([tilt,0,angle])
            translate([0,0,0])
                cube([t, w, h], center=true);
}

module cage_openings(){
    union(){
        long_horizontal_slot();

        for (ang=[0:60:300]){
            planar_cutout(angle=ang, tilt=0, w=16, h=95, t=50, z=0);
        }

        for (ang=[30:60:330]){
            planar_cutout(angle=ang, tilt=22, w=14, h=90, t=50, z=0);
        }

        for (ang=[0:90:270]){
            translate([0,0,0])
                rotate([0,0,ang])
                    translate([r*0.55,0,0])
                        rotate([0,35,0])
                            cube([60, 10, 22], center=true);
        }

        translate([0,0,r*0.55])
            rotate([0,0,0])
                cylinder(h=40, r1=10, r2=18, center=true);

        translate([0,0,-r*0.55])
            rotate([0,0,0])
                cylinder(h=40, r1=18, r2=10, center=true);
    }
}

module cap_and_tip(){
    union(){
        translate([0,0,r-cap_h*0.55])
            cylinder(h=cap_h, r1=cap_r*0.92, r2=cap_r, center=true, $fn=8);

        translate([0,0,-r+tip_h*0.55])
            cylinder(h=tip_h, r1=tip_r, r2=0.1, center=true, $fn=4);
    }
}

module pendant_lantern(){
    difference(){
        union(){
            shell();
            cap_and_tip();
        }
        cage_openings();

        translate([0,0,r-6])
            cylinder(h=18, r=7, center=true);

        translate([0,0,r-2])
            cylinder(h=10, r=4.2, center=true);

        for (ang=[0:45:315]){
            rotate([0,0,ang])
                translate([0,0,0])
                    rotate([0,18,0])
                        translate([r*0.2,0,0])
                            cube([70, 6, 70], center=true);
        }
    }
}

pendant_lantern();