$fn=64;

L = 80;
W = 24;
T = 10;

bodyL = 44;
tabL = 18;
clevisL = 18;

bodyW = 22;
tabW = 24;
clevisW = 24;

endR = bodyW/2;

hole_d = 5.2;
hole_spacing = 12;

diamond_d = 6.0;

clevis_slotW = 10;
clevis_slotDepth = 12;
clevis_slotEndR = 3.5;

clevis_pin_d = 6.2;
clevis_pin_z = 0;

module rounded_rect_2d(w,h,r){
    r2 = min(r, min(w,h)/2);
    hull(){
        translate([ w/2-r2,  h/2-r2]) circle(r=r2);
        translate([-w/2+r2,  h/2-r2]) circle(r=r2);
        translate([ w/2-r2, -h/2+r2]) circle(r=r2);
        translate([-w/2+r2, -h/2+r2]) circle(r=r2);
    }
}

module barrel_body(len, w, t){
    hull(){
        translate([-len/2 + w/2, 0, 0]) cylinder(h=t, r=w/2, center=true);
        translate([ len/2 - w/2, 0, 0]) cylinder(h=t, r=w/2, center=true);
    }
}

module tab_with_two_holes(len, w, t, hole_d, spacing){
    difference(){
        hull(){
            translate([-len/2, 0, 0]) cube([len, w, t], center=true);
            translate([ len/2, 0, 0]) cylinder(h=t, r=w/2, center=true);
        }
        for (yy=[-spacing/2, spacing/2]){
            translate([0, yy, 0]) cylinder(h=t+2, d=hole_d, center=true);
        }
    }
}

module clevis_end(len, w, t, slotW, slotDepth, slotEndR, pin_d){
    difference(){
        translate([0,0,0]) cube([len, w, t], center=true);
        translate([len/2 - slotDepth/2, 0, 0])
            hull(){
                translate([-slotDepth/2 + slotEndR,  slotW/2 - slotEndR, 0]) cylinder(h=t+2, r=slotEndR, center=true);
                translate([-slotDepth/2 + slotEndR, -slotW/2 + slotEndR, 0]) cylinder(h=t+2, r=slotEndR, center=true);
                translate([ slotDepth/2 - slotEndR,  slotW/2 - slotEndR, 0]) cylinder(h=t+2, r=slotEndR, center=true);
                translate([ slotDepth/2 - slotEndR, -slotW/2 + slotEndR, 0]) cylinder(h=t+2, r=slotEndR, center=true);
            }
        translate([len/2 - slotDepth + 6, 0, 0]) cylinder(h=t+2, d=pin_d, center=true);
    }
}

module diamond_hole(t, d){
    rotate([0,0,45]) cylinder(h=t+2, r=d/2, center=true, $fn=4);
}

module bracket(){
    difference(){
        union(){
            barrel_body(bodyL, bodyW, T);
            translate([-(bodyL/2 + tabL/2), 0, 0]) tab_with_two_holes(tabL, tabW, T, hole_d, hole_spacing);
            translate([(bodyL/2 + clevisL/2), 0, 0]) clevis_end(clevisL, clevisW, T, clevis_slotW, clevis_slotDepth, clevis_slotEndR, clevis_pin_d);
        }
        diamond_hole(T, diamond_d);
    }
}

bracket();