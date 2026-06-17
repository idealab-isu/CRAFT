$fn=128;

bore_d = 4.0;
od_d = 8.0;
len = 12.0;

module linear_bearing(bore_d, od_d, len){
    difference(){
        cylinder(d=od_d, h=len, center=true);
        cylinder(d=bore_d, h=len+0.2, center=true);
    }
}

linear_bearing(bore_d, od_d, len);