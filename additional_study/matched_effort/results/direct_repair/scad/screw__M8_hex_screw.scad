$fn = 96;

// Parameters (mm)
shaft_d = 8.0;
shaft_r = shaft_d/2;

head_flat_d = 15.0;     // across flats
head_h = 5.65;

shaft_len = 10.0;

// Derived: hex circumradius from across-flats
hex_R = head_flat_d / sqrt(3);

module hex_prism(h, R){
    linear_extrude(height=h)
        polygon(points=[
            [ R, 0],
            [ R/2,  R*sqrt(3)/2],
            [-R/2,  R*sqrt(3)/2],
            [-R, 0],
            [-R/2, -R*sqrt(3)/2],
            [ R/2, -R*sqrt(3)/2]
        ]);
}

union() {
    // Shaft (under head)
    cylinder(h=shaft_len, r=shaft_r);

    // Hex head on top of shaft
    translate([0,0,shaft_len])
        hex_prism(head_h, hex_R);
}