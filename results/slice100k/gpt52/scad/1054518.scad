$fn=96;

bbox_x = 10.1;
bbox_y = 10.2;
bbox_z = 8.0;

flange_d = 10.1;
flange_h = 3.0;

boss_d = 7.0;
boss_h = bbox_z - flange_h;

bore_d = 4.0;

flat_depth = 2.2;
flat_width = 6.0;

module stepped_bushing() {
    difference() {
        union() {
            translate([0,0,-bbox_z/2])
                cylinder(d=flange_d, h=flange_h);
            translate([0,0,-bbox_z/2 + flange_h])
                cylinder(d=boss_d, h=boss_h);
        }

        translate([0,0,-bbox_z/2 - 0.2])
            cylinder(d=bore_d, h=bbox_z + 0.4);

        translate([boss_d/2 - flat_depth, 0, -bbox_z/2 + flange_h - 0.2])
            cube([flat_depth + 0.6, flat_width, boss_h + 0.4], center=true);
    }
}

stepped_bushing();