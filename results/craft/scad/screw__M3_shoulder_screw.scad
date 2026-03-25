// Simple screw: 4.0mm shaft diameter, 7.0mm head diameter, head height 2.4mm, total length 10mm
$fn = 96;

// Parameters (mm)
shaft_diameter_mm = 4.0;
length_mm         = 10.0;

head_diameter_mm  = 7.0;
head_height_mm    = 2.4;

// Small overlap to ensure one connected solid
overlap_mm = 0.2;

module screw_simple() {
    shaft_r = shaft_diameter_mm/2;
    head_r  = head_diameter_mm/2;

    // Place screw along +Z, bottom at z=0, top at z=length_mm
    union() {
        // Shaft (under head)
        cylinder(h = length_mm - head_height_mm + overlap_mm, r = shaft_r, center = false);

        // Head (on top), overlapping slightly into shaft
        translate([0, 0, length_mm - head_height_mm])
            cylinder(h = head_height_mm, r = head_r, center = false);
    }
}

screw_simple();