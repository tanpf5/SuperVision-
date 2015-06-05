% Detect guestures that tap phone, double tap and triple tap
% Signal signature in sensor data should be positive, if not flip it.
% stable_threshold, threshold used to define stable status of phone
% fluc_threshold, threshold used to define the large fluctuation during tapping
% hit_threshold, threshold to detect tap signal

function results = TapDetectionBySensor(sensor,frequency,stable_threshold,fluc_threshold,hit_threshold)


plot(sensor);
eval('hold on');

gap_wnd_t = 600;  % ms. Before a new tapping, there should be a short period of time the phone is stable
tap_wnd_t = 600;  % ms. Tap gesture should be finished within this window

len = length(sensor);
results = zeros(len,1);
t=zeros(len,1);
tf=zeros(len,1);
tapstd=zeros(len,1);

gap_wnd = round((gap_wnd_t*frequency)/1000);
tap_wnd = round((tap_wnd_t*frequency)/1000);

% % stable_mean = -9999;
% for n=gap_wnd+1:len-tap_wnd
%     fluc = std(sensor(n-gap_wnd:n));
%     tf(n)=fluc;
% 
%     if fluc < stable_threshold
%         stable_mean = mean(sensor(n-gap_wnd:n));     % update mean
%         if ((sensor(n+1)-stable_mean) > hit_threshold * fluc) 
%             probedata = sensor(n:n+tap_wnd)-stable_mean;
%             probe = probedata>hit_threshold * fluc;
%             difprobe = diff(probe);
%             tapnum1=find(difprobe==1);
%             tapnum2=find(difprobe==-1);
%             if length(tapnum1)==1 && length(tapnum2)==1    % found signle tap
%                 results(n+1:n+tap_wnd) = 1;
%             elseif length(tapnum1)==2 && length(tapnum2)==2    % found double tap
%                 results(n+1:n+tap_wnd) = 2;
%             elseif length(tapnum1)==3 && length(tapnum2)==3    % found tiple taps
%                 results(n+1:n+tap_wnd) = 3;
%             end
%             t(n+1:n+tap_wnd)=stable_mean+hit_threshold * fluc;
%         end
%     end
%     
%     
% end
% figure(1);
% plot(results,'r');
% plot(t,'g');
% plot(tf,'k');
% eval('hold off');

filter_wnd_t = 100;      %ms
filter_wnd = ceil((filter_wnd_t*frequency)/1000);
%filter = ones(filter_wnd,1)/filter_wnd;
filter = [0.2 0.6 0.2];
tapwidth_threshold = filter_wnd*2.5;

for n=gap_wnd+1:len-tap_wnd
    fluc = std(sensor(n-gap_wnd:n));
    tf(n)=fluc;
    if n==14
        a=1;
    end
    if fluc < stable_threshold
        stable_mean = mean(sensor(n-gap_wnd:n));     % update mean
        x = abs(sensor(n+1));
        tapstd(n+1) = std(sensor(n:n+tap_wnd));
        if (abs(sensor(n+1)-stable_mean) > hit_threshold * fluc) && std(sensor(n:n+tap_wnd)) > fluc_threshold
            probedata0 = (sensor(n:n+tap_wnd)-stable_mean);
            fnd=find(probedata0<0);
            probedata0(fnd)=0;
            probedata = conv(probedata0,filter);
            %probedata = probedata0;
            
%             figure(2);
%             plot(probedata0,'g');
%             hold on
%             plot(probedata,'r');
%             hold off
            
            probe = probedata>hit_threshold * fluc;
            difprobe = diff(probe);
            tapnum1=find(difprobe==1);
            tapnum2=find(difprobe==-1);
            if length(tapnum1)==length(tapnum2)                         % rising edge should equal falling edge
                tapwidth = tapnum2-tapnum1;
                if max(tapwidth)<=tapwidth_threshold                    % peak should not be too wide
                    results(n+1:n+tap_wnd) = length(tapnum1);
                end
            end
     
            t(n:n+tap_wnd)=stable_mean+hit_threshold * fluc;
        end
    end
    
    
end
% figure(1);
plot(results,'r');
plot(t,'g');
plot(tf,'k');
plot(tapstd,'o');
eval('hold off');
