$fn=64;

th = 5.0;

module spoke(len, wid, h=th){
    cube([len, wid, h], center=true);
}

module starburst(){
    union(){
        // Dominant long bar (X direction)
        spoke(37.7, 6.0);

        // Shorter spokes at various angles
        rotate([0,0,90])  spoke(40.0, 5.0);
        rotate([0,0,30])  spoke(28.0, 4.5);
        rotate([0,0,-30]) spoke(28.0, 4.5);
        rotate([0,0,60])  spoke(24.0, 4.0);
        rotate([0,0,-60]) spoke(24.0, 4.0);
        rotate([0,0,15])  spoke(20.0, 3.8);
        rotate([0,0,-15]) spoke(20.0, 3.8);

        // Central hub
        cylinder(h=th, r=6.5, center=true);
    }
}

starburst();