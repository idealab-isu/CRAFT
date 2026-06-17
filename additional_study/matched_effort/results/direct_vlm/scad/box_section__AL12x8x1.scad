$fn = 64;

// Aluminium rectangular box section: 12mm x 8mm x 1mm wall
outer_w = 12;   // X (mm)
outer_h = 8;    // Y (mm)
wall    = 1;    // (mm)
length  = 50;   // Z (mm)

inner_w = outer_w - 2*wall;
inner_h = outer_h - 2*wall;

assert(inner_w > 0 && inner_h > 0, "Wall thickness too large for given outer dimensions.");

eps = 0.02; // small overlap to ensure clean boolean

difference() {
    // Centered outer solid for robust viewing/orientation
    cube([outer_w, outer_h, length], center=true);

    // Inner void: same center, slightly longer to guarantee through-cut
    cube([inner_w, inner_h, length + 2*eps], center=true);
}