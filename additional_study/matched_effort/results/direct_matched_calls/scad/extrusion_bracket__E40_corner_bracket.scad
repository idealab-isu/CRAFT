$fn=64;

size = [40,40,35];   // overall bounding box
wall = 4;            // bracket wall thickness
hole_d = 6.5;        // clearance for M6
csk_d = 12;          // counterbore diameter
csk_h = 3;           // counterbore depth
edge_off = 12;       // hole offset from outer edges

module counterbore_hole(h=20){
    union(){
        cylinder(d=hole_d, h=h);
        translate([0,0,h-csk_h]) cylinder(d=csk_d, h=csk_h);
    }
}

difference(){
    // L-bracket body (two plates)
    union(){
        cube([size[0], wall, size[2]], center=false); // base plate along X
        cube([wall, size[1], size[2]], center=false); // base plate along Y
    }

    // lighten inside corner (optional relief)
    translate([wall, wall, 0])
        cube([size[0]-wall, size[1]-wall, size[2]], center=false);

    // holes on X plate (through Y thickness)
    for (xpos = [edge_off, size[0]-edge_off])
        translate([xpos, wall/2, size[2]/2])
            rotate([90,0,0])
                counterbore_hole(h=wall+0.2);

    // holes on Y plate (through X thickness)
    for (ypos = [edge_off, size[1]-edge_off])
        translate([wall/2, ypos, size[2]/2])
            rotate([0,90,0])
                counterbore_hole(h=wall+0.2);
}