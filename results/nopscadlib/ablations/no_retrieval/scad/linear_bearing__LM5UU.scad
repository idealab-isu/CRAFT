// Linear bearing: 5.0mm bore (ID), 10.0mm outer diameter (OD), 15.0mm length
// One connected solid with a visible through-bore.

$fn = 192;

// Parameters (mm)
bore_d  = 5.0;
outer_d = 10.0;
length  = 15.0;

// Small overlap to ensure clean boolean operations
overlap = 0.5;

module linear_bearing(id_d, od_d, len) {
    difference() {
        // Outer body (OD x length)
        cylinder(d=od_d, h=len, center=true);

        // Through-bore (ID), extended slightly beyond ends to guarantee cut-through
        cylinder(d=id_d, h=len + 2*overlap, center=true);
    }
}

linear_bearing(bore_d, outer_d, length);