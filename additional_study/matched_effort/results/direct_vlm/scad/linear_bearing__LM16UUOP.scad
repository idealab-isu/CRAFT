$fn = 180;

bore_d = 16.0;   // mm (ID)
od_d   = 28.0;   // mm (OD)
len    = 37.0;   // mm (overall length)

eps = 0.05;      // small overlap to avoid coplanar faces

difference() {
    // Outer body: exact OD and length, centered for easy verification
    cylinder(d = od_d, h = len, center = true);

    // Through bore: exact ID, extended slightly to guarantee a clean cut
    cylinder(d = bore_d, h = len + 2*eps, center = true);
}