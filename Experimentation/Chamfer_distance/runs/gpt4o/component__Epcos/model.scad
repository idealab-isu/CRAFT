translate([-2.3, -1.25, -1.25])
difference() {
    cube([4.6, 2.5, 2.5]);
    translate([2.3, 1.25, 1.25])
    rotate([90, 0, 0])
    cylinder(h=4.6, r=0.5, $fn=64);
}