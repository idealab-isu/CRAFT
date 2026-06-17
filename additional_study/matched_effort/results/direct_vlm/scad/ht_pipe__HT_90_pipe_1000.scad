$fn = 128;

// HT 90 pipe 1000 mm (interpreted as a 90° elbow with 1000 mm legs)
// Assumed: DN90, OD=90mm, wall=3.2mm
outer_d = 90;
wall = 3.2;
inner_d = outer_d - 2*wall;

leg_len = 1000;          // straight length of each leg from tangent point
bend_angle = 90;         // degrees
overlap = 0.5;           // small overlap to ensure watertight boolean

module hollow_cyl(h, od, id, center=false){
    difference(){
        cylinder(h=h, d=od, center=center);
        translate([0,0,-overlap])
            cylinder(h=h + 2*overlap, d=id, center=center);
    }
}

module elbow_90_ht(leg, od, id, angle=90){
    R = leg; // centerline bend radius so that each leg length from tangent is 'leg'

    union(){
        // Bend (quarter torus segment)
        difference(){
            rotate_extrude(angle=angle, convexity=10)
                translate([R, 0, 0])
                    circle(d=od);
            rotate_extrude(angle=angle, convexity=10)
                translate([R, 0, 0])
                    circle(d=id);
        }

        // Leg 1 along +X from tangent at (R,0)
        translate([R + leg/2 - overlap/2, 0, 0])
            rotate([0, 90, 0])
                hollow_cyl(h=leg + overlap, od=od, id=id, center=true);

        // Leg 2 along +Y from tangent at (0,R)
        translate([0, R + leg/2 - overlap/2, 0])
            rotate([-90, 0, 0])
                hollow_cyl(h=leg + overlap, od=od, id=id, center=true);
    }
}

elbow_90_ht(leg_len, outer_d, inner_d, bend_angle);