function [ heights_indx ] = findIndx(heights, PErelation)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
heights_indx = zeros(1, length(heights))
min_valueEle = min(PErelation(:,1))
min_valueP = min(PErelation(:,2))
min_valueHeights = min(heights)

if min_valueHeights == 10 
    heights_indx(find(heights == 10)) = 10;
elseif min_valueHeights <= min_valueP
    heights_indx(find(min_valueHeights <= min_valueEle, 'first'))= min_valueEle;
end 

