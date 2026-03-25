module starburst_gear(radius, teeth, thickness) {
    difference() {
        cylinder(r=radius, h=thickness, $fn=64);
        for (i = [0:360/teeth:360-360/teeth]) {
            rotate([0, 0, i])
            translate([radius, 0, 0])
            rotate([0, 0, -90])
            polygon(points=[[0, 0], [-radius/teeth, -radius/2], [radius/teeth, -radius/2]]);
        }
    }
}

translate([0, 0, -0.05])
starburst_gear(0.05, 20, 0.1);