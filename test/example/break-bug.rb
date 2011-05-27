# Problem is not hitting breakpoint at square +=1 more than once when
# "set different" is off. Tracker #28706
triangle = 0
3.times do |i|
  triangle += i
end
puts triangle
