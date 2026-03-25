$fn=128;

module spool_profile(){
    // Axis along Z, revolve around Z
    // Bounding box target: 12 x 23 x 24 mm => max radius 11.5, length 24
    // Use smooth transitions via hull between adjacent radius stations
    stations = [
        [0.0,   5.0],
        [2.0,   5.0],
        [4.0,   9.0],
        [6.0,   9.0],
        [8.0,   7.0],
        [10.0,  7.0],
        [12.0,  11.5],
        [14.0,  11.5],
        [16.0,  7.0],
        [18.0,  7.0],
        [20.0,  9.0],
        [22.0,  9.0],
        [24.0,  5.0]
    ];
    eps = 0.02;

    union(){
        for(i=[0:len(stations)-2]){
            z0 = stations[i][0];
            r0 = stations[i][1];
            z1 = stations[i+1][0];
            r1 = stations[i+1][1];
            hull(){
                translate([r0, 0, z0]) cylinder(h=eps, r=eps, center=false);
                translate([r1, 0, z1]) cylinder(h=eps, r=eps, center=false);
            }
        }
    }
}

module spool(){
    translate([0,0,-12])
        rotate_extrude(angle=360, convexity=10)
            spool_profile();
}

spool();