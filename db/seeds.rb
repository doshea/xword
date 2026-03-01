puts "\nBEGINNING SEED"
puts "-------------"
seed_start_time = Time.now

# Delete in dependency order (children before parents) to avoid FK issues
puts "Deleting previous records..."
SolutionPartnering.delete_all
FavoritePuzzle.delete_all
Solution.delete_all
Comment.delete_all
Cell.delete_all
Clue.delete_all
Crossword.delete_all
User.delete_all
Word.delete_all
puts "Old records deleted."

# ─────────────────────────────────────────────────────────────────────────────
# USERS
# ─────────────────────────────────────────────────────────────────────────────
print "\nSeeding users..."

u1 = User.create!(
  first_name: 'Dylan', last_name: "O'Shea",
  username: 'doshea', email: 'dylan.j.oshea@gmail.com',
  password: 'qwerty', password_confirmation: 'qwerty'
)
u1.update_column(:is_admin, true)

u2 = User.create!(
  first_name: 'Andrew', last_name: 'Locke',
  username: 'alocke', email: 'locke.andrew@gmail.com',
  password: 'qwerty', password_confirmation: 'qwerty'
)

u3 = User.create!(
  first_name: 'Maria', last_name: 'Santos',
  username: 'msantos', email: 'maria.santos@example.com',
  password: 'qwerty', password_confirmation: 'qwerty'
)

u4 = User.create!(
  first_name: 'James', last_name: 'Chen',
  username: 'jchen', email: 'james.chen@example.com',
  password: 'qwerty', password_confirmation: 'qwerty'
)

u5 = User.create!(
  first_name: 'Sarah', last_name: 'Park',
  username: 'spark', email: 'sarah.park@example.com',
  password: 'qwerty', password_confirmation: 'qwerty'
)

puts " complete! (#{User.count} users)"

# ─────────────────────────────────────────────────────────────────────────────
# CROSSWORDS
# ─────────────────────────────────────────────────────────────────────────────
print "\nSeeding crosswords..."

# Crossword.create uses before_create :populate_letters, which fills letters with spaces.
# Never pass a `letters:` argument here — use set_contents after creation.
cro1 = Crossword.create!(title: 'Interstellar Travel', description: 'My cool puzzle', rows: 15, cols: 15)
cro2 = Crossword.create!(title: 'Rage Cage', description: 'A puzzle for my friends', rows: 15, cols: 15)
cro3 = Crossword.create!(title: 'Over the Rainbow', description: 'Work in progress', rows: 15, cols: 15)

u2.crosswords << cro1
u2.crosswords << cro3
u1.crosswords << cro2

puts " complete! (#{Crossword.count} crosswords)"

# ─────────────────────────────────────────────────────────────────────────────
# CROSSWORD CONTENTS
# ─────────────────────────────────────────────────────────────────────────────
print "\nSetting crossword contents..."

# 15x15 = 225 characters. '_' = black/void cell. All uppercase letters.
CRO1_LETTERS = 'ONION__AFT_CST_PANGE_DNAS_LOSTATORS_EDNA_OURSLONESTARCOUNTRY___SYDNEY_MEH__ABS__SSW_BASAL_NOOSE__SAR__SOBTRUELIE_WARMICEEAT__TAE__BEAKS_THAIS_MAS__NEO__HRS_IBERIA___BLACKSTARNATIONMANA_TERO_MOODYICON_ECGS_INTES_KIE_THO__TEASE'
CRO2_LETTERS = 'FIFA__SUEDE_PBRONIT_DITTOS_HEARAGECAGE_NOTREMALHEAR_RAINIER_ULTIMEMUT__GNI____REDASH_AROO_BOOTLEG_BEHOLDSOVA_PVN_LEE_OILOILOOIE_AWINGCO_NURX_SRSBRO____EMI__IATEDEMYO_WINEBAG_WOPPERPANASU_EMBOLISMFLU_ADORNS_ERGODKM_USESO__ALOT'

raise "CRO1 length wrong: #{CRO1_LETTERS.length}" unless CRO1_LETTERS.length == 225
raise "CRO2 length wrong: #{CRO2_LETTERS.length}" unless CRO2_LETTERS.length == 225

cro1.set_contents(CRO1_LETTERS)
cro2.set_contents(CRO2_LETTERS)
# cro3 stays with blank letters (work in progress)

cro1.number_cells
cro2.number_cells

puts " complete!"

# ─────────────────────────────────────────────────────────────────────────────
# CLUES — Interstellar Travel (cro1)
# ─────────────────────────────────────────────────────────────────────────────
print "\nSetting clues for 'Interstellar Travel'..."

cro1.set_clue(true,  1,  'Has layers, like 4-down, perhaps')
cro1.set_clue(true,  6,  'Towards the stern')
cro1.set_clue(true,  9,  'Concern of Chicago TV watchers')
cro1.set_clue(true,  12, 'West African machete')
cro1.set_clue(true,  13, 'Building blocks of uniqueness')
cro1.set_clue(true,  14, 'Hit 6-season TV series by JJ Abrams')
cro1.set_clue(true,  16, 'Suffix with alig- (pl.)')
cro1.set_clue(true,  17, 'Costume designer in *The Incredibles*')
cro1.set_clue(true,  18, 'Not yours anymore')
cro1.set_clue(true,  19, 'Liberia, slangily')
cro1.set_clue(true,  22, 'Host of the 2000 Summer Olympics')
cro1.set_clue(true,  23, '[*\'\'Not interested\'\'*]')
cro1.set_clue(true,  24, 'Stomach muscles')
cro1.set_clue(true,  27, 'Heading from Salt Lake to Los Angeles, say')
cro1.set_clue(true,  28, 'Bottom layer')
cro1.set_clue(true,  30, 'Final collar in the Wild West?')
cro1.set_clue(true,  33, 'Team that searches for lost sailors, abr.')
cro1.set_clue(true,  35, 'Weep hysterically')
cro1.set_clue(true,  37, 'Oxymoron #1')
cro1.set_clue(true,  40, 'Oxymoron #2')
cro1.set_clue(true,  43, 'Take in food')
cro1.set_clue(true,  44, '___-Bo')
cro1.set_clue(true,  46, 'Darwin focus in the Galapagos')
cro1.set_clue(true,  47, '10-Downs who you will meet if you continue on 26-Down\'s path')
cro1.set_clue(true,  50, 'See 71-Across')
cro1.set_clue(true,  53, 'Prefix with conservative or classical')
cro1.set_clue(true,  54, 'Ken Griffey Jr. stat.')
cro1.set_clue(true,  55, 'Spain and Portugal, collectively')
cro1.set_clue(true,  58, 'Ghana, slangily')
cro1.set_clue(true,  64, 'Magical power')
cro1.set_clue(true,  65, 'Installation and maintenance prefix')
cro1.set_clue(true,  66, 'Temperamental')
cro1.set_clue(true,  67, 'Madonna or Michael Jackson')
cro1.set_clue(true,  68, 'Electronic displays of heartbeats')
cro1.set_clue(true,  69, 'Guts, abr.')
cro1.set_clue(true,  70, 'When doubled, a New Zealand plant used for baskets')
cro1.set_clue(true,  71, 'With 50-Across, the name between 6- and 29-Down')
cro1.set_clue(true,  72, 'Poke fun at')

cro1.set_clue(false, 1,  'Semi-transparent gem')
cro1.set_clue(false, 2,  'Upper hemisphere grp. established in 1949')
cro1.set_clue(false, 3,  'Privy to')
cro1.set_clue(false, 4,  'Shrek, among others')
cro1.set_clue(false, 5,  'Nickname for Loch and 29-Down')
cro1.set_clue(false, 6,  'Jackson and 29-Down, among others')
cro1.set_clue(false, 7,  'Ornate')
cro1.set_clue(false, 8,  'With -Chuang, city in Eastern China')
cro1.set_clue(false, 9,  'Carbon copies')
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

puts " complete!"

# ─────────────────────────────────────────────────────────────────────────────
# SOLUTIONS — various completion states
# ─────────────────────────────────────────────────────────────────────────────
print "\nSeeding solutions..."

# Helper: blank solution string (spaces for letters, _ for void cells)
def blank_letters(crossword)
  crossword.letters.gsub(/[^_]/, ' ')
end

# Helper: partial solution (first N rows filled correctly, rest blank)
def partial_letters(crossword, filled_rows)
  chars_per_row = crossword.cols
  cutoff = filled_rows * chars_per_row
  crossword.letters[0...cutoff] + crossword.letters[cutoff..].gsub(/[^_]/, ' ')
end

# u1 (doshea) — solving cro1: first 4 rows filled in correctly
Solution.create!(
  user: u1, crossword: cro1,
  letters: partial_letters(cro1, 4)
)

# u3 (msantos) — solved cro1 completely
Solution.create!(
  user: u3, crossword: cro1,
  letters: CRO1_LETTERS   # check_completion callback marks is_complete: true automatically
)

# u4 (jchen) — just opened cro1, nothing entered yet
Solution.create!(
  user: u4, crossword: cro1,
  letters: blank_letters(cro1)
)

# u5 (spark) — solving cro1: first 7 rows filled in correctly
Solution.create!(
  user: u5, crossword: cro1,
  letters: partial_letters(cro1, 7)
)

# u2 (alocke) — solving cro2 (not their puzzle): partial (first 5 rows)
Solution.create!(
  user: u2, crossword: cro2,
  letters: partial_letters(cro2, 5)
)

# u3 (msantos) — solving cro2: just started
Solution.create!(
  user: u3, crossword: cro2,
  letters: blank_letters(cro2)
)

puts " complete! (#{Solution.count} solutions, #{Solution.complete.count} complete)"

# ─────────────────────────────────────────────────────────────────────────────
# FAVORITES
# ─────────────────────────────────────────────────────────────────────────────
print "\nSeeding favorites..."

FavoritePuzzle.create!(user: u1, crossword: cro1)
FavoritePuzzle.create!(user: u3, crossword: cro1)
FavoritePuzzle.create!(user: u4, crossword: cro1)
FavoritePuzzle.create!(user: u5, crossword: cro1)
FavoritePuzzle.create!(user: u3, crossword: cro2)
FavoritePuzzle.create!(user: u4, crossword: cro2)

puts " complete! (#{FavoritePuzzle.count} favorites)"

# ─────────────────────────────────────────────────────────────────────────────
# COMMENTS + REPLIES
# ─────────────────────────────────────────────────────────────────────────────
print "\nSeeding comments and replies..."

# Thread 1: question about the theme
com1 = Comment.create!(content: "Had a great time working on this puzzle — how did you come up with the theme?")
u1.comments  << com1
cro1.comments << com1

com1_reply = Comment.create!(content: "A whole lotta trial and error haha")
u2.comments << com1_reply
com1.replies << com1_reply

# Thread 2: asking for a hint
com2 = Comment.create!(content: "Totally stumped on 12-across — any hints without totally giving it away?")
u3.comments   << com2
cro1.comments << com2

com2_reply = Comment.create!(content: "Think geography — specifically West Africa 🌍")
u1.comments << com2_reply
com2.replies << com2_reply

# Thread 3: standalone praise
com3 = Comment.create!(content: "LONE STAR COUNTRY spanning the whole middle row — that's incredible construction!")
u4.comments   << com3
cro1.comments << com3

# Thread 4: on cro2
com4 = Comment.create!(content: "The HEAR/AGE/CAGE stack in the top-right is wild. Love it.")
u5.comments   << com4
cro2.comments << com4

puts " complete! (#{Comment.count} comments)"

puts "\n-------------"
puts "SEED COMPLETE"
puts "  Users:          #{User.count}"
puts "  Crosswords:     #{Crossword.count}"
puts "  Solutions:      #{Solution.count} (#{Solution.complete.count} complete)"
puts "  Favorites:      #{FavoritePuzzle.count}"
puts "  Comments:       #{Comment.count}"
puts "  Cells:          #{Cell.count}"
puts "  Clues:          #{Clue.count}"
puts "\nSeeding took ~ #{distance_of_time_in_words_to_now(seed_start_time, include_seconds: true)}"
