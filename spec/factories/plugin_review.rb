Factory.define :plugin_review do |o|
  o.association   :record, :factory => :item
  o.association   :user, :factory => :user
  o.is_approved   "1"
  o.review_score  3.5
  o.review        "This is a test review, this is really, really, good. I'm so happy I oculd write this, thank you!"
  o.useful_score  10
  o.vote_score    11
end