module lug() {
    cube([3, 6.3, 6.3], center=true);
}

module disk_with_lugs() {
    cylinder(h=6.3, d=16.8, center=true, $fn=64);
    for (angle = [0, 90, 180, 270]) {
        rotate([0, 0, angle])
        translate([8.4, 0, 0])
        lug();
    }
}

disk_with_lugs();