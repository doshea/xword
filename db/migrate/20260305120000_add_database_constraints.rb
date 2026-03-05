class AddDatabaseConstraints < ActiveRecord::Migration[8.1]
  def up
    # 1. Pre-flight: verify no duplicates exist on tables getting unique indexes
    dupes = execute("SELECT email FROM users GROUP BY email HAVING COUNT(*) > 1").to_a
    raise "Duplicate emails found: #{dupes.map { |d| d['email'] }}" if dupes.any?

    dupes = execute("SELECT username FROM users GROUP BY username HAVING COUNT(*) > 1").to_a
    raise "Duplicate usernames found: #{dupes.map { |d| d['username'] }}" if dupes.any?

    dupes = execute("SELECT content FROM words GROUP BY content HAVING COUNT(*) > 1").to_a
    raise "Duplicate words found: #{dupes.map { |d| d['content'] }}" if dupes.any?

    # 2. Drop dead table (model deleted in Phase 1 cleanup)
    drop_table :cell_edits

    # 3. Dedup id:false tables using ctid (safe for tables without a primary key)
    execute <<~SQL
      DELETE FROM friendships f1
      USING friendships f2
      WHERE f1.ctid > f2.ctid
        AND f1.user_id = f2.user_id
        AND f1.friend_id = f2.friend_id;
    SQL

    execute <<~SQL
      DELETE FROM friend_requests f1
      USING friend_requests f2
      WHERE f1.ctid > f2.ctid
        AND f1.sender_id = f2.sender_id
        AND f1.recipient_id = f2.recipient_id;
    SQL

    # 4. Add unique indexes
    add_index :users, :email, unique: true
    add_index :users, :username, unique: true
    add_index :friendships, [:user_id, :friend_id], unique: true,
              name: 'index_friendships_on_user_and_friend'
    add_index :friend_requests, [:sender_id, :recipient_id], unique: true,
              name: 'index_friend_requests_on_sender_and_recipient'
    add_index :words, :content, unique: true

    # 5. FK index for dependent: :destroy on triggered_notifications
    add_index :notifications, :actor_id, name: 'index_notifications_on_actor_id'

    # 6. Dedup personal solutions: keep the most recently updated row per (crossword, user)
    execute <<~SQL
      DELETE FROM solutions s1
      USING solutions s2
      WHERE s1.team = false AND s2.team = false
        AND s1.crossword_id = s2.crossword_id
        AND s1.user_id = s2.user_id
        AND s1.id < s2.id;
    SQL

    # Partial unique index: one personal solution per user per crossword
    add_index :solutions, [:crossword_id, :user_id],
              unique: true, where: "team = false",
              name: 'index_solutions_on_crossword_user_personal_unique'
  end

  def down
    remove_index :solutions, name: 'index_solutions_on_crossword_user_personal_unique', if_exists: true
    remove_index :notifications, name: 'index_notifications_on_actor_id', if_exists: true
    remove_index :words, :content, if_exists: true
    remove_index :friend_requests, name: 'index_friend_requests_on_sender_and_recipient', if_exists: true
    remove_index :friendships, name: 'index_friendships_on_user_and_friend', if_exists: true
    remove_index :users, :username, if_exists: true
    remove_index :users, :email, if_exists: true

    # Recreate cell_edits for rollback (data is permanently lost — table was dead)
    create_table :cell_edits do |t|
      t.text :across_clue_content
      t.integer :cell_id
      t.text :down_clue_content
      t.timestamps null: true
      t.index :cell_id
    end
  end
end
