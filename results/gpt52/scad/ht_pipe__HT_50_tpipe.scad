$fn=96;

module pipe_segment(od=50, wall=1.8, len=60){
    difference(){
        cylinder(h=len, d=od, center=true);
        cylinder(h=len+0.2, d=od-2*wall, center=true);
    }
}

module socket(od=50, wall=1.8, len=35, socket_extra=4){
    // Slightly larger OD to suggest socket end
    difference(){
        cylinder(h=len, d=od+2*socket_extra, center=true);
        cylinder(h=len+0.2, d=od-2*wall, center=true);
    }
}

module ht50_t_pipe(){
    od = 50;
    wall = 1.8;

    main_len = 140;
    branch_len = 90;

    socket_len = 35;
    socket_extra = 4;

    union(){
        // Main run (X axis)
        rotate([0,90,0]) pipe_segment(od=od, wall=wall, len=main_len);

        // Branch (Y axis)
        rotate([90,0,0]) pipe_segment(od=od, wall=wall, len=branch_len);

        // Sockets on main ends
        translate([ main_len/2 - socket_len/2, 0, 0])
            rotate([0,90,0]) socket(od=od, wall=wall, len=socket_len, socket_extra=socket_extra);

        translate([-main_len/2 + socket_len/2, 0, 0])
            rotate([0,90,0]) socket(od=od, wall=wall, len=socket_len, socket_extra=socket_extra);

        // Socket on branch end
        translate([0, branch_len/2 - socket_len/2, 0])
            rotate([90,0,0]) socket(od=od, wall=wall, len=socket_len, socket_extra=socket_extra);
    }
}

ht50_t_pipe();