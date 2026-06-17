$fn = 128;

bore_d = 10.0;
od_d   = 19.0;
len    = 55.0;

eps = 0.02;

// Orient the bearing axis along X so standard orthographic views show:
// Front/Back = side profile (length visible), Left/Right = annular end view.
rotate([0, 90, 0])
difference() {
    cylinder(d = od_d, h = len, center = true);
    cylinder(d = bore_d, h = len + 2*eps, center = true);
}