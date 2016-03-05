require 'csv'
require './lib/nanogram.rb'
class VisitorsController < ApplicationController
    def correct_words word
        word
    end
    def predict_word word
        word
    end
    def receive
        if params[:random_string].length > 0
            @random  = params[:random_string]
            flash[:info]="Success"
        else
            flash[:alert]="Enter a string!"
            redirect_to root_url
        end
        @predicted = predict_word @random
        @corrected = correct_words @random
    end

end
