$fn = 48;

// Parameters
length = 200;          // Length of the sponge
width = 100;           // Width of the sponge
thickness = 10;        // Thickness of the sponge
corner_radius = 5;     // Corner rounding radius
edge_radius = 2;       // Edge rounding radius (kept <= corner_radius)
pore_diameter = 1;     // Diameter of surface texture pores
pore_spacing = 5;      // Spacing between pores
pore_depth = 0.8;      // Depth of pores (shallow so sheet remains solid)

// Safety clamps
edge_r = min(edge_radius, corner_radius, thickness/2 - 0.01);
corner_r = min(corner_radius, min(length, width)/2 - 0.01, thickness/2 - 0.01);
pore_r = pore_diameter/2;
pore_h = min(pore_depth, thickness/2 - 0.01);

// Rounded rectangular prism via Minkowski (robust, always visible)
module rounded_sheet(L, W, T, r) {
    minkowski() {
        cube([L - 2*r, W - 2*r, T - 2*r], center=true);
        sphere(r=r);
    }
}

// Surface pores: shallow dimples from the top face only
module surface_pores() {
    z_top = thickness/2;
    z_center = z_top - pore_h/2; // ensures pores cut into top surface only

    for (x = [-length/2 + pore_spacing/2 : pore_spacing : length/2 - pore_spacing/2])
        for (y = [-width/2 + pore_spacing/2 : pore_spacing : width/2 - pore_spacing/2])
            translate([x, y, z_center])
                cylinder(h=pore_h, r=pore_r, center=true);
}

// Final model: one connected solid
difference() {
    rounded_sheet(length, width, thickness, corner_r);
    surface_pores();
}