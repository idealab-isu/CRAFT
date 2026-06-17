$fn=64;

bbox_xy = 6.8;
bbox_z  = 9.9;

sphere_d = 6.8;
sphere_r = sphere_d/2;

stem_d = 3.0;
stem_r = stem_d/2;

stem_h = bbox_z - sphere_d;

module faceted_sphere(r, facets=18){
    sphere(r=r, $fn=facets);
}

module stem(r, h){
    cylinder(r=r, h=h, center=false, $fn=64);
}

union(){
    translate([0,0,-bbox_z/2 + sphere_r])
        faceted_sphere(sphere_r, facets=18);

    translate([0,0,-bbox_z/2 + sphere_d])
        stem(stem_r, stem_h);
}