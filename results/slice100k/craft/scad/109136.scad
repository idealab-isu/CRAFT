// Flat hexagonal plate with central circular through-hole and a shallow boss/pad on one face.
// Bounding box target: 35.0 x 30.31 x 4.0 mm

$fn = 128; // ensure circular hole (not polygonal)

// Parameters
bbox_X = 35.0;
bbox_Y = 30.31;
bbox_Z = 4.0;

plate_thk = 3.2;
boss_thk  = bbox_Z - plate_thk;   // 0.8 to reach total 4.0
hole_d    = 6.0;
boss_d    = 14.0;

boss_face = 1; // 1 = boss on +Z face, 0 = boss on -Z face
overlap   = 0.2;

// Regular hex sized by flat-to-flat distance (across flats)
module hex2d(flat_to_flat_x, flat_to_flat_y) {
    // Use the smaller of the two to keep within both bbox limits
    f = min(flat_to_flat_x, flat_to_flat_y);
    // For a regular hex: flat-to-flat = sqrt(3) * R (circumradius)
    R = f / sqrt(3);
    polygon(points=[ for(i=[0:5]) [ R*cos(60*i), R*sin(60*i) ] ]);
}

module plate_body() {
    linear_extrude(height=plate_thk, center=true)
        hex2d(bbox_X, bbox_Y);
}

module boss_pad() {
    zc = (boss_face==1)
        ? (plate_thk/2 + boss_thk/2 - overlap)
        : (-plate_thk/2 - boss_thk/2 + overlap);

    translate([0,0,zc])
        cylinder(d=boss_d, h=boss_thk, center=true);
}

module through_hole() {
    cylinder(d=hole_d, h=bbox_Z + 4*overlap, center=true);
}

difference() {
    union() {
        plate_body();
        boss_pad(); // connected via overlap
    }
    through_hole();
}