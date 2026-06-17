// Generic Component Model (fixed: non-empty, one connected solid)

$fn = 64;

module main_body() {
    body = [20, 20, 20];
    hole_r = 5;
    hole_h = body[2] + 2; // ensure through-hole without removing entire body

    difference() {
        cube(body, center=true);

        // Centered through-hole along Z
        cylinder(h=hole_h, r=hole_r, center=true);
    }
}

main_body();