User.delete_all
Comment.delete_all
Crossword.delete_all

#Makes an admin User
u1 = User.create(:first_name => 'Dylan', :last_name => 'O\'Shea', :username => 'doshea', :email => 'dylan.j.oshea@gmail.com', :password => 'temp123', :password_confirmation => 'temp123')
u1.is_admin = true
u1.save

#Makes other users
u2 = User.create(:first_name => 'Andrew', :last_name => 'Locke', :username => 'alocke', :email => 'locke.andrew@gmail.com', :password => 'temp123', :password_confirmation => 'temp123')

cro1 = Crossword.create(:title => 'Interstellar Travel', :description => 'My cool puzzle', :rows => 15, :cols => 15)
cro2 = Crossword.create(:title => 'Rage Cage', :description => 'A puzzle for my friends', :rows => 15, :cols => 15)
u1.crosswords << cro2
u2.crosswords << cro1

com1 = Comment.create(:content => "Hi, I'm Andrew. This is the first comment...")
com2 = Comment.create(:content => "...and this is the second comment.")
u2.comments << com1 << com2
cro2.comments << com1 << com2