translate([-20, -20, 0])
difference() {
    // Base plate
    cube([40, 40, 3], center = false);
    
    // Corner holes
    for (x = [0, 40])
        for (y = [0, 40])
            translate([x, y, 0])
                cylinder(h = 3, r = 2, $fn = 64);
}