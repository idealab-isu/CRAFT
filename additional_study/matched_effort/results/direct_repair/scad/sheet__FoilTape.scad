$fn = 96;

length = 120;
width  = 60;
thickness = 0.08;

corner_r = 2;

module rounded_sheet(l, w, t, r){
    r2 = min(r, min(l,w)/2);
    linear_extrude(height=t, center=false, convexity=10)
        offset(r=r2)
            square([l-2*r2, w-2*r2], center=true);
}

module foil_tape_sheet(){
    // Slightly irregular edge to suggest thin foil
    edge_wobble = 0.35;
    edge_freq = 18;

    // Base rounded sheet
    color([0.78, 0.80, 0.83])
    difference(){
        rounded_sheet(length, width, thickness, corner_r);

        // Subtle scallop cuts along long edges
        for(i=[0:edge_freq]){
            x = -length/2 + i*(length/edge_freq);
            y1 =  width/2;
            y2 = -width/2;
            translate([x, y1, -0.01])
                cylinder(h=thickness+0.02, r=edge_wobble, center=false);
            translate([x, y2, -0.01])
                cylinder(h=thickness+0.02, r=edge_wobble, center=false);
        }

        // Subtle scallop cuts along short edges
        for(i=[0:floor(edge_freq*width/length)]){
            y = -width/2 + i*(width/max(1,floor(edge_freq*width/length)));
            x1 =  length/2;
            x2 = -length/2;
            translate([x1, y, -0.01])
                cylinder(h=thickness+0.02, r=edge_wobble, center=false);
            translate([x2, y, -0.01])
                cylinder(h=thickness+0.02, r=edge_wobble, center=false);
        }
    }

    // Brushed/creased highlights (very shallow ridges)
    color([0.88, 0.90, 0.93, 0.55])
    for(i=[0:10]){
        x = -length/2 + (i+0.5)*length/11;
        ridge_w = 0.6 + (i%3)*0.25;
        ridge_h = 0.015 + (i%4)*0.004;
        translate([x, 0, thickness])
            linear_extrude(height=ridge_h, center=false)
                offset(r=0.2)
                    square([ridge_w, width*0.92], center=true);
    }

    // A couple of diagonal creases
    color([0.95, 0.96, 0.98, 0.45])
    for(a=[-18, 22]){
        translate([0,0,thickness])
            rotate([0,0,a])
                linear_extrude(height=0.02, center=false)
                    square([length*0.95, 0.7], center=true);
    }
}

foil_tape_sheet();