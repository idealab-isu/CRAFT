module rounded_rectangle(width, height, radius, thickness) {
    difference() {
        offset(r=radius) offset(delta=thickness)
            square([width-2*radius, height-2*radius], center=true);
        offset(r=radius)
            square([width, height], center=true);
    }
}

module cutout_grid(rows, cols, cutout_width, cutout_height, spacing) {
    for (i = [0:cols-1])
        for (j = [0:rows-1])
            translate([(i - (cols-1)/2) * (cutout_width + spacing), 
                       (j - (rows-1)/2) * (cutout_height + spacing), 0])
                rounded_rectangle(cutout_width, cutout_height, 0.01, 0.005);
}

module diagonal_ribs(width, height, thickness) {
    polygon(points=[
        [-width/2, -height/2], 
        [width/2, height/2], 
        [width/2, height/2-thickness], 
        [-width/2+thickness, -height/2]
    ]);
    polygon(points=[
        [-width/2, height/2], 
        [width/2, -height/2], 
        [width/2-thickness, -height/2], 
        [-width/2, height/2-thickness]
    ]);
}

module panel() {
    difference() {
        union() {
            rounded_rectangle(0.2, 0.1, 0.01, 0.005);
            diagonal_ribs(0.2, 0.1, 0.005);
        }
        cutout_grid(2, 3, 0.06, 0.03, 0.01);
    }
}

panel();