%  Matlab mesh
% test, Created by Gmsh
% ASCII
clear msh;
msh.nbNod = 12;
msh.POS = [
0 -0.5 0;
1 -0.5 0;
1 0.5 0;
0 0.5 0;
0.5 -0.5 0;
1 0 0;
0.5 0.5 0;
0 0 0;
0.25 -0.25 0;
0.625 -0.1249999999999999 0;
0.71875 0.2187500000000001 0;
0.345703125 0.154296875 0;
];
msh.MAX = max(msh.POS);
msh.MIN = min(msh.POS);
msh.LINES =[
 1 5 0
 5 2 0
 2 6 0
 6 3 0
 3 7 0
 7 4 0
 4 8 0
 8 1 0
];
msh.TRIANGLES =[
 2 10 5 0
 6 10 2 0
 4 12 7 0
 8 12 4 0
 3 11 6 0
 7 11 3 0
 5 9 1 0
 1 9 8 0
 10 12 9 0
 9 12 8 0
 5 10 9 0
 11 12 10 0
 7 12 11 0
 6 11 10 0
];
msh.PNT =[
 1 0
 2 0
 3 0
 4 0
];
