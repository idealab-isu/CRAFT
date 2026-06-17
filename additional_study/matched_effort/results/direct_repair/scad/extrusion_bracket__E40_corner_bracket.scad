$fn = 64;

size = [40, 40, 35];   // overall bounding box [X,Y,Z]
wall = 4;              // bracket wall thickness
hole_d = 6.5;          // mounting hole diameter
hole_edge = 12;        // distance from outer edges to hole centers
fillet_r = 3;          // outer corner rounding

module rounded_box(sz=[10,10,10], r=2){
    r2 = min(r, sz[0]/2, sz[1]/2);
    linear_extrude(height=sz[2])
        offset(r=r2)
            square([sz[0]-2*r2, sz[1]-2*r2], center=true);
}

module extrusion_bracket(sz=[40,40,35], t=4, hd=6.5, he=12, fr=3){
    difference(){
        // Outer L-bracket volume (rounded)
        translate([sz[0]/2, sz[1]/2, 0])
            rounded_box([sz[0], sz[1], sz[2]], r=fr);

        // Remove inner corner to form L shape
        translate([t, t, -0.5])
            cube([sz[0]-t+0.5, sz[1]-t+0.5, sz[2]+1], center=false);

        // Holes on X-leg (along Y thickness)
        for (x = [he, sz[0]-he])
            translate([x, t/2, sz[2]/2])
                rotate([90,0,0])
                    cylinder(d=hd, h=t+1, center=true);

        // Holes on Y-leg (along X thickness)
        for (y = [he, sz[1]-he])
            translate([t/2, y, sz[2]/2])
                rotate([0,90,0])
                    cylinder(d=hd, h=t+1, center=true);
    }
}

extrusion_bracket(size, wall, hole_d, hole_edge, fillet_r);