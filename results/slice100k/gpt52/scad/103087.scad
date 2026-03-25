$fn=96;

L = 55.0;
W = 16.6;
H = 20.1;

end_relief_len = 6.0;
end_chamfer = 2.2;

hex_flat = 8.0;
hex_r = hex_flat / sqrt(3);

cs_depth = 2.0;
cs_extra_flat = 4.0;
cs_flat = hex_flat + cs_extra_flat;
cs_r = cs_flat / sqrt(3);

hole_x = 0;

module bar_body() {
    difference() {
        cube([L, W, H], center=true);

        for (sx = [-1, 1]) {
            translate([sx*(L/2 - end_relief_len/2), 0, 0])
                cube([end_relief_len, W + 0.6, H + 0.6], center=true);

            translate([sx*(L/2 - end_chamfer/2), 0, 0])
                rotate([0, 45, 0])
                    cube([end_chamfer*2, W + 0.8, H + 0.8], center=true);
        }
    }
}

module hex_through_with_v_countersink() {
    union() {
        translate([hole_x, 0, 0])
            rotate([90, 0, 0])
                cylinder(h=W + 1.0, r=hex_r, center=true, $fn=6);

        for (sy = [-1, 1]) {
            translate([hole_x, sy*(W/2 - cs_depth/2), 0])
                rotate([90, 0, 0])
                    cylinder(h=cs_depth, r1=cs_r, r2=hex_r, center=true, $fn=6);
        }
    }
}

difference() {
    bar_body();
    hex_through_with_v_countersink();
}