puts "\nBEGINNING SEED"
puts "-------------"
seed_start_time = Time.now

puts "Deleting previous records."
Cell.delete_all
Clue.delete_all
Comment.delete_all
Crossword.delete_all
Solution.delete_all
User.delete_all
Word.delete_all
puts "Old records deleted."

print "\nSeeding Users..."
#Makes an admin User
u1 = User.create(first_name: 'Dylan', last_name: 'O\'Shea', username: 'doshea', email: 'dylan.j.oshea@gmail.com', password: 'qwerty', password_confirmation: 'qwerty', remote_image_url: 'http://zooborns.typepad.com/photos/uncategorized/2008/10/13/red_panda_close_up.jpg')
u1.is_admin = true
u1.save

#Makes other users
u2 = User.create(first_name: 'Andrew', last_name: 'Locke', username: 'alocke', email: 'locke.andrew@gmail.com', password: 'qwerty', password_confirmation: 'qwerty', remote_image_url: 'http://imgur.com/zM7KTDd.jpg')
puts ' complete!'

nytimes = User.create(first_name: 'NYTimes', last_name: 'Crossword', username: 'nytimes', email: 'dylan.jc.oshea@gmail.com', password: 'qwerty', password_confirmation: 'qwerty', remote_image_url: 'http://a607.phobos.apple.com/us/r1000/081/Purple/v4/d8/8e/0b/d88e0ba0-6b83-ccbe-9a83-01f395a52940/mzl.odyharra.png')

print "\nSeeding incomplete crosswords..."
cro3 = Crossword.create(title: 'Over the Rainbow', description: 'My other puzzle', rows: 15, cols: 15, letters: 'abcd')
puts " complete!"

print "\nSeeding complete crosswords..."
#Makes a crossword with its full letters`
cro1 = Crossword.create(title: 'Interstellar Travel', description: 'My cool puzzle', rows: 15, cols: 15, published: true)
cro2 = Crossword.create(title: 'Rage Cage', description: 'A puzzle for my friends', rows: 15, cols: 15)
cro1.letters = 'ONION__AFT_CST_PANGE_DNAS_LOSTATORS_EDNA_OURSLONESTARCOUNTRY___SYDNEY_MEH__ABS__SSW_BASAL_NOOSE__SAR__SOBTRUELIE_WARMICEEAT__TAE__BEAKS_THAIS_MAS__NEO__HRS_IBERIA___BLACKSTARNATIONMANA_TERO_MOODYICON_ECGS_INTES_KIE_THO__TEASE'
cro1.save

print "\nLinking cells in complete puzzle..."
Crossword.all.each do |cw|
  cw.link_cells
end
puts " complete!"

cro1.set_letters('ONION  AFT CST PANGE DNAS LOSTATORS EDNA OURSLONESTARCOUNTRY   SYDNEY MEH  ABS  SSW BASAL NOOSE  SAR  SOBTRUELIE WARMICEEAT  TAE  BEAKS THAIS MAS  NEO  HRS IBERIA   BLACKSTARNATIONMANA TERO MOODYICON ECGS INTES KIE THO  TEASE')
cro2.set_letters('FIFA  SUEDE PBRONIT DITTOS HEARAGECAGE NOTREMALHEAR RAINIER ULTIMEMUT  GNI    REDASH AROO BOOTLEG BEHOLDSOVA PVN LEE OILOILOOIE AWINGCO NURX SRSBRO    EMI  IATEDEMYO WINEBAG WOPPERPANASU EMBOLISMFLU ADORNS ERGODKM USESO  ALOT')

cro1.number_cells
cro2.number_cells

cro1.set_clue(true, 1, 'Has layers, like 4-down, perhaps')
cro1.set_clue(true, 6, 'Towards the stern')
cro1.set_clue(true, 9, 'Concern of Chicago TV watchers')
cro1.set_clue(true, 12, 'West African machete')
cro1.set_clue(true, 13, 'Building blocks of uniqueness')
cro1.set_clue(true, 14, 'Hit 6-season TV series by JJ Abrams')
cro1.set_clue(true, 16, 'Suffix with alig- (pl.)')
cro1.set_clue(true, 17, 'Costume designer in *The Incredibles*')
cro1.set_clue(true, 18, 'Not yours anymore')
cro1.set_clue(true, 19, 'Liberia, slangily')
cro1.set_clue(true, 22, 'Host of the 2000 Summer Olympics')
cro1.set_clue(true, 23, '[*\'\'Not interested\'\'*]')
cro1.set_clue(true, 24, 'Stomach muscles')
cro1.set_clue(true, 27, 'Heading from Salt Lake to Los Angeles, say')
cro1.set_clue(true, 28, 'Bottom layer')
cro1.set_clue(true, 30, 'Final collar in the Wild West?')
cro1.set_clue(true, 33, 'Team that searches for lost sailors, abr.')
cro1.set_clue(true, 35, 'Weep hysterically')
cro1.set_clue(true, 37, 'Oxymoron #1')
cro1.set_clue(true, 40, 'Oxymoron #2')
cro1.set_clue(true, 43, 'Take in food')
cro1.set_clue(true, 44, '___-Bo')
cro1.set_clue(true, 46, 'Darwin focus in the Galapagos')
cro1.set_clue(true, 47, '10-Downs who you will meet if you continue on 26-Down\'s path')
cro1.set_clue(true, 50, 'See 71-Across')
cro1.set_clue(true, 53, 'Prefix with conservative or classical')
cro1.set_clue(true, 54, 'Ken Griffey Jr. stat.')
cro1.set_clue(true, 55, 'Spain and Portugal, collectively')
cro1.set_clue(true, 58, 'Ghana, slangily')
cro1.set_clue(true, 64, 'Magical power')
cro1.set_clue(true, 65, 'Installation and maintenance prefix')
cro1.set_clue(true, 66, 'Temperamental')
cro1.set_clue(true, 67, 'Madonna or Michael Jackson')
cro1.set_clue(true, 68, 'Electronic displays of heartbeats')
cro1.set_clue(true, 69, 'Guts, abr.')
cro1.set_clue(true, 70, 'When doubled, a New Zealand plant used for baskets')
cro1.set_clue(true, 71, 'With 50-Across, the name between 6- and 29-Down')
cro1.set_clue(true, 72, 'Poke fun at')

cro1.set_clue(false, 1, 'Semi-transparent gem')
cro1.set_clue(false, 2, 'Upper hemisphere grp. established in 1949')
cro1.set_clue(false, 3, 'Privy to')
cro1.set_clue(false, 4, 'Shrek, among others')
cro1.set_clue(false, 5, 'Nickname for Loch and 29-Down')
cro1.set_clue(false, 6, 'Jackson and 29-Down, among others')
cro1.set_clue(false, 7, 'Ornate')
cro1.set_clue(false, 8, 'With -Chuang, city in Eastern China')
cro1.set_clue(false, 9, 'Carbon copies')
cro1.set_clue(false, 10, 'One from Burma to Malaysia')
cro1.set_clue(false, 11, 'Train route across No. Mongolia and Rus.')
cro1.set_clue(false, 13, 'Heads of academic departments')
cro1.set_clue(false, 15, 'Suffix with ar- to describe many coffee shop faithful')
cro1.set_clue(false, 20, 'They\'re worth six in the N.F.L.')
cro1.set_clue(false, 21, 'Thurman of *Kill Bill*')
cro1.set_clue(false, 24, 'First step in a poker game')
cro1.set_clue(false, 25, 'Kazakhstani ambassador of movies')
cro1.set_clue(false, 26, 'On the Cambodian side of Vietnam\'s biggest city')
cro1.set_clue(false, 28, 'Women\'s underwear')
cro1.set_clue(false, 29, 'See 5-Down')
cro1.set_clue(false, 31, 'U-turn from N.W.')
cro1.set_clue(false, 32, '__ Dorado')
cro1.set_clue(false, 34, '*\'\'That\'s so cute!\'\'*')
cro1.set_clue(false, 36, 'Kiss, in Madrid')
cro1.set_clue(false, 38, '*\'\'___ a long story...\'\'*')
cro1.set_clue(false, 39, '\'\'__ Sports, It\'s in The Game\'\'')
cro1.set_clue(false, 41, '_&_ - Blues and Jazz genre')
cro1.set_clue(false, 42, 'Windows operating system in 2000')
cro1.set_clue(false, 45, 'U.S. policy towards Cuba, e.g.')
cro1.set_clue(false, 48, 'Mysterious')
cro1.set_clue(false, 49, 'Suffix with basil')
cro1.set_clue(false, 51, 'Things related to aviation')
cro1.set_clue(false, 52, 'Many hospital wrks.')
cro1.set_clue(false, 55, 'Apple products, more generally')
cro1.set_clue(false, 56, 'What one would say after getting tagged, say')
cro1.set_clue(false, 57, 'Make amends, with \'\'for\'\'')
cro1.set_clue(false, 58, 'Key stat. for athletes')
cro1.set_clue(false, 59, 'Be without')
cro1.set_clue(false, 60, '\'Let it stand\'')
cro1.set_clue(false, 61, 'Smallest bit')
cro1.set_clue(false, 62, 'Lyrical poems')
cro1.set_clue(false, 63, 'Where the bell-man may have trouble getting to work (these days)?')

print "\nOwning crosswords..."
u1.crosswords << cro2
u2.crosswords << cro1
u2.crosswords << cro3
puts " complete!"

print "\nSeeding comments and replies..."
com1 = Comment.create(content: "Had a great time working on this puzzle -- how did you come up with the theme?")
com2 = Comment.create(content: "A whole lotta trial and error haha")
u1.comments << com1
u2.comments << com2
cro1.comments << com1
com1.replies << com2
puts " complete!"

# print "\nPublishing complete puzzle..."
# cro1.publish!
# puts " complete!"

puts "\n-------------"
puts "SEED COMPLETE"
puts "\nSeeding took ~ #{distance_of_time_in_words_to_now(seed_start_time, true)}" #this line required an import of the DateHelper in the Rakefile