module spool() {
    cylinder(h=6.6, d=6.6, $fn=64);
    translate([-5.85, 0, 3.3])
        cube([11.7, 6.6, 1.7], center=true);
}

spool();