$fn=96;

// DURATRAK V5HM variac (approximate external model)
// Units: mm

module rounded_box(size=[100,80,60], r=6){
    x=size[0]; y=size[1]; z=size[2];
    r2=min(r, min(x,y)/2-0.01);
    hull(){
        for (sx=[-1,1], sy=[-1,1], sz=[-1,1]){
            translate([sx*(x/2-r2), sy*(y/2-r2), sz*(z/2-r2)])
                sphere(r=r2);
        }
    }
}

module screw_boss(h=6, d=10, hole=3.2){
    difference(){
        cylinder(h=h, d=d);
        translate([0,0,-0.1]) cylinder(h=h+0.2, d=hole);
    }
}

module knurled_knob(d=52, h=22, skirt=2.0, knurls=48, knurl_depth=1.2){
    difference(){
        union(){
            // main body
            cylinder(h=h, d=d);
            // top cap
            translate([0,0,h]) cylinder(h=2.2, d1=d*0.92, d2=d*0.78);
            // bottom skirt
            translate([0,0,-skirt]) cylinder(h=skirt, d1=d*1.02, d2=d);
        }
        // knurl cuts
        for(i=[0:knurls-1]){
            a = 360/knurls*i;
            rotate([0,0,a])
                translate([d/2 - knurl_depth/2,0,h/2])
                    cube([knurl_depth, 2.2, h+6], center=true);
        }
        // center bore for shaft
        translate([0,0,-skirt-0.1]) cylinder(h=h+skirt+3, d=6.35); // 1/4" shaft
        // set-screw flat hint
        translate([2.8,0,h/2]) cube([2.0,8.0,h+6], center=true);
    }
}

module pointer(d=52, h=2.2, len=18, w=6){
    // simple pointer on knob top
    translate([0,0,h])
        linear_extrude(height=2.0)
            polygon(points=[
                [d/2-2, -w/2],
                [d/2-2,  w/2],
                [d/2-2+len, 0]
            ]);
}

module vent_slots(area=[70,18], slot_w=2.2, gap=2.2, depth=2.0){
    // centered vent slots cut
    w=area[0]; h=area[1];
    n = floor((h + gap)/(slot_w+gap));
    for(i=[0:n-1]){
        y = -h/2 + (i+0.5)*(slot_w+gap);
        translate([0,y,0])
            cube([w, slot_w, depth], center=true);
    }
}

module label_plate(size=[58,18,1.2], r=1.5){
    x=size[0]; y=size[1]; z=size[2];
    translate([0,0,z/2])
    hull(){
        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*(x/2-r), sy*(y/2-r), 0])
                cylinder(h=z, r=r, center=true);
        }
    }
}

module variac_duratrak_v5hm(){
    // Overall envelope (approx)
    body_x=165;
    body_y=135;
    body_z=120;
    wall=3.0;
    corner_r=10;

    // Front panel features
    knob_d=56;
    knob_h=24;
    knob_center=[0, body_y/2 - 28, body_z/2 + 10];

    // Feet
    foot_d=16;
    foot_h=6;
    foot_inset=18;

    // Base body
    difference(){
        union(){
            // main enclosure
            translate([0,0,body_z/2])
                rounded_box([body_x, body_y, body_z], r=corner_r);

            // bottom feet
            for (sx=[-1,1], sy=[-1,1]){
                translate([sx*(body_x/2-foot_inset), sy*(body_y/2-foot_inset), 0])
                    cylinder(h=foot_h, d=foot_d);
            }

            // front panel bezel (slight)
            translate([0, body_y/2-1.2, body_z/2])
                cube([body_x-18, 2.4, body_z-18], center=true);

            // label plate
            translate([0, body_y/2-0.8, body_z-22])
                rotate([90,0,0])
                    label_plate([70,20,1.2], r=2);

            // knob
            translate(knob_center)
                rotate([0,0,0])
                    knurled_knob(d=knob_d, h=knob_h, knurls=54, knurl_depth=1.1);

            // knob pointer
            translate(knob_center)
                rotate([0,0,0])
                    pointer(d=knob_d, h=knob_h+2.2, len=18, w=6);
        }

        // Hollow interior (simple shell)
        translate([0,0,body_z/2 + wall])
            rounded_box([body_x-2*wall, body_y-2*wall, body_z-2*wall], r=max(1,corner_r-3));

        // Front knob shaft clearance through panel
        translate([knob_center[0], body_y/2+0.5, knob_center[2]])
            rotate([90,0,0])
                cylinder(h=20, d=10);

        // Front panel mounting screw holes (4)
        for (sx=[-1,1], sz=[-1,1]){
            translate([sx*(body_x/2-14), body_y/2-2.0, body_z/2 + sz*(body_z/2-18)])
                rotate([90,0,0])
                    cylinder(h=10, d=3.6);
        }

        // Rear panel cutouts: IEC-ish inlet + fuse + vents
        // Rear face at y = -body_y/2
        // IEC inlet
        translate([0, -body_y/2-0.5, 28])
            rotate([90,0,0])
                cube([28, 20, 12], center=true);

        // Fuse holder hole
        translate([body_x/2-28, -body_y/2-0.5, 28])
            rotate([90,0,0])
                cylinder(h=12, d=12.5);

        // Rear vents
        translate([0, -body_y/2-0.5, body_z/2+18])
            rotate([90,0,0])
                vent_slots(area=[90,26], slot_w=2.2, gap=2.2, depth=12);

        // Side vents (both sides)
        for (sx=[-1,1]){
            translate([sx*(body_x/2+0.5), 0, body_z/2+10])
                rotate([0,90,0])
                    vent_slots(area=[80,24], slot_w=2.2, gap=2.2, depth=12);
        }

        // Bottom mounting holes (optional)
        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*(body_x/2-28), sy*(body_y/2-28), -0.1])
                cylinder(h=foot_h+2, d=4.2);
        }
    }

    // Add internal bosses (visible if transparent; kept as solids)
    // (Placed inside; not subtracted)
    for (sx=[-1,1], sy=[-1,1]){
        translate([sx*(body_x/2-20), sy*(body_y/2-20), 10])
            screw_boss(h=10, d=12, hole=3.2);
    }
}

variac_duratrak_v5hm();