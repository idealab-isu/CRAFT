$fn = 96;

module main_body() {
    body = [20, 20, 20];
    hole_r = 5;
    eps = 0.2;

    difference() {
        cube(body, center=true);

        // Center the hole through the cube (no arbitrary offsets)
        cylinder(h=body[2] + 2*eps, r=hole_r, center=true);
    }
}

main_body();