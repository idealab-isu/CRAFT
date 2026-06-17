$fn=96;

// RAVISTAT 1F-1 variac (approximate, renderable model)
// Units: mm

// ---------- Parameters ----------
base_d = 120;
base_h = 55;

top_plate_d = 112;
top_plate_h = 3;

shaft_d = 10;
shaft_h = 22;

knob_d = 62;
knob_h = 22;
knob_skirt_h = 6;

dial_d = 92;
dial_h = 1.6;

handle_len = 34;
handle_w = 10;
handle_t = 8;

vent_slot_w = 4;
vent_slot_h = 18;
vent_slot_depth = 2.2;

foot_d = 12;
foot_h = 4;

panel_th = 2.2;
panel_w = 58;
panel_h = 26;

binding_post_d = 10;
binding_post_h = 10;

screw_d = 4;
screw_head_d = 7;
screw_head_h = 2;

// ---------- Helpers ----------
module rounded_cylinder(d=10,h=10,r=1){
    minkowski(){
        cylinder(d=d-2*r,h=h-2*r,center=false);
        sphere(r=r);
    }
}

module screw(x,y,z){
    translate([x,y,z])
    union(){
        cylinder(d=screw_d,h=base_h+top_plate_h+2);
        translate([0,0,base_h+top_plate_h-0.2])
            cylinder(d=screw_head_d,h=screw_head_h);
    }
}

module vent_band(){
    // slots around the side
    n = 28;
    for(i=[0:n-1]){
        a = i*360/n;
        translate([0,0,18])
        rotate([0,0,a])
        translate([base_d/2-1.2,0,0])
            rotate([0,90,0])
                cube([vent_slot_depth, vent_slot_w, vent_slot_h], center=true);
    }
}

module feet(){
    for(a=[45,135,225,315]){
        rotate([0,0,a])
        translate([base_d*0.33,0,-foot_h])
            cylinder(d=foot_d,h=foot_h);
    }
}

module top_plate(){
    translate([0,0,base_h])
        cylinder(d=top_plate_d,h=top_plate_h);
}

module dial(){
    translate([0,0,base_h+top_plate_h+0.2])
    difference(){
        cylinder(d=dial_d,h=dial_h);
        // tick marks as shallow grooves
        for(i=[0:49]){
            a = -140 + i*(280/49);
            rotate([0,0,a])
            translate([dial_d/2-6,0,dial_h/2])
                cube([10, (i%5==0)?1.6:0.9, dial_h+0.4], center=true);
        }
        // center hole
        translate([0,0,-0.2]) cylinder(d=shaft_d+2.5,h=dial_h+0.6);
    }
}

module knob(){
    z0 = base_h+top_plate_h+dial_h+0.6;
    translate([0,0,z0])
    difference(){
        union(){
            // main knob body
            cylinder(d=knob_d,h=knob_h);
            // skirt flare
            translate([0,0,0])
                cylinder(d1=knob_d+6,d2=knob_d,h=knob_skirt_h);
            // pointer
            translate([knob_d/2-2,0,knob_h-6])
                rotate([0,0,0])
                    cube([14,4,6], center=true);
            // grip ribs
            for(i=[0:23]){
                a=i*360/24;
                rotate([0,0,a])
                translate([knob_d/2-2.2,0,knob_h/2])
                    cube([3.2,2.2,knob_h-4], center=true);
            }
        }
        // shaft hole
        translate([0,0,-0.2]) cylinder(d=shaft_d+0.6,h=knob_h+0.4);
        // set-screw flat (approx)
        translate([shaft_d/2+1.2,0,knob_h/2])
            cube([3,6,knob_h+1], center=true);
    }
}

module shaft(){
    translate([0,0,base_h+top_plate_h])
        cylinder(d=shaft_d,h=shaft_h);
}

module front_panel(){
    // small terminal panel on side
    translate([0,0,18])
    rotate([0,0,180])
    translate([base_d/2-0.8,0,0])
    rotate([0,90,0])
    difference(){
        union(){
            // panel plate
            translate([0,0,0])
                cube([panel_th,panel_w,panel_h], center=true);
            // slight bezel
            translate([panel_th/2,0,0])
                cube([panel_th*0.6,panel_w+4,panel_h+4], center=true);
        }
        // holes for binding posts
        for(y=[-16,0,16]){
            translate([0,y,0])
                rotate([0,90,0])
                    cylinder(d=binding_post_d-2,h=panel_th+2, center=true);
        }
    }
    // binding posts protruding
    translate([0,0,18])
    rotate([0,0,180])
    translate([base_d/2+binding_post_h/2,0,0])
    rotate([0,90,0])
    for(y=[-16,0,16]){
        translate([0,y,0])
        union(){
            cylinder(d=binding_post_d,h=binding_post_h, center=true);
            translate([binding_post_h/2,0,0])
                cylinder(d=binding_post_d*0.7,h=3, center=true);
        }
    }
}

module handle(){
    // carry handle on top
    z = base_h+top_plate_h+6;
    translate([0,0,z])
    union(){
        // two posts
        for(x=[-38,38]){
            translate([x,0,0])
            difference(){
                rounded_cylinder(d=14,h=18,r=1.2);
                translate([0,0,6]) cylinder(d=6.5,h=20);
            }
        }
        // arch
        translate([0,0,16])
        rotate([90,0,0])
        difference(){
            // outer
            rotate_extrude(angle=180)
                translate([38,0,0])
                    circle(r=handle_t/2);
            // inner to make it more handle-like
            rotate_extrude(angle=180)
                translate([38,0,0])
                    circle(r=handle_t/2-2);
        }
        // grip bar
        translate([0,0,16])
        rotate([0,90,0])
        cylinder(d=handle_t,h=76, center=true);
    }
}

module label_text(){
    // embossed label on top plate
    translate([0,0,base_h+top_plate_h+0.2])
    linear_extrude(height=0.8)
    translate([-38,-52,0])
    text("RAVISTAT 1F-1", size=8, font="Liberation Sans:style=Bold");
}

module body(){
    difference(){
        union(){
            // main body
            cylinder(d=base_d,h=base_h);
            // top plate
            top_plate();
            // feet
            feet();
        }
        // hollow interior
        translate([0,0,4])
            cylinder(d=base_d-8,h=base_h-6);
        // vents
        vent_band();
        // bottom recess
        translate([0,0,-0.2])
            cylinder(d=base_d-14,h=3.2);
        // screw holes (4)
        for(a=[30,150,210,330]){
            rotate([0,0,a])
            translate([base_d*0.36,0,-0.2])
                cylinder(d=4.2,h=base_h+top_plate_h+2);
        }
    }
    // screws (visual)
    for(a=[30,150,210,330]){
        rotate([0,0,a])
        translate([base_d*0.36,0,0])
        union(){
            translate([0,0,-0.2]) cylinder(d=4,h=base_h+top_plate_h+1);
            translate([0,0,base_h+top_plate_h-0.2]) cylinder(d=7,h=2);
        }
    }
}

module variac(){
    color([0.85,0.85,0.86]) body();
    color([0.75,0.75,0.78]) shaft();
    color([0.95,0.95,0.95]) dial();
    color([0.15,0.15,0.16]) knob();
    color([0.7,0.7,0.72]) handle();
    color([0.9,0.9,0.9]) front_panel();
    color([0.2,0.2,0.2]) label_text();
}

// ---------- Render ----------
variac();