$fn=96;

module ring(od, id, h){
    difference(){
        cylinder(d=od, h=h, center=false);
        translate([0,0,-0.1]) cylinder(d=id, h=h+0.2, center=false);
    }
}

module ht125_cap(){
    // Approximate dimensions for HT 125 end cap
    // Nominal pipe OD ~125mm; cap has socket and closed end
    od_outer = 140;
    od_socket_inner = 126.5;
    wall = (od_outer - od_socket_inner)/2;
    socket_depth = 55;
    end_thickness = 6;
    total_h = socket_depth + end_thickness;

    // External grip ribs
    rib_count = 24;
    rib_depth = 1.6;
    rib_width = 3.2;
    rib_h = 18;
    rib_z0 = total_h - rib_h - 6;

    // Stop ring inside socket
    stop_z = socket_depth - 10;
    stop_th = 3;
    stop_id = 118;

    difference(){
        union(){
            // Main body: socket + end
            cylinder(d=od_outer, h=total_h, center=false);

            // Slight outer collar near opening
            translate([0,0,0])
                cylinder(d=od_outer+4, h=8, center=false);

            // Grip ribs
            for(i=[0:rib_count-1]){
                rotate([0,0,360/rib_count*i])
                    translate([od_outer/2 - rib_depth/2,0,rib_z0])
                        cube([rib_depth, rib_width, rib_h], center=true);
            }
        }

        // Hollow socket
        translate([0,0,-0.1])
            cylinder(d=od_socket_inner, h=socket_depth+0.2, center=false);

        // Inner cavity behind end (leave end_thickness)
        translate([0,0,socket_depth])
            cylinder(d=od_socket_inner-2*1.5, h=end_thickness+0.2, center=false);

        // Internal stop ring (reduce ID at stop position)
        translate([0,0,stop_z])
            cylinder(d=stop_id, h=stop_th, center=false);

        // Small vent/mark dimple on end face
        translate([0,0,total_h-2])
            cylinder(d=3, h=3, center=false);
    }
}

translate([0,0,-(55+6)/2]) ht125_cap();