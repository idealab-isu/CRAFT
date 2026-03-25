module spur_gear_with_hex_bore(teeth=12, radius=20, thickness=5, hex_size=10) {
    gear_teeth(teeth, radius, thickness);
    hex_bore(hex_size, thickness);
}

module gear_teeth(teeth, radius, thickness) {
    difference() {
        cylinder(r=radius, h=thickness, $fn=64);
        for (i = [0:teeth-1]) {
            rotate([0, 0, i * 360 / teeth])
            translate([radius, 0, 0])
            cube([radius / teeth, 2 * radius / teeth, thickness], center=true);
        }
    }
}

module hex_bore(size, thickness) {
    rotate([0, 0, 90])
    translate([0, 0, -thickness/2])
    linear_extrude(height=thickness)
    polygon(points=[
        [size/2, 0],
        [size/4, size * sqrt(3)/4],
        [-size/4, size * sqrt(3)/4],
        [-size/2, 0],
        [-size/4, -size * sqrt(3)/4],
        [size/4, -size * sqrt(3)/4]
    ]);
}

spur_gear_with_hex_bore();