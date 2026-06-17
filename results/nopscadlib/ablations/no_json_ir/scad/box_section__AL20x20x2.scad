// Aluminium rectangular box section: 20mm x 20mm x 2mm wall

outer_size = 20;        // mm
wall_thickness = 2;     // mm
length = 100;           // mm

eps = 0.02;             // small overlap to avoid coplanar faces

module box_section_20x20x2(L=length, OD=outer_size, t=wall_thickness) {
    ID = OD - 2*t;
    assert(ID > 0, "Wall thickness too large for given outer size.");

    // Centered for predictable viewing/orientation
    difference() {
        cube([OD, OD, L], center=true);
        cube([ID, ID, L + 2*eps], center=true);
    }
}

box_section_20x20x2();