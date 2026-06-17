$fn=64;

module mounting_hole(d=3.2, h=10){
    cylinder(d=d, h=h, center=true);
}

module lcd_2004a_board(board_x=97.0, board_y=39.5, board_z=1.6){
    difference(){
        cube([board_x, board_y, board_z], center=true);
        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*(board_x/2-2.5), sy*(board_y/2-2.5), 0])
                mounting_hole(d=3.2, h=board_z+2);
        }
    }
}

module lcd_2004a_bezel(board_x=97.0, board_y=39.5, bezel_z=3.0, margin=1.5){
    difference(){
        translate([0,0,bezel_z/2])
            cube([board_x-2*margin, board_y-2*margin, bezel_z], center=true);
        translate([0,0,bezel_z/2])
            cube([76.0, 25.0, bezel_z+1], center=true);
    }
}

module lcd_2004a_display_area(){
    translate([0,0,1.6+0.2])
        cube([76.0, 25.0, 1.0], center=true);
}

module lcd_2004a_header(pin_count=16, pitch=2.54, row_y=5.0, pin_d=0.7, pin_h=6.0, body_h=2.5){
    header_len = (pin_count-1)*pitch + 2.0;
    body_w = 5.0;
    translate([0, row_y, 1.6 + body_h/2])
        cube([header_len, body_w, body_h], center=true);
    for(i=[0:pin_count-1]){
        x = -((pin_count-1)*pitch)/2 + i*pitch;
        translate([x, row_y, 1.6 + body_h + pin_h/2])
            cylinder(d=pin_d, h=pin_h, center=true);
    }
}

module lcd_2004a(){
    union(){
        lcd_2004a_board();
        lcd_2004a_bezel();
        lcd_2004a_display_area();
        lcd_2004a_header();
    }
}

lcd_2004a();