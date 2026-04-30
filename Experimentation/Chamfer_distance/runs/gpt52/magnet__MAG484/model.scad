$fn = 96;

module ring_magnet(od=6.35, id=3.175, h=6.35, r=0.5) {
    r_eff = min(r, (od-id)/4, h/2);
    ro = od/2;
    ri = id/2;

    difference() {
        // Outer rounded cylinder
        minkowski() {
            cylinder(h = h - 2*r_eff, r = ro - r_eff, center = true);
            sphere(r = r_eff);
        }
        // Inner hole
        cylinder(h = h + 4*r_eff, r = ri, center = true);
    }
}

ring_magnet();