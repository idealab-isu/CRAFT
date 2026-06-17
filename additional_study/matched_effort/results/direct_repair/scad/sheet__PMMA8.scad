$fn = 64;

inch = 25.4;
thickness = 5/16 * inch;   // ~5/16"
width = 100;               // mm
length = 150;              // mm

cube([length, width, thickness], center=false);