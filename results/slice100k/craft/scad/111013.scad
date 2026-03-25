// Symmetric prismatic connector/block
// Bounding box: 14.0 x 9.0 x 3.6 mm  (X x Y x Z)

L = 14.0;
W = 9.0;
T = 3.6;

// End masses and central web (H-profile in front/back)
end_L = 4.5;                 // length of each end mass along X
web_L = L - 2*end_L;          // central span along X
web_W = 3.6;                  // web width along Y

// Midspan relief notches on top and bottom edges (in Y), through full thickness (Z)
notch_L = 5.0;                // notch length along X
notch_W = 2.0;                // notch depth from edge along Y

eps = 0.02;                   // small overlap to avoid coplanar artifacts

module main_prismatic_body() {
    union() {
        // Central web
        cube([web_L, web_W, T], center=true);

        // End masses (connected to web with slight overlap)
        translate([-(web_L/2 + end_L/2 - eps), 0, 0])
            cube([end_L, W, T], center=true);

        translate([(web_L/2 + end_L/2 - eps), 0, 0])
            cube([end_L, W, T], center=true);
    }
}

module relief_notches() {
    // Cut rectangular notches from the top and bottom edges in Y,
    // through the full thickness in Z to match the H-profile views.
    union() {
        // Top edge notch (+Y)
        translate([0, (W/2 - notch_W/2), 0])
            cube([notch_L, notch_W + 2*eps, T + 2*eps], center=true);

        // Bottom edge notch (-Y)
        translate([0, -(W/2 - notch_W/2), 0])
            cube([notch_L, notch_W + 2*eps, T + 2*eps], center=true);
    }
}

difference() {
    main_prismatic_body();
    relief_notches();
}