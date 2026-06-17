module hex_bore(diameter, length) {
    rotate([0, 0, 90])
    translate([-length/2, 0, 0])
    cylinder(d=diameter, h=length, $fn=6);
}

module faceted_cylinder(diameter, length, facets) {
    for (i = [0:facets-1]) {
        rotate([0, 0, i * 360 / facets])
        translate([0, 0, -length/2])
        cylinder(d1=diameter, d2=diameter * 0.95, h=length, $fn=3);
    }
}

module handle() {
    difference() {
        union() {
            translate([0, 0, -50])
            faceted_cylinder(30, 100, 12);
            translate([0, 0, 50])
            scale([1, 1, 0.2])
            sphere(d=30, $fn=64);
            translate([0, 0, -50])
            cylinder(d1=20, d2=30, h=10, $fn=64);
        }
        hex_bore(10, 100);
    }
}

handle();