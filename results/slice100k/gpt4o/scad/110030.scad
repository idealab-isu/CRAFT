module t_shaped_fastener() {
    // Parameters
    shank_length = 18.9;
    shank_diameter = 3.0;
    flare_diameter = 4.0;
    flare_height = 1.0;
    body_diameter = 8.8;
    body_length = 11.0;
    fork_width = 1.5;
    fork_gap = 1.0;
    fork_length = 3.0;
    boss_diameter = 5.0;
    boss_height = 1.0;
    tab_width = 4.0;
    tab_height = 1.0;
    tab_length = 5.0;
    
    // Shank with flared end
    difference() {
        union() {
            cylinder(h = shank_length, d = shank_diameter, $fn = 64);
            translate([0, 0, shank_length - flare_height])
                cylinder(h = flare_height, d1 = shank_diameter, d2 = flare_diameter, $fn = 64);
        }
        translate([0, 0, shank_length - fork_length])
            cube([shank_diameter, fork_gap, fork_length], center = true);
    }
    
    // Transverse body with fork
    translate([0, 0, shank_length / 2])
    union() {
        cylinder(h = body_length, d = body_diameter, $fn = 64);
        translate([0, 0, body_length / 2])
            difference() {
                cube([body_diameter, fork_width, fork_length], center = true);
                translate([0, 0, fork_length / 2])
                    cube([body_diameter, fork_gap, fork_length], center = true);
            }
    }
    
    // Boss at intersection
    translate([0, 0, shank_length / 2])
        cylinder(h = boss_height, d = boss_diameter, $fn = 64);
    
    // Wedge-like tab
    translate([body_diameter / 2, 0, shank_length / 2])
        cube([tab_length, tab_width, tab_height], center = true);
}

t_shaped_fastener();