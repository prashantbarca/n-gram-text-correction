require 'csv'
class SeedController < ApplicationController
    """
    Access at /visitors/seed
    This method is to seed the words from the corpus. 
    """
    def dictionary
        Dictionary.delete_all
        array_global = []
        count = 0
        filename = "/home/prashant/cs76proj/master_master_corpus.txt"

        CSV.foreach filename,{:col_sep => "\t", encoding: "ISO8859-1"} do |row|
            count = count+1
            if count>20
                break
            end
            array = row[2].split(/ -/)
            array.each do |each_string|
                each_string.split(' ').each do |a|
                    a.gsub!('\.\?\(\)\:\"\'\!\@\#\$\%\^\&\*','')
                    array_global.push a.downcase
                end
            end
        end
        array_global = array_global.uniq
        array_global.each do |string|
            @dictionary = Dictionary.create!(:word=>string)
            @dictionary.save
        end
        flash[:info]="Success"
    end

    """
    """
    def bigrams
        filename = "/home/prashant/cs76proj/master_corpus.txt"

        Bigram.delete_all
        count = 0
        CSV.foreach filename,{:col_sep => "\t", encoding: "ISO8859-1"} do |row|
            count = count+1
            if count>20
                break
            end
            array = row[2]
            tokenizer = Nanogram::Tokenizer.new
            array = array.downcase.gsub(/[\.\?\,\:\-\(\)\'\!0-9\/]/,'')
            global_array = tokenizer.ngrams(2,array)
            global_array.each do |string|
                string = string.split(' ')
                @bigram = Bigram.find_by_word1_and_word2(string[0],string[1])
                if @bigram
                    @bigram.count = @bigram.count+1
                    @bigram.save
                else
                    @bigrams = Bigram.create!(:word1=> string[0],:word2 => string[1])
                    @bigrams.save
                end
            end
        end
        flash[:info]="Success"
    end

    """
    """
    def trigrams
        filename = "/home/prashant/cs76proj/master_corpus.txt"
        Trigram.delete_all
        count = 0
        CSV.foreach filename,{:col_sep => "\t", encoding: "ISO8859-1"} do |row|
            count = count+1
            if count>20
                break
            end
            array = row[2]
            tokenizer = Nanogram::Tokenizer.new
            array = array.downcase.gsub(/[\.\?\,\:\-\(\)\'\!0-9\/]/,'')
            global_array = tokenizer.ngrams(3,array)
            global_array.each do |string|
                string = string.split(' ')
                @trigram = Trigram.find_by_word1_and_word2_and_word3(string[0],string[1],string[2])
                if @trigram
                    @trigram.count = @trigram.count+1
                    @trigram.save
                else
                    @trigrams = Trigram.create!(:word1=> string[0],:word2 => string[1],:word3 => string[2])
                    @trigrams.save
                end
            end
        end
        flash[:info]="Success"
    end
end
