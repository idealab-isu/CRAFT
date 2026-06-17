module t_shaped_fitting() {
    // Parameters
    stem_diameter = 3.0;
    stem_length = 18.9;
    barrel_diameter = 5.0;
    barrel_length = 11.0;
    flange_width = 8.8;
    flange_height = 2.0;
    prong_width = 2.0;
    prong_gap = 1.0;
    prong_length = 3.0;
    collar_diameter = 6.0;
    collar_height = 1.0;
    chamfer_size = 0.5;
    $fn = 64;

    // Stem
    translate([0, 0, -stem_length / 2])
    cylinder(h = stem_length, d = stem_diameter, center = true);

    // Barrel
    translate([0, 0, 0])
    rotate([90, 0, 0])
    cylinder(h = barrel_length, d = barrel_diameter, center = true);

    // Flange
    translate([-flange_width / 2, barrel_length / 2, -flange_height / 2])
    cube([flange_width, flange_height, barrel_diameter]);

    // Prongs
    translate([0, -barrel_length / 2, 0])
    rotate([90, 0, 0])
    difference() {
        union() {
            translate([-prong_width - prong_gap / 2, 0, 0])
            cube([prong_width, prong_length, barrel_diameter]);
            translate([prong_gap / 2, 0, 0])
            cube([prong_width, prong_length, barrel_diameter]);
        }
        translate([-barrel_diameter / 2, prong_length - chamfer_size, -barrel_diameter / 2])
        cube([barrel_diameter, chamfer_size, barrel_diameter]);
    }

    // Collar
    translate([0, 0, -collar_height / 2])
    rotate([90, 0, 0])
    cylinder(h = collar_height, d = collar_diameter, center = true);
}

t_shaped_fitting();