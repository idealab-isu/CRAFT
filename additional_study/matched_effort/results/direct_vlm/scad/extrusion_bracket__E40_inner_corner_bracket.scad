$fn = 64;

size = [38, 31, 8.5];   // [X, Y, Z] overall
corner_r = 2.0;

hole_d = 5.2;
hole_offset = 9.0;

module rounded_plate(sz=[38,31,8.5], r=2){
    x = sz[0]; y = sz[1]; z = sz[2];
    linear_extrude(height=z)
        offset(r=r)
            square([x-2*r, y-2*r], center=true);
}

difference() {
    rounded_plate(size, corner_r);

    // Two mounting holes along X axis
    for (sx = [-1, 1]) {
        translate([sx*(size[0]/2 - hole_offset), 0, -0.5])
            cylinder(h=size[2]+1, d=hole_d);
    }
}