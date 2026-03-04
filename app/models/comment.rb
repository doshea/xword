# == Schema Information
#
# Table name: comments
#
#  id              :integer          not null, primary key
#  content         :text             not null
#  flagged         :boolean          default(FALSE), not null
#  user_id         :integer
#  crossword_id    :integer
#  base_comment_id :integer
#  created_at      :datetime
#  updated_at      :datetime
#

class Comment < ApplicationRecord
  include ActionView::Helpers::DateHelper

  belongs_to :user, inverse_of: :comments, optional: true
  belongs_to :crossword, inverse_of: :comments, optional: true
  belongs_to :base_comment, class_name: 'Comment', inverse_of: :replies, optional: true
  has_many :replies, class_name: 'Comment', foreign_key: 'base_comment_id', dependent: :destroy

  validates :content, presence: true, length: { maximum: 10_000 }

  scope :order_recent, -> {order created_at: :desc}

  MAX_PER_CROSSWORD = 50

  self.per_page = 50

  # Template vocabulary for generating random wine-tasting-style placeholder comments.
  WINE_VOCAB = {
    advs:[
      'freakishly','longingly','forcefully','morally'
    ],
    adjs: [
      'acidic','arcane','aggressive','atomic','bashful','brackish','complex','dainty','dried','evil','elegant','fat','fleshy','french-oaked','focused','forceful','hopeful','intense','lackluster','light','middle-aged','musty','overdone','putrid','ripe','roasted','semi-weak','salted','smoked','supple','strong','strong-willed','stunning','sugary','superior','weak','wicked','yellowed'
    ],
    nouns: [
      'acid','american oak','apple','bacon','banana','beef','berry','blackberry','black-cherry','blueberry','candy','cardboard','cassis','celery','chutney','cigarbox','clay','cocoa','coffee','fig','fir','fruit punch','garlic','herbs','honey','jam','lemon rind','lime','loganberry','mango','meat','melon','mocha','orange peel','papaya','pear','peach-pit','pepper','prune juice','rye','salad','spice','strawberry','tangerine','tea notes','tobacco','thyme','vanilla'
    ],
    amts: [
      'aromas','essences','hints','traces','whispers'
    ],
    starts: [
      '',
      '*adv bites you with ',
      '*amt of ',
      'attacks with ',
      'begins with ',
      'contains ',
      'displays ',
      'forces ',
      'hits you with ',
      'kicks you with ',
      'opens with ',
      'reminds one of ',
      'resembles ',
      'spews ',
      'starts with ',
      'throws out '
    ],
    lists: [
      '*adj *noun, *adj *noun and *adj *noun',
      '*noun, *adj and *adj *noun and *adj *noun',
      '*noun, *adj *noun and *adj *noun',
      '*noun, *adv *adj *noun and *amt of *adj *noun',
      '*noun, *adj *adj *noun and *adj *noun',
      '*noun, *adj *noun and *adj *amt of *noun',
      '*noun, *adj *noun and total absence of *noun'
    ]
  }.freeze

  def format_for_api
    acceptable_keys = [:content, :flagged, :created_at, :updated_at]
    hash = attributes.symbolize_keys.delete_if{|k,v| !k.in? acceptable_keys}
    hash[:commenter] = user&.username
    hash[:reply_count] = replies.count
    hash[:replies] = replies.map{|r| r.format_for_api}
    hash
  end

  def self.random_wine_comment
    structure = WINE_VOCAB[:starts].sample + WINE_VOCAB[:lists].sample
    structure.gsub(/\*adv/){|a| WINE_VOCAB[:advs].sample}.gsub(/\*adj/){|a| WINE_VOCAB[:adjs].sample}.gsub(/\*noun/){|a| WINE_VOCAB[:nouns].sample}.gsub(/\*amt/){|a| WINE_VOCAB[:amts].sample}.humanize + '...'
  end

  # Walks up the reply chain to find the root comment's crossword.
  # Replies don't store crossword_id directly; only top-level comments do.
  def base_crossword
    temp_cw = crossword
    temp_comment = self
    seen = Set.new([id])
    while temp_cw.nil?
      temp_comment = temp_comment.base_comment
      break if temp_comment.nil? || seen.include?(temp_comment.id)
      seen.add(temp_comment.id)
      temp_cw = temp_comment.crossword
    end
    temp_cw
  end

  def created_ago
    "#{time_ago_in_words(created_at)} ago"
  end

end
