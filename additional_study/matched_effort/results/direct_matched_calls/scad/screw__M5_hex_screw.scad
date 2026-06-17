$fn = 96;

// Dimensions (mm)
shaft_d = 5.0;
shaft_r = shaft_d/2;

head_flat_d = 9.2;          // across flats
head_h = 3.65;

length_under_head = 10.0;   // shaft length (under head)

// Derived: hex circumradius from across-flats
hex_R = head_flat_d / sqrt(3);

union() {
    // Shaft (under head)
    translate([0,0,-length_under_head])
        cylinder(h=length_under_head, r=shaft_r);

    // Hex head
    cylinder(h=head_h, r=hex_R, $fn=6);
}