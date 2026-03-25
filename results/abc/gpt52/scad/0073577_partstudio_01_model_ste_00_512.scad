$fn=64;

eps = 0.01;

// Bounding box target: 0.1 x 0.0 x 0.1 mm (use 0.1 x 0.02 x 0.1 mm to avoid zero thickness)
L = 0.10;   // length (elongated axis)
W = 0.02;   // width (non-zero)
T = 0.01;   // thickness
H = 0.10;   // upright height

module diamond_hole(size=0.006, thickness=0.2) {
    rotate([0,0,45]) cube([size, size, thickness], center=true);
}

module slot_hole(len=0.030, wid=0.006, thickness=0.2) {
    hull() {
        translate([-len/2 + wid/2, 0, 0]) cylinder(h=thickness, r=wid/2, center=true);
        translate([ len/2 - wid/2, 0, 0]) cylinder(h=thickness, r=wid/2, center=true);
    }
}

module base_plate() {
    cube([L, W, T], center=true);
}

module upright_plate() {
    translate([L/2 - T/2, 0, H/2 - T/2])
        cube([T, W, H], center=true);
}

module gusset() {
    // Triangular gusset in X-Z plane, extruded along Y
    translate([L/2 - T, 0, T/2])
        rotate([90,0,0])
            linear_extrude(height=W, center=true)
                polygon(points=[
                    [0, 0],
                    [0, H - T],
                    [-(L*0.35), 0]
                ]);
}

module tabs_steps() {
    // Small tabs/steps along edges
    tab_t = T;
    tab_w = W*0.6;
    tab_l = L*0.10;

    // Two tabs on base top surface near ends
    translate([-L/2 + tab_l/2, 0, T/2 + tab_t/2])
        cube([tab_l, tab_w, tab_t], center=true);
    translate([ L/2 - tab_l*1.6, 0, T/2 + tab_t/2])
        cube([tab_l*0.8, tab_w, tab_t], center=true);

    // Small step on upright outer face
    translate([L/2 + tab_t/2, 0, H*0.65])
        cube([tab_t, tab_w, H*0.12], center=true);
}

module base_holes() {
    // Diamond holes pattern on base
    for (x = [-L*0.30, -L*0.10, L*0.10, L*0.30])
        for (y = [-W*0.20, W*0.20])
            translate([x, y, 0])
                diamond_hole(size=0.006, thickness=0.3);

    // Rectangular slot on base
    translate([0, 0, 0])
        slot_hole(len=L*0.45, wid=0.006, thickness=0.3);
}

module upright_holes() {
    // Diamond holes pattern on upright (in X-Z plane, through X)
    for (z = [H*0.25, H*0.45, H*0.65, H*0.85])
        for (y = [-W*0.20, W*0.20])
            translate([L/2 - T/2, y, z - T/2])
                rotate([0,90,0])
                    diamond_hole(size=0.006, thickness=0.3);

    // Rectangular slot on upright (vertical slot), through X
    translate([L/2 - T/2, 0, H*0.55 - T/2])
        rotate([0,90,0])
            slot_hole(len=H*0.40, wid=0.006, thickness=0.3);
}

difference() {
    union() {
        base_plate();
        upright_plate();
        gusset();
        tabs_steps();
    }
    base_holes();
    upright_holes();
}