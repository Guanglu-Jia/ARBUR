% writematrix()
%   writeMatrix.m
function writeMatrix(A, path)
[row, col] = size(A);
fid = fopen(path, 'w');
for i=1:row
    for j=1:col-1
        fprintf(fid, '%f\,', A(i,j));
    end
    fprintf(fid, '%f\r\n', A(i,col));
end
fclose(fid);
end
