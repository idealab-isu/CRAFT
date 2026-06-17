$fn = 64;

size = [40, 40, 35];   // overall bounding box [X,Y,Z]
wall = 4;              // bracket wall thickness
rib  = 6;              // corner rib thickness
hole_d = 6.5;          // clearance hole diameter
csk_d  = 12;           // counterbore diameter
csk_h  = 4;            // counterbore depth
edge   = 10;           // hole offset from outer edges

module extrusion_bracket(sz=[40,40,35]) {
    x = sz[0];
    y = sz[1];
    z = sz[2];

    eps = 0.2;

    // L-bracket (angle bracket) within overall [x,y,z]:
    // Two perpendicular plates of thickness 'wall' plus a corner rib.
    difference() {
        union() {
            // Base plate: X by Y, thickness wall (at Z=0..wall)
            cube([x, y, wall], center=false);

            // Upright plate: thickness wall in X, spans Y and Z (at X=0..wall)
            cube([wall, y, z], center=false);

            // Corner rib (gusset) connecting base to upright along Y
            // Triangle in XZ plane: (0,0)->(rib,0)->(0,rib), extruded along Y
            linear_extrude(height=y, center=false, convexity=10)
                polygon(points=[[0,0],[rib,0],[0,rib]]);
        }

        // Through-hole in base plate (vertical, along Z), with counterbore from top of base
        // Keep hole fully inside base plate area.
        hx = x - edge;
        hy = y - edge;

        translate([hx, hy, -eps])
            cylinder(d=hole_d, h=wall + 2*eps, center=false);

        translate([hx, hy, wall - csk_h])
            cylinder(d=csk_d, h=csk_h + eps, center=false);

        // Through-hole in upright plate (horizontal, along X), with counterbore from outside face (X=wall side)
        // Place it centered in Z and offset from Y edge.
        hy2 = edge;
        hz2 = z/2;

        translate([-eps, hy2, hz2])
            rotate([0, 90, 0])
                cylinder(d=hole_d, h=wall + 2*eps, center=false);

        translate([wall - csk_h, hy2, hz2])
            rotate([0, 90, 0])
                cylinder(d=csk_d, h=csk_h + eps, center=false);
    }
}

extrusion_bracket(size);