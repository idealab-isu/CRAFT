cube([68.58, 53.34, 1.6], center = true);

module mounting_hole() {
    cylinder(h = 5, d = 3.3, $fn = 64);
}

translate([-34.29, -26.67, 0])
    mounting_hole();

translate([34.29, -26.67, 0])
    mounting_hole();

translate([-34.29, 26.67, 0])
    mounting_hole();

translate([34.29, 26.67, 0])
    mounting_hole();