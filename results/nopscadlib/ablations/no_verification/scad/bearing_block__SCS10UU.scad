// Linear bearing block for 8.0mm shaft
// Block size: 40.0mm x 35.0mm (X x Y)
// One connected solid (printed part): body with through shaft bore + bearing pocket + 4 mounting holes + counterbores

$fn = 96;

// Parameters
shaft_diameter_mm = 8;                 //[4:16:0.1]
block_length_mm   = 40;                //[20:80:0.5]   // X
block_width_mm    = 35;                //[18:70:0.5]   // Y
block_height_mm   = 28;                //[14:56:0.5]   // Z

bearing_outer_diameter_mm = 15;        //[10:30:0.1]
bearing_length_mm         = 24;        //[12:48:0.5]
bearing_fit_clearance_mm  = 0.2;       //[0:0.6:0.05]

mount_hole_diameter_mm        = 5;     //[3:8:0.1]
mount_hole_spacing_x_mm       = 28;    //[14:56:0.5]
mount_hole_spacing_y_mm       = 22;    //[11:44:0.5]
mount_counterbore_diameter_mm = 9;     //[6:16:0.1]
mount_counterbore_depth_mm    = 4;     //[1:10:0.1]

tolerance_mm = 0.2;                   //[0:0.6:0.05]
overlap_mm   = 1;                     //[0.5:2:0.1]

// Helpers
function clamp(v, lo, hi) = min(max(v, lo), hi);

module bearing_block()
{
    // Derived sizes
    shaft_r  = (shaft_diameter_mm + tolerance_mm)/2;
    pocket_r = (bearing_outer_diameter_mm + bearing_fit_clearance_mm)/2;

    // Ensure pocket is larger than shaft
    pocket_r2 = max(pocket_r, shaft_r + 0.5);

    // Keep bearing pocket within block length
    pocket_len = clamp(bearing_length_mm, 6, block_length_mm - 2);
    pocket_x   = pocket_len + 2*overlap_mm;

    // Through lengths for clean boolean cuts
    cut_x = block_length_mm + 2*overlap_mm;
    cut_y = block_width_mm  + 2*overlap_mm;
    cut_z = block_height_mm + 2*overlap_mm;

    // Keep hole pattern inside the block with margins
    edge_margin_x = max(mount_counterbore_diameter_mm/2 + 2, mount_hole_diameter_mm/2 + 2);
    edge_margin_y = max(mount_counterbore_diameter_mm/2 + 2, mount_hole_diameter_mm/2 + 2);

    sx = clamp(mount_hole_spacing_x_mm, 0, block_length_mm - 2*edge_margin_x);
    sy = clamp(mount_hole_spacing_y_mm, 0, block_width_mm  - 2*edge_margin_y);

    // Typical block geometry: rounded edges + central raised "barrel" around bearing
    fillet_r = min(3, min(block_length_mm, block_width_mm)/10);
    boss_r   = min(pocket_r2 + 3, (block_width_mm/2) - 2);
    boss_h   = min(6, block_height_mm/3);

    difference() {
        union() {
            // Main body with rounded vertical edges
            minkowski() {
                cube([block_length_mm - 2*fillet_r, block_width_mm - 2*fillet_r, block_height_mm], center=true);
                cylinder(r=fillet_r, h=0.01, center=true);
            }

            // Raised boss on top face (connected, overlaps slightly)
            translate([0, 0, block_height_mm/2 + boss_h/2 - overlap_mm])
                cylinder(r=boss_r, h=boss_h, center=true);
        }

        // Shaft through-bore along X (8mm shaft channel)
        rotate([0, 90, 0])
            cylinder(r=shaft_r, h=cut_x, center=true);

        // Bearing pocket along X (OD ~15mm) centered
        rotate([0, 90, 0])
            cylinder(r=pocket_r2, h=pocket_x, center=true);

        // Optional relief slot from top down to pocket (typical clamp-style look)
        // Keeps part one connected solid (this is a cut, not a separate part)
        slot_w = min(2.5, block_width_mm/6);
        slot_h = block_height_mm/2 + boss_h + overlap_mm;
        translate([0, 0, block_height_mm/2 - slot_h/2 + overlap_mm])
            cube([pocket_len, slot_w, slot_h], center=true);

        // 4 mounting through-holes along Z
        for (ix = [-1, 1])
            for (iy = [-1, 1])
                translate([ix*sx/2, iy*sy/2, 0])
                    cylinder(r=mount_hole_diameter_mm/2, h=cut_z, center=true, $fn=48);

        // Counterbores on TOP face (Z+)
        for (ix = [-1, 1])
            for (iy = [-1, 1])
                translate([ix*sx/2, iy*sy/2, block_height_mm/2 - mount_counterbore_depth_mm/2])
                    cylinder(r=mount_counterbore_diameter_mm/2,
                             h=mount_counterbore_depth_mm + overlap_mm,
                             center=true, $fn=64);
    }
}

bearing_block();