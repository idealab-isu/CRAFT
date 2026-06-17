$fn = 64;

module smd(size = [4.90, 3.90, 1.25]) {
    eps = 0.01;
    sx = max(size[0], eps);
    sy = max(size[1], eps);
    sz = max(size[2], eps);

    // Slightly chamfered rectangular body to ensure visible edges in renders
    chamfer = min(0.25, sx/6, sy/6, sz/4);

    hull() {
        translate([0, 0,  sz/2 - chamfer/2])
            cube([sx - 2*chamfer, sy - 2*chamfer, chamfer], center=true);
        translate([0, 0, -sz/2 + chamfer/2])
            cube([sx - 2*chamfer, sy - 2*chamfer, chamfer], center=true);
    }
}

smd([4.90, 3.90, 1.25]);