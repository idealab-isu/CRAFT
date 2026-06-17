$fn=64;

size = 0.1;
half = size/2;

boss_h = 0.012;
boss_base = 0.018;
boss_top = 0.004;

boss_h_small = 0.008;
boss_base_small = 0.012;
boss_top_small = 0.003;

edge_boss_h = 0.007;
edge_boss_base = 0.010;
edge_boss_top = 0.0025;

module faceted_boss(h, b, t){
    linear_extrude(height=h, scale=t/b, convexity=10)
        circle(d=b, $fn=4);
}

module face_bosses(face="z+", inset=0.028){
    zoff = half;
    if(face=="z+"){
        translate([ inset,  inset, zoff]) faceted_boss(boss_h, boss_base, boss_top);
        translate([-inset,  inset, zoff]) faceted_boss(boss_h, boss_base, boss_top);
        translate([ inset, -inset, zoff]) faceted_boss(boss_h, boss_base, boss_top);
        translate([-inset, -inset, zoff]) faceted_boss(boss_h, boss_base, boss_top);
        translate([0,0,zoff]) faceted_boss(boss_h_small, boss_base_small, boss_top_small);
    } else if(face=="z-"){
        rotate([180,0,0]) face_bosses("z+");
    } else if(face=="x+"){
        rotate([0,-90,0]) face_bosses("z+");
    } else if(face=="x-"){
        rotate([0,90,0]) face_bosses("z+");
    } else if(face=="y+"){
        rotate([90,0,0]) face_bosses("z+");
    } else if(face=="y-"){
        rotate([-90,0,0]) face_bosses("z+");
    }
}

module edge_bosses(){
    e = 0.040;
    o = half;
    // Along edges near corners, on each face adjacency
    // Z+ edges
    translate([ e,  o,  o]) rotate([0,0,45]) faceted_boss(edge_boss_h, edge_boss_base, edge_boss_top);
    translate([-e,  o,  o]) rotate([0,0,45]) faceted_boss(edge_boss_h, edge_boss_base, edge_boss_top);
    translate([ e, -o,  o]) rotate([0,0,45]) faceted_boss(edge_boss_h, edge_boss_base, edge_boss_top);
    translate([-e, -o,  o]) rotate([0,0,45]) faceted_boss(edge_boss_h, edge_boss_base, edge_boss_top);

    translate([ o,  e,  o]) rotate([0,0,45]) faceted_boss(edge_boss_h, edge_boss_base, edge_boss_top);
    translate([ o, -e,  o]) rotate([0,0,45]) faceted_boss(edge_boss_h, edge_boss_base, edge_boss_top);
    translate([-o,  e,  o]) rotate([0,0,45]) faceted_boss(edge_boss_h, edge_boss_base, edge_boss_top);
    translate([-o, -e,  o]) rotate([0,0,45]) faceted_boss(edge_boss_h, edge_boss_base, edge_boss_top);

    // Z- edges
    translate([ e,  o, -o]) rotate([180,0,45]) faceted_boss(edge_boss_h, edge_boss_base, edge_boss_top);
    translate([-e,  o, -o]) rotate([180,0,45]) faceted_boss(edge_boss_h, edge_boss_base, edge_boss_top);
    translate([ e, -o, -o]) rotate([180,0,45]) faceted_boss(edge_boss_h, edge_boss_base, edge_boss_top);
    translate([-e, -o, -o]) rotate([180,0,45]) faceted_boss(edge_boss_h, edge_boss_base, edge_boss_top);

    translate([ o,  e, -o]) rotate([180,0,45]) faceted_boss(edge_boss_h, edge_boss_base, edge_boss_top);
    translate([ o, -e, -o]) rotate([180,0,45]) faceted_boss(edge_boss_h, edge_boss_base, edge_boss_top);
    translate([-o,  e, -o]) rotate([180,0,45]) faceted_boss(edge_boss_h, edge_boss_base, edge_boss_top);
    translate([-o, -e, -o]) rotate([180,0,45]) faceted_boss(edge_boss_h, edge_boss_base, edge_boss_top);

    // A few extra near corners on side faces
    c = 0.042;
    translate([ o,  c,  c]) rotate([0,-90,45]) faceted_boss(edge_boss_h, edge_boss_base, edge_boss_top);
    translate([ o, -c,  c]) rotate([0,-90,45]) faceted_boss(edge_boss_h, edge_boss_base, edge_boss_top);
    translate([ o,  c, -c]) rotate([0,-90,45]) faceted_boss(edge_boss_h, edge_boss_base, edge_boss_top);
    translate([ o, -c, -c]) rotate([0,-90,45]) faceted_boss(edge_boss_h, edge_boss_base, edge_boss_top);

    translate([-o,  c,  c]) rotate([0,90,45]) faceted_boss(edge_boss_h, edge_boss_base, edge_boss_top);
    translate([-o, -c,  c]) rotate([0,90,45]) faceted_boss(edge_boss_h, edge_boss_base, edge_boss_top);
    translate([-o,  c, -c]) rotate([0,90,45]) faceted_boss(edge_boss_h, edge_boss_base, edge_boss_top);
    translate([-o, -c, -c]) rotate([0,90,45]) faceted_boss(edge_boss_h, edge_boss_base, edge_boss_top);
}

module studded_cube(){
    union(){
        cube([size,size,size], center=true);
        face_bosses("z+");
        face_bosses("z-");
        face_bosses("x+");
        face_bosses("x-");
        face_bosses("y+");
        face_bosses("y-");
        edge_bosses();
    }
}

studded_cube();