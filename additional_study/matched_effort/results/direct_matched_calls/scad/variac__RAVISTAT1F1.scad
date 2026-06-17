$fn=96;

// RAVISTAT 1F-1 variac (approximate visual model)

module rounded_box(size=[10,10,10], r=1, center=false){
    x=size[0]; y=size[1]; z=size[2];
    translate(center ? [-x/2,-y/2,-z/2] : [0,0,0])
    minkowski(){
        cube([x-2*r,y-2*r,z-2*r], center=false);
        sphere(r=r);
    }
}

module knurl_ring(od=40, id=34, h=10, teeth=48, tooth_depth=1.2){
    difference(){
        cylinder(d=od, h=h);
        translate([0,0,-0.2]) cylinder(d=id, h=h+0.4);
    }
    for(i=[0:teeth-1]){
        a=360*i/teeth;
        rotate([0,0,a])
            translate([od/2 - tooth_depth/2,0,h/2])
                cube([tooth_depth, 2.2, h], center=true);
    }
}

module pointer_cap(d=18, h=8){
    difference(){
        union(){
            cylinder(d=d, h=h);
            translate([0,0,h]) cylinder(d1=d, d2=d*0.85, h=2);
        }
        translate([0,0,-0.2]) cylinder(d=d*0.35, h=h+2.4);
    }
    // pointer
    translate([d*0.45,0,h*0.65])
        rotate([0,0,0])
            linear_extrude(height=1.6)
                polygon(points=[[0,0],[10,1.2],[10,-1.2]]);
}

module dial_plate(d=78, h=2.2){
    difference(){
        cylinder(d=d, h=h);
        translate([0,0,-0.2]) cylinder(d=d-6, h=h+0.4);
    }
    // tick marks
    for(i=[0:59]){
        a=360*i/60;
        len = (i%5==0) ? 6 : 3.2;
        w   = (i%5==0) ? 1.2 : 0.8;
        rotate([0,0,a])
            translate([d/2-3.2,0,h])
                cube([len,w,0.8], center=false);
    }
}

module terminal_block(w=26, d=18, h=14){
    difference(){
        rounded_box([w,d,h], r=1.2, center=false);
        // screw holes
        for(x=[w*0.28, w*0.72]){
            translate([x,d*0.55,h*0.55])
                rotate([90,0,0])
                    cylinder(d=4.2, h=d+1, center=true);
        }
    }
    // screws
    for(x=[w*0.28, w*0.72]){
        translate([x,d*0.55,h])
            cylinder(d=6, h=2.2);
    }
}

module variac_body(){
    // Main can
    can_d=92;
    can_h=62;
    base_th=4;

    // Base flange
    color([0.15,0.15,0.15])
    union(){
        cylinder(d=can_d+10, h=base_th);
        translate([0,0,base_th])
            cylinder(d=can_d, h=can_h-base_th);
    }

    // Vent slots around upper body
    color([0.12,0.12,0.12])
    for(i=[0:23]){
        a=360*i/24;
        rotate([0,0,a])
            translate([can_d/2-2.2,0,can_h*0.55])
                cube([4.5,6.5,18], center=true);
    }

    // Mounting feet holes in flange
    difference(){
        // subtract holes from flange only
        translate([0,0,0])
            cylinder(d=can_d+10, h=base_th);
        for(i=[0:2]){
            a=120*i+30;
            rotate([0,0,a])
                translate([(can_d+10)/2-8,0,base_th/2])
                    cylinder(d=5.2, h=base_th+1, center=true);
        }
    }
}

module top_assembly(){
    // Dial plate
    translate([0,0,62])
        color([0.85,0.85,0.85])
            dial_plate(d=78, h=2.2);

    // Knob skirt / knurl
    translate([0,0,64.2])
        color([0.2,0.2,0.2])
            knurl_ring(od=54, id=40, h=14, teeth=54, tooth_depth=1.1);

    // Center hub
    translate([0,0,64.2])
        color([0.18,0.18,0.18])
            cylinder(d=40, h=14);

    // Pointer cap
    translate([0,0,78.2])
        color([0.1,0.1,0.1])
            pointer_cap(d=26, h=10);

    // Shaft
    translate([0,0,62])
        color([0.6,0.6,0.6])
            cylinder(d=8, h=30);
}

module label_band(){
    // Side label plate "RAVISTAT 1F-1"
    can_d=92;
    can_h=62;
    plate_w=54;
    plate_h=18;
    plate_t=1.6;

    translate([0,0,can_h*0.35])
    rotate([0,90,0])
    translate([0,0,can_d/2+0.8])
    color([0.9,0.9,0.9])
    rounded_box([plate_w, plate_h, plate_t], r=1.2, center=true);

    // Raised text approximation (simple blocks)
    // ( text can be slow; keep simple and renderable)
    translate([0,0,can_h*0.35])
    rotate([0,90,0])
    translate([0,0,can_d/2+1.7])
    color([0.1,0.1,0.1])
    linear_extrude(height=0.8)
        text("RAVISTAT 1F-1", size=6.2, halign="center", valign="center", font="Liberation Sans:style=Bold");
}

module terminals(){
    can_d=92;
    // Terminal block on side near bottom
    translate([0,0,10])
    rotate([0,90,0])
    translate([0,0,can_d/2+9])
    color([0.2,0.2,0.2])
        terminal_block(w=30, d=20, h=16);

    // Cable gland / strain relief
    translate([0,0,10])
    rotate([0,90,0])
    translate([18,0,can_d/2+2])
    color([0.1,0.1,0.1])
    union(){
        cylinder(d=14, h=10);
        translate([0,0,10]) cylinder(d1=14, d2=10, h=6);
    }
}

module variac(){
    union(){
        variac_body();
        top_assembly();
        label_band();
        terminals();
    }
}

// Scene
translate([0,0,0]) variac();