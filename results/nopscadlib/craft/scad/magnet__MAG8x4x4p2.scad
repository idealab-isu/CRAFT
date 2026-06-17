// Permanent magnet: 8.0mm diameter, 4.2mm tall

outer_diameter_mm = 8.0;   // [4.0:16.0:0.1]
height_mm         = 4.2;   // [2.1:8.4:0.1]

outer_radius_mm = outer_diameter_mm / 2;

$fn = 128;

module magnet(d=outer_diameter_mm, h=height_mm) {
    assert(d > 0);
    assert(h > 0);

    color([0.72, 0.45, 0.2])
        cylinder(d=d, h=h, center=true);
}

magnet();