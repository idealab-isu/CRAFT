$fn=96;

bbox_x = 11.0;
bbox_y = 18.9;
bbox_z = 8.8;

shank_r = 2.0;
shank_len = 18.9;
flare_len = 2.2;
flare_r2 = 2.6;

cross_r = 2.2;
cross_len = 11.0;

boss_r = 3.0;
boss_t = 1.6;

tab_len = 4.6;
tab_w = 3.6;
tab_t = 1.4;
tab_wedge = 0.9;

fork_len = 3.2;
fork_gap = 1.2;
fork_prong_min = 0.9;
fork_prong_max = 1.6;

module shank_with_flare() {
    union() {
        translate([0, -shank_len/2 + flare_len/2, 0])
            cylinder(h=shank_len - flare_len, r=shank_r, center=true);
        translate([0, shank_len/2 - flare_len/2, 0])
            cylinder(h=flare_len, r1=shank_r, r2=flare_r2, center=true);
    }
}

module cross_body() {
    cylinder(h=cross_len, r=cross_r, center=true);
}

module boss() {
    cylinder(h=boss_t, r=boss_r, center=true);
}

module wedge_tab() {
    translate([boss_r + tab_len/2 - 0.2, 0, 0])
        rotate([0, 90, 0])
            linear_extrude(height=tab_len, center=true, convexity=10)
                polygon(points=[
                    [-tab_w/2, -tab_t/2],
                    [ tab_w/2, -tab_t/2],
                    [ tab_w/2,  tab_t/2],
                    [-tab_w/2,  tab_t/2 - tab_wedge]
                ]);
}

module fork_end() {
    difference() {
        translate([0, 0, cross_len/2 - fork_len/2])
            cylinder(h=fork_len, r=cross_r, center=true);
        translate([0, 0, cross_len/2 - fork_len/2])
            cube([fork_gap, 2*cross_r + 0.6, fork_len + 0.4], center=true);
        translate([0, 0, cross_len/2 - fork_len/2])
            rotate([0, 0, 90])
                cylinder(h=fork_len + 0.6, r=fork_gap/2, center=true);
    }
    translate([0, 0, cross_len/2 - fork_len/2])
        intersection() {
            cylinder(h=fork_len, r=cross_r, center=true);
            union() {
                translate([ (fork_gap/2 + fork_prong_min/2), 0, 0])
                    cube([fork_prong_min, 2*cross_r + 0.2, fork_len], center=true);
                translate([-(fork_gap/2 + fork_prong_min/2), 0, 0])
                    cube([fork_prong_min, 2*cross_r + 0.2, fork_len], center=true);
            }
        }
    translate([0, 0, cross_len/2 - fork_len/2])
        intersection() {
            cylinder(h=fork_len, r=cross_r, center=true);
            union() {
                translate([ (fork_gap/2 + fork_prong_max/2), 0, 0])
                    cube([fork_prong_max, 2*cross_r + 0.2, fork_len*0.55], center=true);
                translate([-(fork_gap/2 + fork_prong_max/2), 0, 0])
                    cube([fork_prong_max, 2*cross_r + 0.2, fork_len*0.55], center=true);
            }
        }
}

module fastener() {
    union() {
        shank_with_flare();
        rotate([90, 0, 0]) cross_body();
        rotate([90, 0, 0]) fork_end();
        boss();
        wedge_tab();
    }
}

scale([
    bbox_x / (2*boss_r + tab_len + 0.6),
    bbox_y / shank_len,
    bbox_z / (2*max(boss_r, cross_r) + 0.4)
]) fastener();