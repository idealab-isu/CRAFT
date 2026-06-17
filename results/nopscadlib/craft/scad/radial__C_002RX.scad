// Radial parameters (requested: A radial: [2.0, 0, 6])
radial_x = 2.0; //[1.0:4.0:0.1]
radial_y = 0.0; //[-2.0:2.0:0.1]
radial_z = 6.0; //[3.0:12.0:0.1]

// Build a clean 6-fold radial (one connected solid), no extra axis/labels.
num_arms = 6;

overlap = 0.8;          //[0.5:2.0:0.1]
hub_r = 1.2;
hub_h = 2.0;

arm_r = 0.45;
end_r = 0.9;

// Use the requested vector magnitude as the arm length
arm_len = sqrt(radial_x*radial_x + radial_y*radial_y + radial_z*radial_z);

// One arm along +X, starting inside hub (by overlap) and ending at radius arm_len
module arm_one() {
    // Cylinder centered at x = (arm_len - overlap)/2 so inner end is at x = -overlap
    translate([(arm_len - overlap)/2, 0, 0])
        rotate([0, 90, 0])
            cylinder(h=arm_len + overlap, r=arm_r, center=true, $fn=48);

    // End cap at x = arm_len
    translate([arm_len, 0, 0])
        sphere(r=end_r, $fn=48);
}

module radial6() {
    union() {
        // Hub
        cylinder(r=hub_r, h=hub_h, center=true, $fn=64);

        // 6 arms in XY plane
        for (i = [0:num_arms-1])
            rotate([0, 0, i*360/num_arms])
                arm_one();
    }
}

radial6();