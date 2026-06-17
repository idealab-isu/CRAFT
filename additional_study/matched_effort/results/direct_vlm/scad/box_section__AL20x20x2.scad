$fn = 64;

// Aluminium rectangular box section: 20mm x 20mm x 2mm wall
outer_w = 20;
outer_h = 20;
wall    = 2;
length  = 100; // mm

inner_w = outer_w - 2*wall;
inner_h = outer_h - 2*wall;

eps = 0.05; // small extra to ensure clean boolean cut

// Guard against invalid dimensions
assert(inner_w > 0 && inner_h > 0, "Wall thickness too large for given outer dimensions.");

difference() {
    // Outer tube
    cube([outer_w, outer_h, length], center=true);

    // Inner void (open ends), extended along length to guarantee through-cut
    cube([inner_w, inner_h, length + 2*eps], center=true);
}