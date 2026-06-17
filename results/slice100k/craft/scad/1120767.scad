$fn = 96;

// Target bounding box (mm)
bbox_x = 16.8;
bbox_y = 16.8;
bbox_z = 6.3;

// Main disk
disk_d = 12.0;
disk_r = disk_d/2;
thickness = bbox_z;

// Lugs (4x at 90°)
lug_count = 4;
lug_w_tangential = 4.0;                 // width of lug (tangential)
lug_len_radial = (bbox_x/2) - disk_r;   // set so overall X/Y matches bbox
overlap = 0.8;                          // overlap into disk to ensure one solid

module disk_body() {
    cylinder(r=disk_r, h=thickness, center=true);
}

module lug() {
    // Lug extends outward from disk edge; overlaps inward by 'overlap'
    // Inner edge radius = disk_r - overlap
    // Outer edge radius = disk_r + lug_len_radial
    translate([disk_r + lug_len_radial/2 - overlap/2, 0, 0])
        cube([lug_len_radial + overlap, lug_w_tangential, thickness], center=true);
}

union() {
    disk_body();
    for (i = [0:lug_count-1])
        rotate([0, 0, i*360/lug_count]) lug();
}