// Axial part target dimensions: [3.4, 1.75, 0.3]
// Interpreted as: body length (axial) = 3.4, body diameter = 1.75, lead diameter = 0.3

$fn = 96;

L = 3.4;        // axial length
D = 1.75;       // body diameter
lead_d = 0.3;   // lead diameter

eps = 0.02;

module axial_part() {
    union() {
        // Main cylindrical body (axial component)
        cylinder(h=L, r=D/2, center=true);

        // Leads (extend slightly beyond body; connected with small overlap)
        translate([0, 0, 0])
            cylinder(h=L + 2*eps, r=lead_d/2, center=true);
    }
}

color("Silver") axial_part();