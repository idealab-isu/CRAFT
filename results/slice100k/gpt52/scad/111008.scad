$fn=96;

bbox_x = 54.4;
bbox_y = 57.1;
bbox_z = 90.0;

Rmax = min(bbox_x, bbox_y)/2;   // 27.2
H = bbox_z;                     // 90

hub_r = 12.0;
hub_h = 22.0;

tip_r = Rmax;
tip_h = H;

base_z = -H/2;
hub_z0 = base_z;
hub_z1 = base_z + hub_h;

module lobe(angle=0, base_r=hub_r, tip_r=tip_r, z0=hub_z1, z1=H/2, w=12.0){
    rotate([0,0,angle])
    polyhedron(
        points=[
            [ base_r, -w/2, z0],  // 0
            [ base_r,  w/2, z0],  // 1
            [ base_r*0.55, 0, z0],// 2
            [ tip_r, 0, z1]       // 3
        ],
        faces=[
            [0,1,2],
            [0,3,1],
            [1,3,2],
            [2,3,0]
        ],
        convexity=10
    );
}

module hub(r=hub_r, h=hub_h){
    translate([0,0,base_z + h/2])
        cylinder(r=r, h=h, center=true);
}

module star_solid(){
    union(){
        hub();
        for(i=[0:4]) lobe(angle=i*72, w=12.0);
    }
}

star_solid();