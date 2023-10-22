
%figure, imagesc(d)


%for i=1:170
%    for t=0:179
%        d(i)=sum((ans(i,t)-ans(i-1,t)) + (ans(i,t)-ans(i+1,t)))^2;
%    end
%end

d=D;

Bi=sum(d,2);

% loop over the detector pixels
for i=2:length(Bi)-1
    Ai(i)=((Bi(i)-Bi(i-1))+Bi(i)-Bi(i+1))^2;
end
% x=linspace(1,length(Ai));
%figure(1),
%subplot(2,1,1)
%plot(Bi);title('Uncorrected Sinogram');
%subplot(2,1,2)
figure(1);
subplot(2,1,1)
plot(Ai);title('Squared Difference Curve');
df=diff(Ai);
subplot(2,1,2)
plot(df);title('derivative of squared difference')

%%
figure; 
plot(d(388,:),'r','DisplayName','388');
hold on; 
plot(d(389,:),'b','DisplayName','389');
yline(4.5,'DisplayName','artificial bad pixel')
plot(d(390,:),'g','DisplayName','390');
%plot(d(391,:),'-','DisplayName','391');
title('pixel vs. angle for suspects')
xlabel('angs')
ylabel('Intensity')
ylim([0,5])
hold off;legend
%% Threshold

w=50;
delta=8;
Th=(delta/w)*sum(Ai(1,600:650));

%% Mean curve of uncorrected sinogram

%total number of detector elements
Ni=length(Bi);

%mean curve
mi=Bi/Ni;

%S-G smoothing filter estimated baseline
zi=sgolayfilt(mi,2,5);

%baseline subtracted mean curve
ri=abs(zi-mi);

% plot(mi,':')
% hold on
% plot(Bi,'-o')
% plot(zi,'.-')
%subplot(3,1,3)
%plot(ri,'-*');title('filtered')
%xlabel('pixel number')
%ylabel('r(i)')
%xlim([0, 167])



