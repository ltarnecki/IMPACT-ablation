function ShadedErrorEllipse(xc, yc, xr, yr, color, tp, border) 
% Ace Stratton 
% Last Updated: 10/6/2022
% Matlab version R2022A 

% xc, yc = the x and y center coordinates 
% xr, yr = the x and y radii
% preferred color in RGB Triplet or matlab standard string color
% tp = transparency value 
% border = option to plot border input 'on' or 'off'

sz = length(xc); 

for i = 1:sz

    if isnan(xc(i)) 
        continue
    end
    if isnan(yc(i)) 
        continue
    end

%Ellipse top half
x = linspace(xc(i)-xr(i),xc(i)+xr(i));
y = sqrt((yr(i)^2)*(1 - (((x-xc(i)).^2)./(xr(i)^2))));

%ignoring imaginary part of ellipse function
y = real(y); 
indexFind = find(y ~= 0); 
minIndex = min(indexFind); maxIndex = max(indexFind); 

if minIndex ~= 1
    minIndex = minIndex - 1;
end 
if maxIndex ~= length(x)
    maxIndex = maxIndex + 1;

end
y = y(minIndex: maxIndex);
x = x(minIndex: maxIndex);

%creating both halves of ellipse
ytop = yc(i) + y; 
ybottom = yc(i) - y; 
xinvert = fliplr(x);
yinvert = fliplr(ybottom);
newX = [x, xinvert];
newY = [ytop, yinvert];

%filling with color
if strcmp(border,'off') == 1
    fill(newX, newY, color, 'FaceAlpha',tp, 'EdgeColor','none')
else
    fill(newX, newY, color, 'FaceAlpha',tp)
end
end

end
