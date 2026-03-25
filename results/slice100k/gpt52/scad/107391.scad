$fn=96;

L = 6.7;   // length (Y)
W = 5.4;   // width  (X)
T = 0.6;   // thickness (Z)

taper = 0.35;          // total width reduction from center to ends
end_r = 1.15;          // end rounding radius
side_scallop_r = 0.85; // scallop radius
side_scallop_inset = 0.55; // how deep scallop cuts in from side
side_scallop_y = 1.55; // distance from center along Y for scallops

fillet_r = 0.28;       // perimeter fillet radius
relief_h = 0.10;       // diagonal relief height
relief_w = 0.55;       // relief band width
relief_pitch = 1.25;   // spacing between relief bands
relief_angle = 28;     // diagonal angle

module capsule2d(len, wid, r){
    hull(){
        translate([0,  len/2 - r]) circle(r=r);
        translate([0, -len/2 + r]) circle(r=r);
    }
    intersection(){
        children();
        square([wid, len], center=true);
    }
}

module tapered_outline_2d(){
    hull(){
        translate([0,0]) scale([W,1]) capsule2d(L*0.55, 1, end_r/W);
        translate([0, L/2 - end_r]) scale([W - taper,1]) circle(r=end_r);
        translate([0,-L/2 + end_r]) scale([W - taper,1]) circle(r=end_r);
    }
}

module scallops_2d(){
    union(){
        for (sy = [-1,1]){
            translate([ W/2 - side_scallop_inset, sy*side_scallop_y]) circle(r=side_scallop_r);
            translate([-W/2 + side_scallop_inset, sy*side_scallop_y]) circle(r=side_scallop_r);
        }
    }
}

module base_2d(){
    difference(){
        tapered_outline_2d();
        scallops_2d();
    }
}

module filleted_plate(){
    minkowski(){
        linear_extrude(height=T-2*fillet_r, center=true, convexity=10)
            offset(r=max(0, fillet_r*0.35)) base_2d();
        sphere(r=fillet_r);
    }
}

module diagonal_relief(sign=1){
    intersection(){
        linear_extrude(height=relief_h, center=false, convexity=10)
            base_2d();
        translate([0,0,0])
        rotate([0,0,relief_angle])
        union(){
            for (i=[-20:20]){
                translate([i*relief_pitch,0,0])
                    square([relief_w, 40], center=true);
            }
        }
    }
}

module part(){
    union(){
        filleted_plate();
        translate([0,0, T/2 - relief_h])
            diagonal_relief(1);
        translate([0,0,-T/2])
            mirror([0,0,1])
                translate([0,0, T/2 - relief_h])
                    diagonal_relief(-1);
    }
}

part();