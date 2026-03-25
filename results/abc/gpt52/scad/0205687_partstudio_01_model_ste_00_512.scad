$fn=96;

disk_d = 40;
disk_h = 8;

rim_recess_d = 34;
rim_recess_depth = 1.2;

center_boss_size = 10;
center_boss_h = 1.6;

center_square_hole = 6.2;

peg_size = 6;
peg_h = 6;

diamond_w = 6;
diamond_h = 10;
diamond_cut_depth = 2.2;

diamond_r = 11;

module diamond2d(w,h){
    polygon(points=[
        [0, h/2],
        [w/2, 0],
        [0, -h/2],
        [-w/2, 0]
    ]);
}

module diamond_cut(pos=[0,0], rot=0, depth=2){
    translate([pos[0], pos[1], disk_h - depth])
        rotate([0,0,rot])
            linear_extrude(height=depth+0.2)
                diamond2d(diamond_w, diamond_h);
}

module face_pattern_cuts(){
    diamond_cut([0, diamond_r], 0, diamond_cut_depth);
    for(a=[0:90:270]){
        diamond_cut([diamond_r*cos(a), diamond_r*sin(a)], a, diamond_cut_depth);
    }
}

module main_body(){
    difference(){
        union(){
            cylinder(d=disk_d, h=disk_h, center=false);
            translate([0,0,disk_h])
                cube([center_boss_size, center_boss_size, center_boss_h], center=true);
            translate([0,0,-peg_h])
                cube([peg_size, peg_size, peg_h], center=true);
        }

        translate([0,0,disk_h - rim_recess_depth])
            cylinder(d=rim_recess_d, h=rim_recess_depth+0.2, center=false);

        face_pattern_cuts();

        translate([0,0,-peg_h-0.2])
            cube([center_square_hole, center_square_hole, disk_h + peg_h + center_boss_h + 0.6], center=false);
    }
}

translate([0,0,-disk_h/2])
    main_body();