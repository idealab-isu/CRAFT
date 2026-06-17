// Permanent magnet: 8.0mm diameter, 4.2mm tall

outer_diameter_mm = 8.0;  //[4.0:16.0:0.1]
height_mm         = 4.2;  //[2.1:8.4:0.1]

$fn = 128;

module magnet(d=outer_diameter_mm, h=height_mm) {
    // Ensure valid, visible geometry
    d2 = max(d, 0.01);
    h2 = max(h, 0.01);

    color([0.72, 0.45, 0.2])
        cylinder(d=d2, h=h2, center=true);
}

magnet();