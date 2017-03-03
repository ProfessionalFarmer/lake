#! /usr/bin/ruby


#File.open(ARGV[0],"r") do | file |
#do sth
#end

if ARGV.length!=0 then
    file=File.open(ARGV[0],"r")
else
    file=STDIN
end


while line = file.gets
    line = line.chomp
    t=line.split("\t")

    # do not consider multiple allele
    if t[4].include?","  then
        next

    if t[3].length==1 and t[4].length==1
        #1	36587318	36587318	-	A
        #1	36587318	36587318	T	A
        puts t.join("\t")
	next
    elsif t[3].length==1 and t[4].length!=1
	if t[4].include?","
	    #1	8999158	8999158	C	1CT,CTT	1000G_AFR	S
	    tmpt4=t[4]
            tmpt4.split(",").each do | altt |
		if tmpt4[0].is_a?(Integer) then 
		    altt=altt.gsub!(tmpt4[0],"")
		end
		puts t.join("\t")
	    end
	    next
	else
	#1	36587318	36587318	T	TA	1000G_AFR	S
	    puts t.join("\t")
	    next
	end
    end

    if t[4]=="-" then
	#1	6472478	6472484	TTTTTTT	-
	puts t.join("\t")
	next
    end

    if t[4].length==1 and t[3][0]==t[4] then
	#1	6472478	6472485	ATTTTTTT	A	1000G_AFR	M
        #多了前面一个A，坐标减一
	t[1]=t[1].to_i - 1
	t[2]=t[2].to_i - 1
	puts t.join("\t")
	next
    end

    if t[3].length!=1 then
	t[1] = t[1].to_i - t[3].length + 1
	tmpt4=t[4]
	tmpt4.split(",").each do | altt |
	    if tmpt4[0].is_a?(Integer) then
		altt=altt.gsub!(tmpt4[0],"")
	    end
	    puts t.join("\t")
	end
	next
    end
    
    p "Please note: the following line was not handled"
    p line
    exit
    
end



