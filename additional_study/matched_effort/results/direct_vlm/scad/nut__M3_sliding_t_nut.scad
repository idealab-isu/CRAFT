$fn = 96;

// T-slot nut for 3.0mm screws
// Key dimensions to match:
// - 6.0mm across flats (hex boss)
// - 3.0mm thick overall
// - through clearance hole for 3.0mm screw

across_flats = 6.0;
thickness    = 3.0;

screw_d    = 3.0;
clearance  = 0.4;
hole_d     = screw_d + clearance;

// Generic T-slot nut proportions (parametric, connected, verifiable)
nut_len = 10.0;  // along slot
nut_w   = 6.0;   // across slot (kept compact; hex boss defines 6mm AF feature)

boss_h  = 1.2;                 // hex boss height
base_h  = thickness - boss_h;  // base height

eps = 0.05;

module hex_prism_af(af, h){
    R = af / (2 * cos(30));
    linear_extrude(height=h, center=true)
        polygon(points=[for(i=[0:5]) [R*cos(60*i), R*sin(60*i)]]);
}

difference() {
    union() {
        // Base body (centered)
        cube([nut_len, nut_w, base_h], center=true);

        // Hex anti-rotation boss on top, connected with slight overlap
        translate([0, 0, base_h/2 + boss_h/2 - eps])
            hex_prism_af(across_flats, boss_h);
    }

    // Through hole (centered) for 3.0mm screw clearance
    cylinder(d=hole_d, h=thickness + 2*eps, center=true);
}