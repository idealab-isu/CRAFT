$fn=64;

plate_x = 0.1;
plate_y = 0.02;
plate_z = 0.1;

boss_h = 0.01;
boss_x = 0.012;
boss_y = 0.008;

module boss(px, pz, sx=boss_x, sy=boss_y, h=boss_h){
    translate([px, plate_y/2 + h/2, pz])
        cube([sx, h, sy], center=true);
}

module plate(){
    cube([plate_x, plate_y, plate_z], center=true);
}

union(){
    plate();
    boss(-0.032, -0.028, sx=0.014, sy=0.008, h=0.010);
    boss( 0.018, -0.010, sx=0.010, sy=0.010, h=0.010);
    boss(-0.006,  0.026, sx=0.012, sy=0.007, h=0.010);
    boss( 0.034,  0.018, sx=0.009, sy=0.012, h=0.010);
}