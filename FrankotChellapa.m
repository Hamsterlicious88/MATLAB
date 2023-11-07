function X = PoiSolveSym(gx,gy,dx,regparam,sym)
%PoiSolveSym solves a Poisson equation Del2(X)=g using FFTs
% returns a matrix X the same size as g.
%
% dx is the pixel size
% regparam is a regularization
% sym is a string, either 's', 'a', or 'n' indicating symmetric,
% asymmetric or no mirrororing--see VV Volkov, Y Zho, M De Graef, Micron. 2002;33(5):411-6.
% if any thing other than s or a passed, it doesn't mirror

F = @(x) fftshift(fft2(ifftshift(x)));
Ft= @(x) fftshift(ifft2(ifftshift(x)));
[leny0,lenx0]=size(gx);

g=gx+1i.*gy;

if strcmp(sym,'s')
    %Symmetrized
    
    g=padarray(g,[leny0,lenx0],0,'post');
    g=g+fliplr(g);
    g=g+flipud(g);
elseif strcmp(sym,'a')
    %Antisymmetrized
    g=padarray(g,[leny0,lenx0],0,'post');
    g=g-fliplr(g);
    g=g-flipud(g);
end

[leny,lenx]=size(g);

x = ((-lenx/2):(lenx/2-1)).*dx;
y = ((-leny/2):(leny/2-1)).*dx;
dux=1./(dx*size(g,2));
duy=1./(dx*size(g,1));

ux = ((-lenx/2):(lenx/2-1)).*dux;
uy = ((-leny/2):(leny/2-1)).*duy;
[X,Y] = meshgrid(x,y);
[fX,fY] = meshgrid(ux,uy);
Hx = 2.*pi.*1i*(fX);
Hy = 2.*pi.*1i*(fY);
Hforw=Hx+1i.*Hy;
Hinv=conj(Hforw)./(abs(Hforw).^2+(2*pi).^2.*regparam.^2);
% Hinv=1./(Hforw+r);
gf = real(Ft(F(g).*Hinv));%integral result
X=gf(1:leny0,1:lenx0);  
    
end

