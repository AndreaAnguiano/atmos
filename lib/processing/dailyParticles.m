function DailyParticles = dailyParticles(particles, spillTiming)
%UNTITLED10 Summary of this function goes here
%   Detailed explanation goes here
serial_dates       = (datenum(spillTiming.startDay_date):datenum(spillTiming.endSimDay_date))';
simulationDays     = numel(serial_dates);
DailyParticles.SerialDates = serial_dates;
DailyParticles.Net = particles;
end

