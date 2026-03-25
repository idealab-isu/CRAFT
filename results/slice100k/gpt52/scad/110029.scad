$fn=96;

L = 20.8;
D = 4.0;
R = D/2;

slot_w = 1.6;
slot_depth = 3.0;
end_relief = 0.9;

taper_len = 1.6;
taper_drop = 0.35;

tip_round_r = 0.55;
chamfer = 0.35;

module capsule_x(len, r){
    hull(){
        translate([-len/2,0,0]) sphere(r=r);
        translate([ len/2,0,0]) sphere(r=r);
    }
}

module rod_body(){
    union(){
        cylinder(h=L-2*taper_len, r=R, center=true);
        translate([ (L-2*taper_len)/2,0,0])
            cylinder(h=taper_len, r1=R, r2=R-taper_drop, center=false);
        translate([-(L-2*taper_len)/2 - taper_len,0,0])
            cylinder(h=taper_len, r1=R-taper_drop, r2=R, center=false);
    }
}

module end_slot_cut(sign=1){
    x0 = sign*(L/2 - slot_depth);
    translate([x0,0,0])
        cube([slot_depth+0.02, slot_w, D+0.6], center=false);
}

module end_relief_cut(sign=1){
    x = sign*(L/2 - end_relief);
    translate([x,0,0])
        rotate([0,90,0])
            cylinder(h=end_relief+0.02, r=R*0.92, center=false);
}

module prong_tip_round(sign=1, ysign=1){
    x = sign*(L/2 - tip_round_r);
    y = ysign*(slot_w/2);
    translate([x,y,0])
        sphere(r=tip_round_r);
}

module prong_tip_chamfer_cut(sign=1, ysign=1){
    x = sign*(L/2 - chamfer/2);
    y = ysign*(slot_w/2 + 0.01);
    translate([x,y,0])
        rotate([0,0,ysign*45])
            cube([chamfer, chamfer, D+1.0], center=true);
}

difference(){
    union(){
        rod_body();
        for(sign=[-1,1], ysign=[-1,1]) prong_tip_round(sign, ysign);
    }

    translate([-L/2-0.01, -slot_w/2, -D/2-0.3]) end_slot_cut(-1);
    translate([ L/2-slot_depth-0.01, -slot_w/2, -D/2-0.3]) end_slot_cut(1);

    end_relief_cut(-1);
    end_relief_cut(1);

    for(sign=[-1,1], ysign=[-1,1]) prong_tip_chamfer_cut(sign, ysign);
}