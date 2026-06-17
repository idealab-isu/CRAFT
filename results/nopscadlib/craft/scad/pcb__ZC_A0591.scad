$fn = 64;

// Motor driver module PCB dimensions (mm)
length = 35.0;
width  = 32.0;
thickness = 1.6;

// Rounded corner radius (0 = sharp corners)
corner_radius = 0.0;

// 2D rounded rectangle helper (robust for r=0 and small sizes)
module rounded_rect_2d(l, w, r) {
    r2 = max(0, min(r, min(l, w)/2));
    if (r2 == 0) {
        square([l, w], center=true);
    } else {
        offset(r=r2)
            square([l - 2*r2, w - 2*r2], center=true);
    }
}

// PCB plate (single connected solid)
module pcb_plate() {
    color([0.0, 0.4, 0.2])
        linear_extrude(height=thickness, center=false, convexity=10)
            rounded_rect_2d(length, width, corner_radius);
}

// Place PCB so it spans z=[0..thickness] (avoids any center/preview edge cases)
translate([0, 0, 0])
    pcb_plate();