## INPUT PARAMETERS
sample_total = 256
max_val = "fff".to_i(16)
debug_prints = false
##


puts "SAMPLE TOTAL: #{sample_total}"
puts "MAXIMUM: #{max_val}"
puts

### SIN WAVE ###

puts "SIN WAVE"
print ".hword "

scaling_tweak = 64 #default:0
shift_tweak = 60 #default:0

count = 0                       #DEBUG
max = 0                         #DEBUG
min = max_val*100               #DEBUG
max_val_adjusted = (max_val/2) - scaling_tweak


for i in 0..sample_total-1
  count+=1                      #DEBUG
  
  sample_total = sample_total * 1.0
  i = i * 1.0
  

  val = (Math.sin( (Math::PI*2/sample_total) *i)+1)
  #  val = (Math.sin( (Math::PI*2/sample_total) *i)+1)
  adjusted = (val*max_val_adjusted).round + shift_tweak
  
  sample_total = sample_total.round
  i = i.round
  
  
  max = adjusted if(adjusted > max)
  min = adjusted if(adjusted < min)
   
  
 # puts  "#{val} - #{adjusted} - #{adjusted.to_s(16)}"
  print "0x"
  print "%03x" % adjusted
  print ", " if(i != sample_total-1)
  
end

if(debug_prints)
  puts
  puts
  puts "Count: #{count}"
  puts "Max: #{max}"
  puts "Min: #{min}"
end

################

puts
puts

### SAW WAVE ###

puts "SAW WAVE"
print ".hword "

count = 0
max = 0
min = max_val*100
max_val_adjusted = (max_val/2)

max_val = max_val*1.0

step_size = (max_val / (sample_total/2)).round

max_val = max_val.round

val = 0
for i in 0..sample_total-1
  count+=1
  
  if(i < sample_total/2)
    val += step_size
  else
    val -= step_size
  end
  
  adjusted = val > max_val ? max_val : val
  
  
  min = adjusted if(adjusted < min)
  max = adjusted if(adjusted > max)
   
  
 # puts  "#{val} - #{adjusted} - #{adjusted.to_s(16)}"
  print "0x"
  print "%03x" % adjusted
  print ", " if(i != sample_total-1)
  
end

if(debug_prints)
  puts
  puts
  puts "Count: #{count}"
  puts "Max: #{max}"
  puts "Min: #{min}"
  puts "Step Size: #{step_size}"
end

################

puts
puts

### SQUARE WAVE ###

puts "SQUARE WAVE"
print ".hword "

count = 0
max = 0
min = max_val*100
max_val_adjusted = (max_val/2)


for i in 0..sample_total-1
  count+=1
  
  if(i < sample_total/2)
    val = 0
  else
    val = max_val
  end
  
  adjusted = val 
  
  
  min = adjusted if(adjusted < min)
  max = adjusted if(adjusted > max)
   
  
 # puts  "#{val} - #{adjusted} - #{adjusted.to_s(16)}"
  print "0x"
  print "%03x" % adjusted
  print ", " if(i != sample_total-1)
  
end

if(debug_prints)
  puts
  puts
  puts "Count: #{count}"
  puts "Max: #{max}"
  puts "Min: #{min}"
end


################

puts