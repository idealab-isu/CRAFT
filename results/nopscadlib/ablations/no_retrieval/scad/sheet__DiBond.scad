// Sheet DiBond (single connected solid)

// Parameters
sheet_length = 1000; //[500:2000:1]
sheet_width = 500;   //[250:1000:1]
sheet_thickness = 3; //[1.5:6:0.1]
corner_radius = 20;  //[5:60:1]
hole_diameter = 6;   //[3:12:0.5]
hole_edge_offset = 25; //[10:80:1]
edge_chamfer = 0.8;  //[0.2:2:0.1]

// Robustness / overlap
eps = 0.01;
overlap = 1; //[0.5:2:0.1]

// Derived checks (avoid invalid geometry)
cr = min(corner_radius, min(sheet_length, sheet_width)/2 - eps);
heo = min(hole_edge_offset, min(sheet_length, sheet_width)/2 - cr - eps);
ch = min(edge_chamfer, sheet_thickness/2 - eps);

// 2D rounded rectangle (exact, no floating corner cutters)
module rounded_rect_2d(L, W, R) {
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(L/2 - R), sy*(W/2 - R)])
                circle(r=R, $fn=64);
    }
}

// Final sheet: rounded corners + holes + edge chamfer, all connected
module dibond_sheet() {
    difference() {
        // Chamfered solid made by hulling top and bottom rounded rectangles
        hull() {
            translate([0, 0, -sheet_thickness/2])
                linear_extrude(height=eps)
                    rounded_rect_2d(sheet_length, sheet_width, cr);

            translate([0, 0,  sheet_thickness/2])
                linear_extrude(height=eps)
                    offset(delta=-ch)
                        rounded_rect_2d(sheet_length, sheet_width, cr);
        }

        // Mounting holes (through)
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(sheet_length/2 - heo), sy*(sheet_width/2 - heo), 0])
                cylinder(h=sheet_thickness + 2*overlap, r=hole_diameter/2, center=true, $fn=64);
    }
}

// Output
color([0.85, 0.85, 0.8])
dibond_sheet();