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
cro1.letters = ['ONION__AFT_CST_PANGE_DNAS_LOSTATORS_EDNA_OURSLONESTARCOUNTRY___SYDNEY_MEH__ABS__SSW_BASAL_NOOSE__SAR__SOBTRUELIE_WARMICEEAT__TAE__BEAKS_THAIS_MAS__NEO__HRS_IBERIA___BLACKSTARNATIONMANA_TERO_MOODYICON_ECGS_INTES_KIE_THO__TEASE'];

cro2 = Crossword.create(:title => 'Rage Cage', :description => 'A puzzle for my friends', :rows => 15, :cols => 15)
u1.crosswords << cro2
u2.crosswords << cro1

com1 = Comment.create(:content => "Hi, I'm Andrew. This is the first comment...")
com2 = Comment.create(:content => "...and this is the second comment.")
u2.comments << com1 << com2
cro2.comments << com1 << com2

#Trying to add serialized fields
cro3 = Crossword.create(:title => 'Over the Rainbow', :description => 'My other puzzle', :rows => 15, :cols => 15, :letters => ['abcd'], :gridnums => [0,0,1,0,0,0,2,0,0,0,3])
u2.crosswords << cro3




cro1_clues = [
  c1 = Clue.create(:content => 'Towards the stern'),
  c2 = Clue.create(:content => 'Jackson and 29-Down, among others'),
  c3 = Clue.create(:content => 'Ornate'),
  c4 = Clue.create(:content => 'With -Chuang, city in Eastern China'),
  c5 = Clue.create(:content => 'Concern of Chicago TV watchers'),
  c6 = Clue.create(:content => 'Carbon copies'),
  c7 = Clue.create(:content => 'One from Burma to Malaysia'),
  c8 = Clue.create(:content => 'Train route across No. Mongolia and Rus.'),
  c9 = Clue.create(:content => 'West African machete'),
  c10 = Clue.create(:content => 'Building blocks of uniqueness'),
  c11 = Clue.create(:content => 'Heads of academic departments'),
  c12 = Clue.create(:content => 'Hit 6-season TV series by JJ Abrams'),
  c13 = Clue.create(:content => 'Suffix with ar- to describe many coffee shop faithful'),
  c14 = Clue.create(:content => 'Suffix with alig- (pl.)'),
  c15 = Clue.create(:content => 'Costume designer in <em>The Incredibles</em>'),
  c16 = Clue.create(:content => 'Not yours anymore'),
  c17 = Clue.create(:content => 'Liberia, slangily'),
  c18 = Clue.create(:content => 'They\'re worth six in the N.F.L.'),
  c19 = Clue.create(:content => 'Thurman of <em>Kill Bill</em>'),
  c20 = Clue.create(:content => 'Host of the 2000 Summer Olympics'),
  c21 = Clue.create(:content => '[<em>\'\'Not interested\'\'</em>]'),
  c22 = Clue.create(:content => 'Stomach muscles'),
  c23 = Clue.create(:content => 'First step in a poker game'),
  c24 = Clue.create(:content => 'Kazakhstani ambassador of movies'),
  c25 = Clue.create(:content => 'On the Cambodian side of Vietnam\'s biggest city'),
  c26 = Clue.create(:content => 'Heading from Salt Lake to Los Angeles, say'),
  c27 = Clue.create(:content => 'Bottom layer'),
  c28 = Clue.create(:content => 'Woman\'s underwear'),
  c29 = Clue.create(:content => 'See 5-Down'),
  c30 = Clue.create(:content => 'Final collar in the Wild West?'),
  c31 = Clue.create(:content => 'U-turn from N.W.'),
  c32 = Clue.create(:content => '__ Dorado'),
  c33 = Clue.create(:content => 'Team that searches for lost sailors, abr.'),
  c34 = Clue.create(:content => '<em>\'\'That\'s so cute!\'\'</em>'),
  c35 = Clue.create(:content => 'Weep hysterically'),
  c36 = Clue.create(:content => 'Kiss, in Madrid'),
  c37 = Clue.create(:content => 'Oxymoron #1'),
  c38 = Clue.create(:content => '<em>\'\'___ a long story...\'\'</em>'),
  c39 = Clue.create(:content => '\'\'__ Sports, It\'s in The Game\'\''),
  c40 = Clue.create(:content => 'Oxymoron #2'),
  c41 = Clue.create(:content => 'Has layers, like 4-down, perhaps'),
  c42 = Clue.create(:content => 'Semi-transparent gem'),
  c43 = Clue.create(:content => 'Upper hemisphere grp. established in 1949'),
  c44 = Clue.create(:content => 'Privy to'),
  c45 = Clue.create(:content => 'Shrek, among others'),
  c46 = Clue.create(:content => 'Nickname for Loch and 29-Down'),
  c47 = Clue.create(:content => '_&_ - Blues and Jazz genre'),
  c48 = Clue.create(:content => 'Windows operating system in 2000'),
  c49 = Clue.create(:content => 'Take in food'),
  c50 = Clue.create(:content => '___-Bo'),
  c51 = Clue.create(:content => 'U.S. policy towards Cuba, e.g.'),
  c52 = Clue.create(:content => 'Darwin focus in the Galapagos'),
  c53 = Clue.create(:content => '10-Downs who you will meet if you continue on 26-Down\'s path'),
  c54 = Clue.create(:content => 'Mysterious'),
  c55 = Clue.create(:content => 'Suffix with basil'),
  c56 = Clue.create(:content => 'See 71-Across'),
  c57 = Clue.create(:content => 'Things related to aviation'),
  c58 = Clue.create(:content => 'Many hospital wrks.'),
  c59 = Clue.create(:content => 'Prefix with conservative or classical'),
  c60 = Clue.create(:content => 'Ken Griffey Jr. stat.'),
  c61 = Clue.create(:content => 'Spain and Portugal, collectively'),
  c62 = Clue.create(:content => 'Apple products, more generally'),
  c63 = Clue.create(:content => 'What one would say after getting tagged, say'),
  c64 = Clue.create(:content => 'Make amends, with \'\'for\'\''),
  c65 = Clue.create(:content => 'Ghana, slangily'),
  c66 = Clue.create(:content => 'Key stat. for athletes'),
  c67 = Clue.create(:content => 'Be without'),
  c68 = Clue.create(:content => '\'Let it stand\''),
  c69 = Clue.create(:content => 'Smallest bit'),
  c70 = Clue.create(:content => 'Lyrical poems'),
  c71 = Clue.create(:content => 'Where the bell-man may have trouble getting to work (these days)?'),
  c72 = Clue.create(:content => 'Magical power'),
  c73 = Clue.create(:content => 'Installation and maintenance prefix'),
  c74 = Clue.create(:content => 'Temperamental'),
  c75 = Clue.create(:content => 'Madonna or Michael Jackson'),
  c76 = Clue.create(:content => 'Electronic displays of heartbeats'),
  c77 = Clue.create(:content => 'Guts, abr.'),
  c78 = Clue.create(:content => 'When doubled, a New Zealand plant used for baskets'),
  c79 = Clue.create(:content => 'With 50-Across, the name between 6- and 29-Down'),
  c80 = Clue.create(:content => 'Poke fun at')
]
cro1.clues = cro1_clues