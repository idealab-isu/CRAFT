$fn = 96;

// Parameters
sheet_length = 300; //[150:600:1]
sheet_width = 200;  //[100:400:1]
sheet_thickness = 3; //[1.5:6:0.5]
corner_radius = 12; //[6:24:1]
edge_chamfer = 1;   //[0.5:3:0.5]
hole_diameter = 6;  //[3:12:0.5]
hole_edge_offset = 15; //[8:30:1]
film_thickness = 0.2;  //[0.1:0.5:0.05]
overlap = 1; //[0.5:2:0.5]

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Keep features valid
cr = clamp(corner_radius, 0, min(sheet_length, sheet_width)/2 - 0.01);
ch = clamp(edge_chamfer, 0, min(sheet_length, sheet_width)/2 - 0.01);
hole_r = hole_diameter/2;

// Base sheet with rounded corners (2D) then extrude
module sheet_2d() {
    // Rounded rectangle via hull of 4 circles
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(sheet_length/2 - cr), sy*(sheet_width/2 - cr)])
                circle(r=cr);
    }
}

module acrylic_sheet() {
    linear_extrude(height=sheet_thickness, center=true, convexity=10)
        sheet_2d();
}

// Chamfer-like corner trims (small corner cuts) to suggest edge chamfer
module chamfer_corner_cuts() {
    // Cut small right triangles at the 4 outer corners in 2D, then extrude through thickness
    linear_extrude(height=sheet_thickness + 2*overlap, center=true, convexity=10)
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(sheet_length/2), sy*(sheet_width/2)])
                rotate( (sx==1 && sy==1) ? 180 :
                        (sx==-1 && sy==1) ? -90 :
                        (sx==-1 && sy==-1) ? 0 : 90 )
                    polygon(points=[[0,0], [ch,0], [0,ch]]);
}

// Mounting holes (through)
module mounting_holes() {
    for (sx = [-1, 1], sy = [-1, 1])
        translate([sx*(sheet_length/2 - hole_edge_offset),
                   sy*(sheet_width/2 - hole_edge_offset),
                   0])
            cylinder(r=hole_r, h=sheet_thickness + 2*overlap, center=true);
}

// Protective film as a connected layer (slightly overlapping into acrylic)
module protective_film_layer() {
    translate([0, 0, sheet_thickness/2 + film_thickness/2 - overlap])
        linear_extrude(height=film_thickness, center=true, convexity=10)
            sheet_2d();
}

module complete_model() {
    union() {
        // Acrylic with holes and corner chamfer cuts
        difference() {
            acrylic_sheet();
            mounting_holes();
            if (ch > 0) chamfer_corner_cuts();
        }
        // Film overlaps into acrylic to ensure one connected solid
        protective_film_layer();
    }
}

// Final output
color([0.85, 0.85, 0.8])
complete_model();