// Symmetric prismatic connector/block
// Bounding box: 14.0 x 9.0 x 3.6 mm (X x Y x Z)

L = 14;      // overall length (X)
W = 9;       // overall width  (Y)
T = 3.6;     // thickness      (Z)

end_L = 4;   // length of each end mass along X
web_L = L - 2*end_L;   // central span along X
web_W = 5;   // width of central web along Y (creates H profile in front/back)

notch_L = 3;     // notch length along X (centered)
notch_D = 1;     // notch depth into Y from top/bottom edges
notch_Z = 0.8;   // shallow relief depth into thickness (Z), not full-depth

eps = 0.02;      // small overlap to avoid coincident faces

module end_mass(xsign=1) {
    translate([xsign*(L/2 - end_L/2), 0, 0])
        cube([end_L, W, T], center=true);
}

module web() {
    cube([web_L + 2*eps, web_W, T], center=true);
}

module notch_top() {
    translate([0,  W/2 - notch_D/2,  T/2 - notch_Z/2])
        cube([notch_L, notch_D + 2*eps, notch_Z + 2*eps], center=true);
}

module notch_bottom() {
    translate([0, -W/2 + notch_D/2, -T/2 + notch_Z/2])
        cube([notch_L, notch_D + 2*eps, notch_Z + 2*eps], center=true);
}

difference() {
    union() {
        end_mass(-1);
        end_mass( 1);
        web();
    }
    // shallow rectangular reliefs at midspan on top and bottom edges
    notch_top();
    notch_bottom();
}