// Sheet carbon fiber (flat sheet with corner holes + subtle weave relief)
// ONE connected solid: base sheet with shallow engraved weave + drilled holes
// No text/labels

$fn = 96;

// Parameters
sheet_L = 300; //[150:600:1]
sheet_W = 200; //[100:400:1]
sheet_T = 2;   //[1:6:0.5]

hole_d = 6;              //[3:12:0.5]
hole_edge_margin = 15;   //[8:40:1]
hole_overlap = 1;        //[0.5:2:0.1]

// Carbon weave relief (very shallow so it still looks like a sheet)
weave_pitch = 6;         //[3:12:0.5]   // spacing between weave ridges
weave_width = 1.2;       //[0.6:3:0.1]  // ridge line width
weave_depth = 0.18;      //[0.05:0.4:0.01] // engraving depth

// Derived / safety
hole_r = hole_d/2;
min_margin = hole_r + 0.5;
m = max(hole_edge_margin, min_margin);
wd = min(weave_depth, sheet_T*0.45); // keep engraving safely within thickness

// Base plate
module sheet_plate() {
    cube([sheet_L, sheet_W, sheet_T], center=true);
}

// Mounting holes (subtracted)
module mounting_holes() {
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx*(sheet_L/2 - m), sy*(sheet_W/2 - m), 0])
            cylinder(h = sheet_T + 2*hole_overlap, r = hole_r, center=true);
    }
}

// Subtle carbon-fiber weave engraving (subtracted from top face only)
module weave_engrave() {
    // Engrave only into the top surface by wd
    translate([0, 0, sheet_T/2 - wd/2])
    intersection() {
        // Limit to sheet footprint
        cube([sheet_L, sheet_W, wd], center=true);

        // Union of two diagonal stripe families to suggest a weave
        union() {
            // 45° stripes
            rotate([0, 0, 45])
                for (y = [-(sheet_L+sheet_W) : weave_pitch : (sheet_L+sheet_W)])
                    translate([0, y, 0])
                        cube([sqrt(sheet_L*sheet_L + sheet_W*sheet_W)*1.2, weave_width, wd], center=true);

            // -45° stripes
            rotate([0, 0, -45])
                for (y = [-(sheet_L+sheet_W) : weave_pitch : (sheet_L+sheet_W)])
                    translate([0, y, 0])
                        cube([sqrt(sheet_L*sheet_L + sheet_W*sheet_W)*1.2, weave_width, wd], center=true);
        }
    }
}

// Final model: one connected solid
module complete_model() {
    difference() {
        sheet_plate();
        mounting_holes();
        if (wd > 0) weave_engrave();
    }
}

// Visual: dark carbon-fiber-like color (geometry provides weave)
color([0.06, 0.06, 0.07]) complete_model();