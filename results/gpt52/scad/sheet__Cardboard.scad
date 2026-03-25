$fn=64;

sheet_len = 200;
sheet_wid = 120;
sheet_thk = 4.0;

liner_thk = 0.6;
flute_amp = (sheet_thk - 2*liner_thk)/2;
flute_pitch = 8;
flute_wall = 0.8;

module liner(zpos){
    translate([0,0,zpos])
        cube([sheet_len, sheet_wid, liner_thk], center=true);
}

module flute_rib(xpos){
    translate([xpos,0,0])
    linear_extrude(height=sheet_wid, center=true, convexity=10)
        polygon(points=[
            [-flute_wall/2, -sheet_thk/2 + liner_thk],
            [-flute_wall/2, 0],
            [-flute_wall/2,  sheet_thk/2 - liner_thk],
            [ flute_wall/2,  sheet_thk/2 - liner_thk],
            [ flute_wall/2, 0],
            [ flute_wall/2, -sheet_thk/2 + liner_thk]
        ]);
}

module flutes(){
    n = floor(sheet_len/flute_pitch) + 2;
    for(i=[-n:n]){
        x = i*flute_pitch;
        if (abs(x) <= sheet_len/2 + flute_pitch)
            flute_rib(x);
    }
}

module corrugated_sheet(){
    union(){
        liner(sheet_thk/2 - liner_thk/2);
        liner(-sheet_thk/2 + liner_thk/2);
        flutes();
    }
}

corrugated_sheet();