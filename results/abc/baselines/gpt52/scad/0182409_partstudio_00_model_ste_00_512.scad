$fn=96;

main_d = 40;
main_h = 22;

boss_d = 22;
boss_h = 10;

total_h = main_h + boss_h;

square_hole = 10.2;
hole_clear = 0.2;

scallop_count = 24;
scallop_r = 2.2;
scallop_depth = 1.6;

facet_count = 12;

shoulder_h = 4;
shoulder_r1 = main_d/2 - 1.2;
shoulder_r2 = boss_d/2 + 0.8;

module faceted_barrel(d, h, facets){
    cylinder(h=h, r=d/2, $fn=facets);
}

module scalloped_rim(d, h, n, r_scallop, depth){
    difference(){
        cylinder(h=h, r=d/2, $fn=128);
        for(i=[0:n-1]){
            rotate([0,0,360*i/n])
                translate([d/2 - depth, 0, h/2])
                    cylinder(h=h+0.6, r=r_scallop, center=true, $fn=48);
        }
    }
}

module rounded_shoulder(h, r1, r2){
    hull(){
        translate([0,0,0]) cylinder(h=0.2, r=r1, $fn=96);
        translate([0,0,h]) cylinder(h=0.2, r=r2, $fn=96);
    }
}

module knob_body(){
    union(){
        translate([0,0,-total_h/2])
            union(){
                translate([0,0,0])
                    union(){
                        faceted_barrel(main_d, main_h, facet_count);
                        translate([0,0,0])
                            scalloped_rim(main_d+1.2, main_h, scallop_count, scallop_r, scallop_depth);
                    }
                translate([0,0,main_h-shoulder_h])
                    rounded_shoulder(shoulder_h, shoulder_r1, shoulder_r2);
                translate([0,0,main_h])
                    cylinder(h=boss_h, r=boss_d/2, $fn=96);
            }
    }
}

module square_through_hole(size){
    translate([0,0,0])
        linear_extrude(height=total_h+2, center=true)
            square([size, size], center=true);
}

difference(){
    knob_body();
    square_through_hole(square_hole + hole_clear);
}