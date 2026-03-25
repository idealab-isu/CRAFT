$fn=64;

board_x = 26.3;
board_y = 19.5;
board_t = 1.6;

corner_r = 1.2;

mount_hole_d = 3.0;
mount_hole_offset_x = 2.2;
mount_hole_offset_y = 2.2;

encoder_hole_d = 7.0;

header_pins = 5;
header_pitch = 2.54;
header_hole_d = 1.0;
header_row_y = -board_y/2 + 2.54;
header_start_x = -((header_pins-1)*header_pitch)/2;

module rounded_rect_2d(x,y,r){
    hull(){
        for (sx=[-1,1], sy=[-1,1])
            translate([sx*(x/2-r), sy*(y/2-r)]) circle(r=r);
    }
}

module pcb(){
    color([0.05,0.35,0.12])
    linear_extrude(height=board_t)
        rounded_rect_2d(board_x, board_y, corner_r);
}

module hole_cyl(d,h){
    cylinder(d=d, h=h, center=false);
}

module through_holes(){
    // Mounting holes (4 corners)
    for (sx=[-1,1], sy=[-1,1]){
        translate([sx*(board_x/2 - mount_hole_offset_x), sy*(board_y/2 - mount_hole_offset_y), -0.2])
            hole_cyl(mount_hole_d, board_t+0.4);
    }
    // Encoder shaft hole (centered)
    translate([0,0,-0.2]) hole_cyl(encoder_hole_d, board_t+0.4);

    // Header holes (single row)
    for (i=[0:header_pins-1]){
        translate([header_start_x + i*header_pitch, header_row_y, -0.2])
            hole_cyl(header_hole_d, board_t+0.4);
    }
}

module copper_pads(){
    pad_t = 0.05;
    pad_d = 1.8;

    // Header pads (top)
    color([0.85,0.65,0.2])
    translate([0,0,board_t - pad_t])
    for (i=[0:header_pins-1]){
        translate([header_start_x + i*header_pitch, header_row_y, 0])
            cylinder(d=pad_d, h=pad_t, center=false);
    }

    // Mount pads (top)
    color([0.85,0.65,0.2])
    translate([0,0,board_t - pad_t])
    for (sx=[-1,1], sy=[-1,1]){
        translate([sx*(board_x/2 - mount_hole_offset_x), sy*(board_y/2 - mount_hole_offset_y), 0])
            cylinder(d=mount_hole_d+2.2, h=pad_t, center=false);
    }
}

module silkscreen(){
    s_t = 0.03;
    color([0.95,0.95,0.95])
    translate([0,0,board_t - s_t])
    linear_extrude(height=s_t)
    difference(){
        offset(delta=0.35) rounded_rect_2d(board_x-1.0, board_y-1.0, max(0.2, corner_r-0.5));
        offset(delta=-0.35) rounded_rect_2d(board_x-1.0, board_y-1.0, max(0.2, corner_r-0.5));
    }
}

module board_assembly(){
    difference(){
        pcb();
        through_holes();
    }
    copper_pads();
    silkscreen();
}

board_assembly();