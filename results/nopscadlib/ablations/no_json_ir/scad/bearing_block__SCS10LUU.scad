$fn = 96;

module bearing_block_long_8mm(
    w = 40.0,          // X overall
    l = 68.0,          // Y overall
    h = 20.0,          // Z overall
    shaft_d = 8.0,

    // housing geometry (SCS/SBR-like)
    bore_housing_d = 18.0,   // outer cylindrical boss around bore
    bore_housing_z = 14.0,   // height of boss (<= h)

    // mounting (4 holes)
    mount_d = 4.0,
    mount_x = 15.0,
    mount_y = 25.0,
    counterbore_d = 8.0,
    counterbore_h = 5.0,

    // clamp slit (cut from top down, leaves bottom connected)
    slit_w = 2.0,      // slit thickness in Y
    slit_z = 2.0,      // remaining material at bottom (keeps body connected)

    // top clamp ears (adds typical block silhouette)
    ear_w = 40.0,      // X width of ears (match body)
    ear_l = 10.0,      // Y length of each ear
    ear_h = 6.0,       // Z height of ears
    ear_gap = 3.0      // Y gap between ears (centered)
) {
    eps = 0.02;

    // Derived / clamped values
    boss_h = min(bore_housing_z, h);
    boss_r = bore_housing_d/2;

    // Ensure ears fit within length
    ear_total = 2*ear_l + ear_gap;
    ear_l_eff = (ear_total <= l) ? ear_l : max(0, (l - ear_gap)/2);

    difference() {
        union() {
            // Main body (exact overall size 40 x 68 x h)
            cube([w, l, h], center=true);

            // Cylindrical bearing housing boss along Y (typical long block feature)
            rotate([90, 0, 0])
                cylinder(h = l, d = bore_housing_d, center=true);

            // Top clamp ears (two pads separated by a gap, connected to body)
            if (ear_l_eff > 0) {
                for (sy = [-1, 1]) {
                    translate([0,
                               sy*(ear_gap/2 + ear_l_eff/2),
                               h/2 + ear_h/2 - 0.5])  // slight overlap into body
                        cube([ear_w, ear_l_eff, ear_h], center=true);
                }
            }
        }

        // 8mm shaft bore along Y (through)
        rotate([90, 0, 0])
            cylinder(h = l + 2*eps, d = shaft_d, center=true);

        // Flatten boss top/bottom so it doesn't exceed overall height h
        // (keeps overall Z within [-h/2, +h/2])
        translate([0, 0,  h/2 + boss_r])
            cube([w + 2*boss_r + 2*eps, l + 2*eps, 2*boss_r + 2*eps], center=true);
        translate([0, 0, -h/2 - boss_r])
            cube([w + 2*boss_r + 2*eps, l + 2*eps, 2*boss_r + 2*eps], center=true);

        // 4x mounting through-holes along Z
        for (x = [-mount_x, mount_x])
            for (y = [-mount_y, mount_y])
                translate([x, y, 0])
                    cylinder(h = h + 2*eps, d = mount_d, center=true);

        // counterbores from top face only
        for (x = [-mount_x, mount_x])
            for (y = [-mount_y, mount_y])
                translate([x, y, h/2 - counterbore_h/2 + eps])
                    cylinder(h = counterbore_h + 2*eps, d = counterbore_d, center=true);

        // clamp slit: cut from top down, leave slit_z at bottom so model stays one connected solid
        translate([0, 0, (h/2 - slit_z)/2])
            cube([w + 2*eps, slit_w, h - slit_z + 2*eps], center=true);
    }
}

bearing_block_long_8mm();