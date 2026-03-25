cylinder(h=100, r=2, $fn=64);  
cylinder(h=100, r=1.5, $fn=64, center=true);  
difference() {  
    translate([0, 0, 50]) cylinder(h=100, r=2, $fn=64);  
    translate([0, 0, 50]) cylinder(h=100, r=1.5, $fn=64);  
}