$fn = 96;

// Parameters for the tooling plate (mm)
length = 200;
width = 100;
thickness = 10;
corner_radius = 5;

// 3D tooling plate: one connected solid with rounded corners
module tooling_plate_sheet_3d(L=200, W=100, T=10, R=5) {
    R2 = min(R, min(L, W)/2);

    color([0.75, 0.75, 0.78])  // aluminum-like light gray
    linear_extrude(height=T, center=true, convexity=10)
        offset(r=R2)
            square([L - 2*R2, W - 2*R2], center=true);
}

tooling_plate_sheet_3d(length, width, thickness, corner_radius);