$fn=96;

L = 12.0;

module sleeve_profile(){
    union(){
        // Base body
        cylinder(h=L, d=27.2, center=true);

        // End collars (slightly larger)
        translate([0,0, (L/2) - 1.0]) cylinder(h=2.0, d=27.2, center=true);
        translate([0,0,-(L/2) + 1.0]) cylinder(h=2.0, d=27.2, center=true);

        // Circumferential ribs
        for(z = [-3.6, 0, 3.6])
            translate([0,0,z]) cylinder(h=0.9, d=27.2, center=true);
    }
}

module grooves(){
    union(){
        // Two prominent recessed bands near midsection
        translate([0,0,-1.8]) cylinder(h=1.6, d=25.2, center=true);
        translate([0,0, 1.8]) cylinder(h=1.6, d=25.2, center=true);

        // Smaller grooves near ends
        translate([0,0, (L/2) - 2.6]) cylinder(h=1.0, d=25.8, center=true);
        translate([0,0,-(L/2) + 2.6]) cylinder(h=1.0, d=25.8, center=true);

        // Shallow relief between ribs
        for(z = [-5.0, 5.0])
            translate([0,0,z]) cylinder(h=0.8, d=26.0, center=true);
    }
}

difference(){
    sleeve_profile();
    grooves();
}