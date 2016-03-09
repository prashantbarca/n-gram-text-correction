require 'csv'
class VisitorsController < ApplicationController
    def correct_words word
        c1 = check_word([word])
        c2 = []
        c3 = []
        list = {}
        if c1.length>0
            return c1.first
        else
            c2 = check_word(permute_words(word))
            if c2.length==0
                c3 = check_word(double_permute_words(word))
            end
        end

        if (c2+c3).length>0
            (c2+c3).each do |e|
                @dict =  Dictionary.find_by_word(e)
                list[@dict.word] = @dict.count
            end
            max = list.values.max
            key = list.select{|k,v| v==max}.keys.first
            return key
        else
            return word
        end
        return word
    end
    def receive
        @corrected = ""
        @predicted = []
        if params[:random_string] && params[:random_string].length > 0
            @random  = params[:random_string].strip
            flash[:info]="Success"
        else
            flash[:alert]="Enter a string!"
            return redirect_to root_url
        end
        dom =@random.split(' ')
        dom.each do |d|
            puts d
            puts correct_words d
            @corrected = @corrected + correct_words(d)+" " 
        end
        c = @corrected.split(' ')
        @predicted = predict_trigram(c).merge(predict_bigram(c))
    end
    def predict_trigram c
        @predicted = {}
        if c[c.length-1] and c[c.length-2]
            @trigram = Trigram.find_by_sql("SELECT word3,count from trigrams where word1='#{c[c.length-2]}' and word2='#{c[c.length-1]}'")
            @bigram = Bigram.find_by_sql("SELECT count from bigrams where word1='#{c[c.length-2]}' and word2='#{c[c.length-1]}'").first
            @trigram.sort_by! do |count|
                count.count
            end
            @trigram = @trigram.reverse
            count = 0
            @trigram.each do |t|
                count = count+1
                i = t.count.to_f
                j = @bigram.count.to_f
                @predicted[t.word3] = i/j
                if count == 3
                    break
                end
            end
        end
        return @predicted
    end
    def predict_bigram c
        @predicted = {}
        if c[c.length-1] 
            @trigram = Bigram.find_by_sql("SELECT word2,count from trigrams where word1='#{c[c.length-1]}'")
            @unigram = Dictionary.find_by_word(c[c.length-1])
            @trigram.sort_by! do |count|
                count.count
            end
            @trigram = @trigram.reverse
            count = 0
            @trigram.each do |t|
                puts t.word2,t.count
                count = count+1
                i = t.count.to_f
                j = @unigram.count.to_f
                @predicted[t.word2] = i/j
                if count == 3
                    break
                end
            end
        end
        return @predicted
    end
    def double_permute_words word
        x = []
        a = permute_words word
        for i in a
            if i
                x = x + (permute_words i)
            end
        end
        return x
    end
    def permute_words word
        alphabets = 'abcdefghijklmnopqrstuvwxyz'.split('')
        splits = []
        for i in (0..word.length)
            splits.push [word[0,i],word[i,word.length]]
        end
        deletes = []
        transposes = []
        replaces = []
        insert = []
        for a,b in splits
            if b and b.length>0
                deletes.push(a + b[1,b.length])
            end
            if b and b.length>1
                transposes.push(a+b[1]+b[0]+b[2,b.length])
            end
            if b and b.length>0
                for j in alphabets
                    replaces.push(a+j+b[1,b.length])
                end
            end
            for c in alphabets
                insert.push(a+c+b)
            end
        end
        return (deletes+transposes+replaces+insert)
    end
    def check_word words
        word_list = []
        for w in words
            if Dictionary.find_by_word(w)
                puts "Pushing"
                word_list.push w
            end
        end
        puts word_list
        return word_list
    end
end
