class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      t.integer  :user_id,           null: false  # recipient
      t.integer  :actor_id,          null: false  # who triggered it
      t.string   :notification_type, null: false
      t.string   :notifiable_type                 # polymorphic, nullable
      t.integer  :notifiable_id                   # polymorphic, nullable
      t.jsonb    :metadata,          null: false, default: {}
      t.datetime :read_at                         # null = unread

      t.timestamps
    end

    # Inbox: unread count + listing (user_id, read_at IS NULL, ordered by created_at)
    add_index :notifications, [:user_id, :read_at, :created_at],
              name: 'index_notifications_on_inbox'

    # Cleanup when notifiable is deleted
    add_index :notifications, [:notifiable_type, :notifiable_id],
              name: 'index_notifications_on_notifiable'

    # Dedup: one notification per (user, actor, type, notifiable)
    add_index :notifications,
              [:user_id, :actor_id, :notification_type, :notifiable_type, :notifiable_id],
              unique: true,
              name: 'index_notifications_on_dedup'

    # PostgreSQL treats NULLs as distinct in unique indexes.
    # friend_request / friend_accepted have nil notifiable — the above index
    # won't prevent duplicates. This partial index covers the NULL case.
    add_index :notifications,
              [:user_id, :actor_id, :notification_type],
              unique: true,
              where: 'notifiable_type IS NULL',
              name: 'index_notifications_on_dedup_no_notifiable'
  end
end
