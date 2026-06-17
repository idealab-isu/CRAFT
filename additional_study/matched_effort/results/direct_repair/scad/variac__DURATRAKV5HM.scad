$fn=96;

// DURATRAK V5HM variac (approximate external model)
// Units: mm

module rounded_box(size=[100,100,50], r=6){
    x=size[0]; y=size[1]; z=size[2];
    r2=min(r, min(x,y)/2-0.01);
    hull(){
        for (sx=[-1,1], sy=[-1,1], sz=[-1,1]){
            translate([sx*(x/2-r2), sy*(y/2-r2), sz*(z/2-r2)])
                sphere(r=r2);
        }
    }
}

module screw_boss(h=6, d=10, hole=3.5){
    difference(){
        cylinder(h=h, d=d);
        translate([0,0,-0.1]) cylinder(h=h+0.2, d=hole);
    }
}

module knurled_knob(d=58, h=18, skirt=2.0, knurls=48, knurl_depth=1.2){
    // Simple knurled knob approximation
    difference(){
        union(){
            cylinder(h=h, d=d);
            translate([0,0,h-3]) cylinder(h=3, d=d-6);
            translate([0,0,0]) cylinder(h=2.5, d=d-4);
        }
        // knurl cuts
        for(i=[0:knurls-1]){
            rotate([0,0, i*360/knurls])
                translate([d/2 - knurl_depth/2,0,h/2])
                    rotate([0,90,0])
                        cylinder(h=knurl_depth+0.6, d=3.2, center=true);
        }
        // center bore
        translate([0,0,-0.1]) cylinder(h=h+0.2, d=8.2);
        // pointer notch
        rotate([0,0,20])
            translate([d/2-6,0,h-4])
                cube([12,3.2,6], center=true);
    }
    // pointer ridge
    rotate([0,0,20])
        translate([d/2-10,0,h-2.2])
            cube([18,2.2,2.2], center=true);
}

module dial_ring(od=86, id=64, h=3.2){
    difference(){
        cylinder(h=h, d=od);
        translate([0,0,-0.1]) cylinder(h=h+0.2, d=id);
    }
}

module vent_slots(w=2.2, l=26, h=2.5, count=10, pitch=4.2){
    for(i=[0:count-1]){
        translate([0,(i-(count-1)/2)*pitch,0])
            cube([l,w,h], center=true);
    }
}

module banana_post(d=12, h=14, hole=4.2){
    difference(){
        union(){
            cylinder(h=h, d=d);
            translate([0,0,h]) cylinder(h=3, d=d-2);
        }
        translate([0,0,-0.1]) cylinder(h=h+3.2, d=hole);
    }
}

module rocker_switch(body=[22,14,12], cut=[20,12,10]){
    // body centered at origin, extends +Z
    difference(){
        translate([-body[0]/2,-body[1]/2,0]) cube(body);
        translate([-cut[0]/2,-cut[1]/2,1]) cube([cut[0],cut[1],cut[2]]);
    }
    // rocker cap
    translate([0,0,body[2]-1.5])
        hull(){
            translate([-9,-5,0]) cylinder(h=3, d=6);
            translate([ 9,-5,0]) cylinder(h=3, d=6);
            translate([-9, 5,0]) cylinder(h=3, d=6);
            translate([ 9, 5,0]) cylinder(h=3, d=6);
        }
}

module fuse_holder(d=16, h=12){
    difference(){
        union(){
            cylinder(h=h, d=d);
            translate([0,0,h]) cylinder(h=3, d=d-2);
        }
        translate([0,0,-0.1]) cylinder(h=h+3.2, d=10);
        // slot
        translate([0,0,h+1.5]) cube([d,2.2,2.2], center=true);
    }
}

module label_plate(size=[60,18,1.2], r=1.5){
    x=size[0]; y=size[1]; z=size[2];
    hull(){
        for(sx=[-1,1], sy=[-1,1]){
            translate([sx*(x/2-r), sy*(y/2-r), 0])
                cylinder(h=z, r=r);
        }
    }
}

module variac_v5hm(){
    // Overall approximate dimensions
    body_x=165;
    body_y=145;
    body_z=120;
    corner_r=10;

    top_th=3.0;
    wall=3.0;

    // Base enclosure
    difference(){
        translate([0,0,body_z/2])
            rounded_box([body_x, body_y, body_z], r=corner_r);

        // Hollow interior
        translate([0,0,body_z/2 + top_th])
            rounded_box([body_x-2*wall, body_y-2*wall, body_z-2*top_th], r=max(2,corner_r-4));

        // Bottom feet recesses
        for(sx=[-1,1], sy=[-1,1]){
            translate([sx*(body_x/2-18), sy*(body_y/2-18), 6])
                cylinder(h=8, d=16, center=true);
        }

        // Side vents (left)
        translate([-body_x/2+1.2,0,body_z*0.55])
            rotate([0,90,0])
                vent_slots(w=2.2,l=34,h=3.0,count=12,pitch=4.4);

        // Side vents (right)
        translate([ body_x/2-1.2,0,body_z*0.55])
            rotate([0,90,0])
                vent_slots(w=2.2,l=34,h=3.0,count=12,pitch=4.4);

        // Rear vents
        translate([0, body_y/2-1.2, body_z*0.55])
            rotate([90,0,0])
                vent_slots(w=2.2,l=44,h=3.0,count=12,pitch=4.4);

        // Front panel cutouts (approx)
        // Switch
        translate([-45, -body_y/2+2.0, 28])
            rotate([90,0,0])
                cube([22,14,12], center=true);

        // Fuse
        translate([-10, -body_y/2+2.0, 28])
            rotate([90,0,0])
                cylinder(h=20, d=16, center=true);

        // Output posts
        for(xp=[25, 45]){
            translate([xp, -body_y/2+2.0, 28])
                rotate([90,0,0])
                    cylinder(h=20, d=12, center=true);
        }

        // Front label recess
        translate([0, -body_y/2+1.6, 58])
            rotate([90,0,0])
                cube([70,22,2.0], center=true);

        // Top dial opening (for knob shaft clearance)
        translate([0,0,body_z-2.0])
            cylinder(h=10, d=14, center=true);

        // Top dial ring recess
        translate([0,0,body_z-1.2])
            cylinder(h=3.0, d=92, center=true);
    }

    // Feet
    for(sx=[-1,1], sy=[-1,1]){
        translate([sx*(body_x/2-18), sy*(body_y/2-18), 2.5])
            cylinder(h=5, d=18);
    }

    // Internal screw bosses (visible if cutaway; kept for realism)
    for(sx=[-1,1], sy=[-1,1]){
        translate([sx*(body_x/2-20), sy*(body_y/2-20), 8])
            screw_boss(h=10, d=12, hole=3.6);
    }

    // Top dial ring
    translate([0,0,body_z-3.2])
        dial_ring(od=92, id=66, h=3.2);

    // Knob
    translate([0,0,body_z-3.2+3.2])
        knurled_knob(d=62, h=20, knurls=54, knurl_depth=1.2);

    // Front components (protruding)
    // Switch
    translate([-45, -body_y/2-0.1, 22])
        rotate([90,0,0])
            rocker_switch(body=[24,16,14], cut=[20,12,10]);

    // Fuse holder
    translate([-10, -body_y/2-0.1, 22])
        rotate([90,0,0])
            fuse_holder(d=16, h=12);

    // Banana posts
    translate([25, -body_y/2-0.1, 22])
        rotate([90,0,0])
            banana_post(d=12, h=14, hole=4.2);

    translate([45, -body_y/2-0.1, 22])
        rotate([90,0,0])
            banana_post(d=12, h=14, hole=4.2);

    // Front label plate
    translate([0, -body_y/2-0.2, 52])
        rotate([90,0,0])
            label_plate([72,24,1.4], r=2);

    // Raised brand text (simple)
    translate([0, -body_y/2-0.9, 52])
        rotate([90,0,0])
            linear_extrude(height=0.9)
                text("DURATRAK V5HM", size=7.2, halign="center", valign="center", font="Liberation Sans:style=Bold");
}

variac_v5hm();