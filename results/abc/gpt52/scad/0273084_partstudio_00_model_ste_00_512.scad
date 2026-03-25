$fn=64;

bbox = [0.1, 0.1, 0.1];

len = 0.1;
boss_big_d = 0.06;
boss_small_d = 0.045;

boss_big_t = 0.06;
boss_small_t = 0.035;

bar_w = 0.02;
bar_t = 0.02;

offset_z = (boss_big_t - boss_small_t);

hex_flat = 0.02;
hex_r = hex_flat / sqrt(3);

module hex_hole(h, r){
    cylinder(h=h, r=r, $fn=6);
}

module boss(d, t, hex_r){
    difference(){
        cylinder(h=t, d=d);
        translate([0,0,-0.01]) hex_hole(t+0.02, hex_r);
    }
}

module bar_between(x0, x1, w, t, z0, z1){
    hull(){
        translate([x0,0,z0]) cube([0.001, w, t], center=true);
        translate([x1,0,z1]) cube([0.001, w, t], center=true);
    }
}

module offset_link(){
    x_big = -len/2 + boss_big_d/2;
    x_small =  len/2 - boss_small_d/2;

    z_big = 0;
    z_small = -offset_z;

    union(){
        translate([x_big,0,z_big]) boss(boss_big_d, boss_big_t, hex_r);
        translate([x_small,0,z_small]) boss(boss_small_d, boss_small_t, hex_r);

        bar_between(x_big, x_small, bar_w, bar_t, boss_big_t/2, z_small + boss_small_t/2);
    }
}

scale_f = [
    bbox[0]/len,
    bbox[1]/max(boss_big_d, bar_w),
    bbox[2]/max(boss_big_t, boss_small_t + abs(offset_z))
];

scale(scale_f)
translate([0,0,-(boss_big_t/2 + (-offset_z + boss_small_t/2))/2])
offset_link();