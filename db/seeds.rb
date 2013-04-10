Clue.delete_all
ClueInstance.delete_all
Comment.delete_all
Crossword.delete_all
Solution.delete_all
User.delete_all
Word.delete_all

#Makes an admin User
u1 = User.create(:first_name => 'Dylan', :last_name => 'O\'Shea', :username => 'doshea', :email => 'dylan.j.oshea@gmail.com', :password => 'temp123', :password_confirmation => 'temp123')
u1.is_admin = true
u1.save

#Makes other users
u2 = User.create(:first_name => 'Andrew', :last_name => 'Locke', :username => 'alocke', :email => 'locke.andrew@gmail.com', :password => 'temp123', :password_confirmation => 'temp123')

#Makes a crossword with its full letters`
cro1 = Crossword.create(:title => 'Interstellar Travel', :description => 'My cool puzzle', :rows => 15, :cols => 15)
cro1.letters = 'ONION__AFT_CST_PANGE_DNAS_LOSTATORS_EDNA_OURSLONESTARCOUNTRY___SYDNEY_MEH__ABS__SSW_BASAL_NOOSE__SAR__SOBTRUELIE_WARMICEEAT__TAE__BEAKS_THAIS_MAS__NEO__HRS_IBERIA___BLACKSTARNATIONMANA_TERO_MOODYICON_ECGS_INTES_KIE_THO__TEASE'
cro1.save

cro2 = Crossword.create(:title => 'Rage Cage', :description => 'A puzzle for my friends', :rows => 15, :cols => 15)
u1.crosswords << cro2
u2.crosswords << cro1

com1 = Comment.create(:content => "Hi, I'm Andrew. This is the first comment...")
com2 = Comment.create(:content => "...and this is the second comment.")
u2.comments << com1 << com2
cro2.comments << com1 << com2

#Trying to add serialized fields
cro3 = Crossword.create(:title => 'Over the Rainbow', :description => 'My other puzzle', :rows => 15, :cols => 15, :letters => 'abcd', :gridnums => '00100020003')
u2.crosswords << cro3

#creates clues
cro1_clues = [
  c01a = Clue.create(:content => 'Has layers, like 4-down, perhaps'),
  c06a = Clue.create(:content => 'Towards the stern'),
  c09a = Clue.create(:content => 'Concern of Chicago TV watchers'),
  c12a = Clue.create(:content => 'West African machete'),
  c13a = Clue.create(:content => 'Building blocks of uniqueness'),
  c14a = Clue.create(:content => 'Hit 6-season TV series by JJ Abrams'),
  c16a = Clue.create(:content => 'Suffix with alig- (pl.)'),
  c17a = Clue.create(:content => 'Costume designer in <em>The Incredibles</em>'),
  c18a = Clue.create(:content => 'Not yours anymore'),
  c19a = Clue.create(:content => 'Liberia, slangily'),
  c22a = Clue.create(:content => 'Host of the 2000 Summer Olympics'),
  c23a = Clue.create(:content => '[<em>\'\'Not interested\'\'</em>]'),
  c24a = Clue.create(:content => 'Stomach muscles'),
  c27a = Clue.create(:content => 'Heading from Salt Lake to Los Angeles, say'),
  c28a = Clue.create(:content => 'Bottom layer'),
  c30a = Clue.create(:content => 'Final collar in the Wild West?'),
  c33a = Clue.create(:content => 'Team that searches for lost sailors, abr.'),
  c35a = Clue.create(:content => 'Weep hysterically'),
  c37a = Clue.create(:content => 'Oxymoron #1'),
  c40a = Clue.create(:content => 'Oxymoron #2'),
  c43a = Clue.create(:content => 'Take in food'),
  c44a = Clue.create(:content => '___-Bo'),
  c46a = Clue.create(:content => 'Darwin focus in the Galapagos'),
  c47a = Clue.create(:content => '10-Downs who you will meet if you continue on 26-Down\'s path'),
  c50a = Clue.create(:content => 'See 71-Across'),
  c53a = Clue.create(:content => 'Prefix with conservative or classical'),
  c54a = Clue.create(:content => 'Ken Griffey Jr. stat.'),
  c55a = Clue.create(:content => 'Spain and Portugal, collectively'),
  c58a = Clue.create(:content => 'Ghana, slangily'),
  c64a = Clue.create(:content => 'Magical power'),
  c65a = Clue.create(:content => 'Installation and maintenance prefix'),
  c66a = Clue.create(:content => 'Temperamental'),
  c67a = Clue.create(:content => 'Madonna or Michael Jackson'),
  c68a = Clue.create(:content => 'Electronic displays of heartbeats'),
  c69a = Clue.create(:content => 'Guts, abr.'),
  c70a = Clue.create(:content => 'When doubled, a New Zealand plant used for baskets'),
  c71a = Clue.create(:content => 'With 50-Across, the name between 6- and 29-Down'),
  c72a = Clue.create(:content => 'Poke fun at'),

  c01d = Clue.create(:content => 'Semi-transparent gem'),
  c02d = Clue.create(:content => 'Upper hemisphere grp. established in 1949'),
  c03d = Clue.create(:content => 'Privy to'),
  c04d = Clue.create(:content => 'Shrek, among others'),
  c05d = Clue.create(:content => 'Nickname for Loch and 29-Down'),
  c06d = Clue.create(:content => 'Jackson and 29-Down, among others'),
  c07d = Clue.create(:content => 'Ornate'),
  c08d = Clue.create(:content => 'With -Chuang, city in Eastern China'),
  c09d = Clue.create(:content => 'Carbon copies'),
  c10d = Clue.create(:content => 'One from Burma to Malaysia'),
  c11d = Clue.create(:content => 'Train route across No. Mongolia and Rus.'),
  c13d = Clue.create(:content => 'Heads of academic departments'),
  c15d = Clue.create(:content => 'Suffix with ar- to describe many coffee shop faithful'),
  c20d = Clue.create(:content => 'They\'re worth six in the N.F.L.'),
  c21d = Clue.create(:content => 'Thurman of <em>Kill Bill</em>'),
  c24d = Clue.create(:content => 'First step in a poker game'),
  c25d = Clue.create(:content => 'Kazakhstani ambassador of movies'),
  c26d = Clue.create(:content => 'On the Cambodian side of Vietnam\'s biggest city'),
  c28d = Clue.create(:content => 'Women\'s underwear'),
  c29d = Clue.create(:content => 'See 5-Down'),
  c31d = Clue.create(:content => 'U-turn from N.W.'),
  c32d = Clue.create(:content => '__ Dorado'),
  c34d = Clue.create(:content => '<em>\'\'That\'s so cute!\'\'</em>'),
  c36d = Clue.create(:content => 'Kiss, in Madrid'),
  c38d = Clue.create(:content => '<em>\'\'___ a long story...\'\'</em>'),
  c39d = Clue.create(:content => '\'\'__ Sports, It\'s in The Game\'\''),
  c41d = Clue.create(:content => '_&_ - Blues and Jazz genre'),
  c42d = Clue.create(:content => 'Windows operating system in 2000'),
  c45d = Clue.create(:content => 'U.S. policy towards Cuba, e.g.'),
  c48d = Clue.create(:content => 'Mysterious'),
  c49d = Clue.create(:content => 'Suffix with basil'),
  c51d = Clue.create(:content => 'Things related to aviation'),
  c52d = Clue.create(:content => 'Many hospital wrks.'),
  c55d = Clue.create(:content => 'Apple products, more generally'),
  c56d = Clue.create(:content => 'What one would say after getting tagged, say'),
  c57d = Clue.create(:content => 'Make amends, with \'\'for\'\''),
  c58d = Clue.create(:content => 'Key stat. for athletes'),
  c59d = Clue.create(:content => 'Be without'),
  c60d = Clue.create(:content => '\'Let it stand\''),
  c61d = Clue.create(:content => 'Smallest bit'),
  c62d = Clue.create(:content => 'Lyrical poems'),
  c63d = Clue.create(:content => 'Where the bell-man may have trouble getting to work (these days)?')
]

# creates clue instances
cro1_cis = [
  ci01a = ClueInstance.create(start_cell: 1, is_across: true),
  ci06a = ClueInstance.create(start_cell: 6, is_across: true),
  ci09a = ClueInstance.create(start_cell: 9, is_across: true),
  ci12a = ClueInstance.create(start_cell: 12, is_across: true),
  ci13a = ClueInstance.create(start_cell: 13, is_across: true),
  ci14a = ClueInstance.create(start_cell: 14, is_across: true),
  ci16a = ClueInstance.create(start_cell: 16, is_across: true),
  ci17a = ClueInstance.create(start_cell: 17, is_across: true),
  ci18a = ClueInstance.create(start_cell: 18, is_across: true),
  ci19a = ClueInstance.create(start_cell: 19, is_across: true),
  ci22a = ClueInstance.create(start_cell: 22, is_across: true),
  ci23a = ClueInstance.create(start_cell: 23, is_across: true),
  ci24a = ClueInstance.create(start_cell: 24, is_across: true),
  ci27a = ClueInstance.create(start_cell: 27, is_across: true),
  ci28a = ClueInstance.create(start_cell: 28, is_across: true),
  ci30a = ClueInstance.create(start_cell: 30, is_across: true),
  ci33a = ClueInstance.create(start_cell: 33, is_across: true),
  ci35a = ClueInstance.create(start_cell: 35, is_across: true),
  ci37a = ClueInstance.create(start_cell: 37, is_across: true),
  ci40a = ClueInstance.create(start_cell: 40, is_across: true),
  ci43a = ClueInstance.create(start_cell: 43, is_across: true),
  ci44a = ClueInstance.create(start_cell: 44, is_across: true),
  ci46a = ClueInstance.create(start_cell: 46, is_across: true),
  ci47a = ClueInstance.create(start_cell: 47, is_across: true),
  ci50a = ClueInstance.create(start_cell: 50, is_across: true),
  ci53a = ClueInstance.create(start_cell: 53, is_across: true),
  ci54a = ClueInstance.create(start_cell: 54, is_across: true),
  ci55a = ClueInstance.create(start_cell: 55, is_across: true),
  ci58a = ClueInstance.create(start_cell: 58, is_across: true),
  ci64a = ClueInstance.create(start_cell: 64, is_across: true),
  ci65a = ClueInstance.create(start_cell: 65, is_across: true),
  ci66a = ClueInstance.create(start_cell: 66, is_across: true),
  ci67a = ClueInstance.create(start_cell: 67, is_across: true),
  ci68a = ClueInstance.create(start_cell: 68, is_across: true),
  ci69a = ClueInstance.create(start_cell: 69, is_across: true),
  ci70a = ClueInstance.create(start_cell: 70, is_across: true),
  ci71a = ClueInstance.create(start_cell: 71, is_across: true),
  ci72a = ClueInstance.create(start_cell: 72, is_across: true),

  ci01d = ClueInstance.create(start_cell: 1, is_across: false),
  ci02d = ClueInstance.create(start_cell: 2, is_across: false),
  ci03d = ClueInstance.create(start_cell: 3, is_across: false),
  ci04d = ClueInstance.create(start_cell: 4, is_across: false),
  ci05d = ClueInstance.create(start_cell: 5, is_across: false),
  ci06d = ClueInstance.create(start_cell: 6, is_across: false),
  ci07d = ClueInstance.create(start_cell: 7, is_across: false),
  ci08d = ClueInstance.create(start_cell: 8, is_across: false),
  ci09d = ClueInstance.create(start_cell: 9, is_across: false),
  ci10d = ClueInstance.create(start_cell: 10, is_across: false),
  ci11d = ClueInstance.create(start_cell: 11, is_across: false),
  ci13d = ClueInstance.create(start_cell: 13, is_across: false),
  ci15d = ClueInstance.create(start_cell: 15, is_across: false),
  ci20d = ClueInstance.create(start_cell: 20, is_across: false),
  ci21d = ClueInstance.create(start_cell: 21, is_across: false),
  ci24d = ClueInstance.create(start_cell: 24, is_across: false),
  ci25d = ClueInstance.create(start_cell: 25, is_across: false),
  ci26d = ClueInstance.create(start_cell: 26, is_across: false),
  ci28d = ClueInstance.create(start_cell: 28, is_across: false),
  ci29d = ClueInstance.create(start_cell: 29, is_across: false),
  ci31d = ClueInstance.create(start_cell: 31, is_across: false),
  ci32d = ClueInstance.create(start_cell: 32, is_across: false),
  ci34d = ClueInstance.create(start_cell: 34, is_across: false),
  ci36d = ClueInstance.create(start_cell: 36, is_across: false),
  ci38d = ClueInstance.create(start_cell: 38, is_across: false),
  ci39d = ClueInstance.create(start_cell: 39, is_across: false),
  ci41d = ClueInstance.create(start_cell: 41, is_across: false),
  ci42d = ClueInstance.create(start_cell: 42, is_across: false),
  ci45d = ClueInstance.create(start_cell: 45, is_across: false),
  ci48d = ClueInstance.create(start_cell: 48, is_across: false),
  ci49d = ClueInstance.create(start_cell: 49, is_across: false),
  ci51d = ClueInstance.create(start_cell: 51, is_across: false),
  ci52d = ClueInstance.create(start_cell: 52, is_across: false),
  ci55d = ClueInstance.create(start_cell: 55, is_across: false),
  ci56d = ClueInstance.create(start_cell: 56, is_across: false),
  ci57d = ClueInstance.create(start_cell: 57, is_across: false),
  ci58d = ClueInstance.create(start_cell: 58, is_across: false),
  ci59d = ClueInstance.create(start_cell: 59, is_across: false),
  ci60d = ClueInstance.create(start_cell: 60, is_across: false),
  ci61d = ClueInstance.create(start_cell: 61, is_across: false),
  ci62d = ClueInstance.create(start_cell: 62, is_across: false),
  ci63d = ClueInstance.create(start_cell: 63, is_across: false)
]

# associates clue instances with clues
c01a.clue_instances << ci01a
c06a.clue_instances << ci06a
c09a.clue_instances << ci09a
c12a.clue_instances << ci12a
c13a.clue_instances << ci13a
c14a.clue_instances << ci14a
c16a.clue_instances << ci16a
c17a.clue_instances << ci17a
c18a.clue_instances << ci18a
c19a.clue_instances << ci19a
c22a.clue_instances << ci22a
c23a.clue_instances << ci23a
c24a.clue_instances << ci24a
c27a.clue_instances << ci27a
c28a.clue_instances << ci28a
c30a.clue_instances << ci30a
c33a.clue_instances << ci33a
c35a.clue_instances << ci35a
c37a.clue_instances << ci37a
c40a.clue_instances << ci40a
c43a.clue_instances << ci43a
c44a.clue_instances << ci44a
c46a.clue_instances << ci46a
c47a.clue_instances << ci47a
c50a.clue_instances << ci50a
c53a.clue_instances << ci53a
c54a.clue_instances << ci54a
c55a.clue_instances << ci55a
c58a.clue_instances << ci58a
c64a.clue_instances << ci64a
c65a.clue_instances << ci65a
c66a.clue_instances << ci66a
c67a.clue_instances << ci67a
c68a.clue_instances << ci68a
c69a.clue_instances << ci69a
c70a.clue_instances << ci70a
c71a.clue_instances << ci71a
c72a.clue_instances << ci72a

c01d.clue_instances << ci01d
c02d.clue_instances << ci02d
c03d.clue_instances << ci03d
c04d.clue_instances << ci04d
c05d.clue_instances << ci05d
c06d.clue_instances << ci06d
c07d.clue_instances << ci07d
c08d.clue_instances << ci08d
c09d.clue_instances << ci09d
c10d.clue_instances << ci10d
c11d.clue_instances << ci11d
c13d.clue_instances << ci13d
c15d.clue_instances << ci15d
c20d.clue_instances << ci20d
c21d.clue_instances << ci21d
c24d.clue_instances << ci24d
c25d.clue_instances << ci25d
c26d.clue_instances << ci26d
c28d.clue_instances << ci28d
c29d.clue_instances << ci29d
c31d.clue_instances << ci31d
c32d.clue_instances << ci32d
c34d.clue_instances << ci34d
c36d.clue_instances << ci36d
c38d.clue_instances << ci38d
c39d.clue_instances << ci39d
c41d.clue_instances << ci41d
c42d.clue_instances << ci42d
c45d.clue_instances << ci45d
c48d.clue_instances << ci48d
c49d.clue_instances << ci49d
c51d.clue_instances << ci51d
c52d.clue_instances << ci52d
c55d.clue_instances << ci55d
c56d.clue_instances << ci56d
c57d.clue_instances << ci57d
c58d.clue_instances << ci58d
c59d.clue_instances << ci59d
c60d.clue_instances << ci60d
c61d.clue_instances << ci61d
c62d.clue_instances << ci62d
c63d.clue_instances << ci63d

# associates clue instances with their crossword
cro1.clue_instances = cro1_cis
cro1.save