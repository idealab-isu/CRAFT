$fn = 64;

board_x = 26.3;
board_y = 19.5;
board_th = 1.6;

corner_r = 1.2;

module rounded_rect_2d(x, y, r){
    r2 = min(r, min(x,y)/2);
    hull(){
        translate([ r2,  r2]) circle(r=r2);
        translate([x-r2,  r2]) circle(r=r2);
        translate([ r2, y-r2]) circle(r=r2);
        translate([x-r2, y-r2]) circle(r=r2);
    }
}

module pcb(){
    color([0.05, 0.35, 0.12])
    linear_extrude(height=board_th)
        rounded_rect_2d(board_x, board_y, corner_r);
}

pcb();