Rails.application.routes.draw do
  root to: 'visitors#index'
  get '/seed/dictionary'
  get '/seed/bigrams'
  get '/seed/trigrams'
  get '/visitors/receive'
end
