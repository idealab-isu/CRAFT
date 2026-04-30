$fn = 64;

module gearbox() {
    cylinder(d = 37, h = 24.5, center = true);
}

module motor() {
    cylinder(d = 35.6, h = 32, center = true);
}

module shaft() {
    cylinder(d = 6, h = 14.7, center = true);
}

translate([0, 0, -24.5/2])
gearbox();

translate([0, 0, 24.5/2 + 32/2])
motor();

translate([0, 0, 24.5/2 + 32 + 14.7/2])
shaft();