require 'csv'
class VisitorsController < ApplicationController
    """
    Methods to perform spell checking
    Start with correct_word
    """

    """
    In this method, we permute through a possible set of words
    """
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
    """
    This method we explore the 4 basic operations leading to errors.
    """
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
    """
    In this method, we check if a word found is in the dictionary (Unigrams)
    """
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
    """
    This method is the first method called. 
    We take a word, and check if it is in the dictionary. 
    We also get the previous word, since we need to perform bigram analysis. 
    """
    def correct_words word,prev
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
    """
    This is the method that gets called when we go to /visitors/receive. 
    """
    def receive
        @corrected = ""
        @predicted = []
        if params[:random_string] && params[:random_string].length > 0
            @random  = params[:random_string].strip
            puts @random
            @random.gsub!(/\:\?\.\,\!\@\#\$\%\^\&\*/,'')
            puts @random
            flash[:info]="Success"
        else
            flash[:alert]="Enter a string!"
            return redirect_to root_url
        end
        if @random.length==0
            flash[:alert]="Enter a string!"
            return redirect_to root_url
        end
        dom =@random.split(' ')
        i = 0
        # We correct the words individually.
        dom.each do |d|
            puts d
            if dom[i-1]
                @corrected = @corrected + correct_words(d,dom[i-1])+" " 
            else
                @corrected = @corrected + correct_words(d,nil)+" " 
            end
            i= i+1
        end
        c = @corrected.split(' ')
        # Predict words based on Trigrams and Bigrams
        @predicted = predict_trigram(c).merge(predict_bigram(c))
    end
    """
    The methods below are used for the predictor module
    """
    # The method below predicts the possibility of the next word based on a trigram
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
    # The method below predicts the possibility of the next word based on a bigram
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
end
