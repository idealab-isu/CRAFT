$fn=96;

module ht40_cap(od=40, wall=2.2, height=35, top_thickness=3.0, lip=2.0, chamfer=1.2) {
    outer_r = od/2;
    inner_r = outer_r - wall;
    inner_depth = height - top_thickness;

    difference() {
        union() {
            cylinder(h=height, r=outer_r);
            translate([0,0,height-lip])
                cylinder(h=lip, r=outer_r + 0.8);
        }

        translate([0,0,top_thickness])
            cylinder(h=inner_depth + 0.2, r=inner_r);

        translate([0,0,top_thickness-0.01])
            cylinder(h=chamfer+0.02, r1=inner_r-0.8, r2=inner_r);

        translate([0,0,-0.1])
            cylinder(h=top_thickness+0.2, r=inner_r-1.0);
    }
}

translate([0,0,-35/2])
    ht40_cap();