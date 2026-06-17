module radial_encoder_magnet() {
    difference() {
        cylinder(h=5, r=10, $fn=64);
        cylinder(h=5, r=5, $fn=64);
    }
}

radial_encoder_magnet();