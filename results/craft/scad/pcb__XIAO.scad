// Printed circuit board: 21.0mm x 18.0mm x 1.2mm (one connected solid)

length_mm = 21.0;
width_mm  = 18.0;
thickness_mm = 1.2;

$fn = 48;

module pcb(len=length_mm, wid=width_mm, th=thickness_mm) {
    // Slightly rounded corners while keeping exact overall dimensions
    corner_r = min(1.0, min(len, wid)/10);
    eps = 0.01;

    color([0.0, 0.4, 0.2])
    linear_extrude(height=th, center=true, convexity=10)
        offset(r=corner_r)
            square([len - 2*corner_r + eps, wid - 2*corner_r + eps], center=true);
}

pcb();