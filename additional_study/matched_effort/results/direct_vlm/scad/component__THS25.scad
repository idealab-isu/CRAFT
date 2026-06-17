$fn=96;

// Generic parametric component (mounting plate with boss, through-holes, and a cable slot)

plate_len = 80;
plate_wid = 50;
plate_thk = 6;

corner_r = 6;

boss_d = 26;
boss_h = 14;
boss_hole_d = 8;

hole_d = 5;
hole_edge_x = 12;
hole_edge_y = 10;

slot_len = 28;
slot_wid = 10;
slot_r = 4;
slot_offset_y = -10;

module rounded_rect_2d(l, w, r){
    r2 = min(r, min(l,w)/2);
    hull(){
        translate([ l/2 - r2,  w/2 - r2]) circle(r=r2);
        translate([-l/2 + r2,  w/2 - r2]) circle(r=r2);
        translate([ l/2 - r2, -w/2 + r2]) circle(r=r2);
        translate([-l/2 + r2, -w/2 + r2]) circle(r=r2);
    }
}

module rounded_slot_2d(l, w, r){
    r2 = min(r, w/2);
    hull(){
        translate([ l/2 - r2, 0]) circle(r=r2);
        translate([-l/2 + r2, 0]) circle(r=r2);
    }
}

module component(){
    difference(){
        union(){
            // Base plate
            linear_extrude(height=plate_thk)
                rounded_rect_2d(plate_len, plate_wid, corner_r);

            // Central boss
            translate([0,0,plate_thk])
                cylinder(d=boss_d, h=boss_h);
        }

        // Boss through-hole
        translate([0,0,-1])
            cylinder(d=boss_hole_d, h=plate_thk + boss_h + 2);

        // Four mounting holes
        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*(plate_len/2 - hole_edge_x), sy*(plate_wid/2 - hole_edge_y), -1])
                cylinder(d=hole_d, h=plate_thk + 2);
        }

        // Cable slot through plate
        translate([0, slot_offset_y, -1])
            linear_extrude(height=plate_thk + 2)
                rounded_slot_2d(slot_len, slot_wid, slot_r);

        // Light underside relief pocket (optional aesthetic)
        translate([0,0,1.2])
            linear_extrude(height=plate_thk-2.4)
                offset(delta=-2)
                    rounded_rect_2d(plate_len, plate_wid, corner_r);
    }
}

component();