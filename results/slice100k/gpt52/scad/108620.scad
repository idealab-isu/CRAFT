$fn=128;

module flange_boss_part(d_flange=8.6, t_flange=2.0, d_boss=5.0, h_boss=4.2) {
    union() {
        translate([0,0,-(t_flange + h_boss)/2])
            cylinder(d=d_flange, h=t_flange);
        translate([0,0,-(t_flange + h_boss)/2 + t_flange])
            cylinder(d=d_boss, h=h_boss);
    }
}

flange_boss_part();