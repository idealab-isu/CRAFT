$fn=96;

size = 0.1;
r = size/2;
h = size;

edge_r = 0.01;
facet_n = 18;

module faceted_cylinder(r=0.05, h=0.1, n=18){
    cylinder(r=r, h=h, center=true, $fn=n);
}

module filleted_puck(r=0.05, h=0.1, fillet=0.01, facets=18){
    union(){
        translate([0,0,0])
            faceted_cylinder(r=r-fillet, h=h, n=facets);
        translate([0,0,(h/2 - fillet)])
            cylinder(r=r-fillet, h=2*fillet, center=true, $fn=facets);
        translate([0,0,(-h/2 + fillet)])
            cylinder(r=r-fillet, h=2*fillet, center=true, $fn=facets);
        translate([0,0,(h/2 - fillet)])
            rotate_extrude(angle=360, $fn=96)
                translate([r-fillet,0,0])
                    circle(r=fillet, $fn=48);
        translate([0,0,(-h/2 + fillet)])
            rotate_extrude(angle=360, $fn=96)
                translate([r-fillet,0,0])
                    circle(r=fillet, $fn=48);
    }
}

intersection(){
    filleted_puck(r=r, h=h, fillet=edge_r, facets=facet_n);
    cube([size,size,size], center=true);
}