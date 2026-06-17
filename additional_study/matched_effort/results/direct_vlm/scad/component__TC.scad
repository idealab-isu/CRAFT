$fn=96;

// Generic parametric component (mounting plate with boss, through-holes, and a cable slot)

plate_l = 80;
plate_w = 50;
plate_t = 6;

corner_r = 6;

boss_d = 22;
boss_h = 10;

hole_d = 4.2;
hole_edge_x = 12;
hole_edge_y = 10;

slot_l = 28;
slot_w = 8;
slot_r = 3;
slot_offset_y = 0;

module rounded_rect_2d(l, w, r){
    r2 = min(r, min(l,w)/2);
    hull(){
        for (sx=[-1,1], sy=[-1,1])
            translate([sx*(l/2 - r2), sy*(w/2 - r2)])
                circle(r=r2);
    }
}

module rounded_slot_2d(l, w, r){
    r2 = min(r, w/2);
    hull(){
        translate([-(l/2 - r2), 0]) circle(r=r2);
        translate([ (l/2 - r2), 0]) circle(r=r2);
    }
}

module component(){
    difference(){
        union(){
            // Base plate
            linear_extrude(height=plate_t)
                rounded_rect_2d(plate_l, plate_w, corner_r);

            // Central boss
            translate([0,0,plate_t])
                cylinder(d=boss_d, h=boss_h);
        }

        // Through mounting holes (4 corners)
        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*(plate_l/2 - hole_edge_x), sy*(plate_w/2 - hole_edge_y), -0.5])
                cylinder(d=hole_d, h=plate_t + boss_h + 1);
        }

        // Cable slot through plate
        translate([0, slot_offset_y, -0.5])
            linear_extrude(height=plate_t + 1)
                rounded_slot_2d(slot_l, slot_w, slot_r);

        // Boss center bore
        translate([0,0,plate_t-0.5])
            cylinder(d=8, h=boss_h + 1);
    }
}

component();