$fn=64;

inch = 25.4;
thickness = 5/16 * inch;  // 0.3125 in
sheet_x = 100;
sheet_y = 100;

module sheet(x=sheet_x, y=sheet_y, t=thickness){
    translate([-x/2, -y/2, -t/2])
        cube([x, y, t], center=false);
}

sheet();