FactoryBot.define do
  factory :notification do
    association :user
    association :actor, factory: :user
    notification_type { 'comment_on_puzzle' }
    metadata { {} }

    trait :friend_request do
      notification_type { 'friend_request' }
    end

    trait :friend_accepted do
      notification_type { 'friend_accepted' }
    end

    trait :puzzle_invite do
      notification_type { 'puzzle_invite' }
      association :notifiable, factory: :solution
    end

    trait :comment_on_puzzle do
      notification_type { 'comment_on_puzzle' }
      association :notifiable, factory: :comment
    end

    trait :comment_reply do
      notification_type { 'comment_reply' }
      association :notifiable, factory: :comment
    end

    trait :read do
      read_at { Time.current }
    end
  end
end
