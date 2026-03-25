$fn=64;

plate_len = 0.5;
plate_wid = 0.4;
plate_thk = 0.05;

boss_len = 0.18;
boss_wid = 0.14;
boss_thk = 0.03;

module plate(l,w,t){
    translate([-l/2, -w/2, -t/2])
        cube([l,w,t], center=false);
}

module boss(l,w,t,base_t){
    translate([-l/2, -w/2, base_t/2])
        cube([l,w,t], center=false);
}

union(){
    plate(plate_len, plate_wid, plate_thk);
    boss(boss_len, boss_wid, boss_thk, plate_thk/2);
}