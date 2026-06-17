// Permanent magnet: 8.0mm diameter, 4.2mm tall

magnet_diameter = 8.0; // mm
magnet_height   = 4.2; // mm

$fn = 128;

module magnet(d=magnet_diameter, h=magnet_height) {
    // Single connected solid with exact requested dimensions
    cylinder(d=d, h=h, center=false);
}

magnet();