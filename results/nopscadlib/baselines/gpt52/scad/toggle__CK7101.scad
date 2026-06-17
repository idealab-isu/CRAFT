$fn=64;

body_d = 6.86;
body_r = body_d/2;
body_h = 12.7;

bushing_d = 7.6;
bushing_h = 2.0;

lever_d = 2.2;
lever_h = 10.0;

tip_d = 3.2;
tip_h = 2.0;

base_plate_w = 12.0;
base_plate_d = 10.0;
base_plate_h = 1.6;

module toggle_switch() {
    union() {
        translate([0,0,body_h/2])
            cylinder(d=body_d, h=body_h, center=true);

        translate([0,0,body_h + bushing_h/2])
            cylinder(d=bushing_d, h=bushing_h, center=true);

        translate([0,0,body_h + bushing_h + lever_h/2])
            rotate([12,0,0])
                cylinder(d=lever_d, h=lever_h, center=true);

        translate([0,0,body_h + bushing_h + lever_h])
            rotate([12,0,0])
                translate([0,0,tip_h/2])
                    cylinder(d=tip_d, h=tip_h, center=true);

        translate([0,0,-base_plate_h/2])
            cube([base_plate_w, base_plate_d, base_plate_h], center=true);

        for (x = [-3.0, 0, 3.0]) {
            translate([x, -base_plate_d/2 - 1.5, -4.0])
                cylinder(d=1.2, h=6.0, center=true);
        }
    }
}

toggle_switch();