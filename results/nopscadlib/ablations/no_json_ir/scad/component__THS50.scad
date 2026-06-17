$fn = 96;

module main_body() {
    body = [20, 20, 20];
    hole_r = 5;
    hole_h = body[2] + 2; // ensure it fully cuts through

    difference() {
        cube(body, center=true);

        // Centered through-hole (no arbitrary offset)
        cylinder(h=hole_h, r=hole_r, center=true);
    }
}

main_body();