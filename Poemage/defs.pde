/*boolean multiDefs(String wrd){
 boolean var = false;
 String base = "http://www.merriam-webster.com/dictionary/";
 wrd = wrd.replaceAll("[.,;:()?-]", "");
 String word = wrd.toLowerCase();
 
 if(loadStrings(base + word) == null){
 return var;
 } else {
 String[] test = loadStrings(base + word);
 for(int i = 950; i < 1350; i++){
 if(test[i].indexOf(word + "[2]") != -1){
 return var = true;
 } 
 }
 return var;
 }
 }
 }*/


//Load existing rules
void addExistingRules() {
 existingRules.add(new rhymerule("Identical Rhyme/Rhyme Riche", "[... - O N C^ - ...]"));
  existingRules.add(new rhymerule("Perfect Masculine", "... - O [N C]'"));
  existingRules.add(new rhymerule("Perfect Feminine", "... - O [N C' - O N C]"));
  existingRules.add(new rhymerule("Perfect Dactylic", "... - O [N C' - O N C - O N C]"));
  existingRules.add(new rhymerule("Semirhyme", "... - O [N C]' & ... - O [N][C]' - [O] N C"));
  existingRules.add(new rhymerule("Syllabic Rhyme", "... - O [N C]' & ... - O [N C]"));
  existingRules.add(new rhymerule("Consonant Slant Rhyme", "... - O N [C`]' - ..."));
  existingRules.add(new rhymerule("Vowel Slant Rhyme", "... - O [N] C' - ..."));
  existingRules.add(new rhymerule("Pararhyme", "... - [O`] N [C`]' - ..."));
  existingRules.add(new rhymerule("Syllabic 2 Rhyme", "O [N C]' - ..."));
  //existingRules.add(new rhymerule("Imperfect consonant slant", "... - O N ~[C]' - ..."));
  existingRules.add(new rhymerule("Alliteration", "...-[O] N C'-..."));
  existingRules.add(new rhymerule("Assonance", "...-O [N] C^-..."));
  existingRules.add(new rhymerule("Consonance", "...-[O]|[C]^-..."));
  existingRules.add(new rhymerule("Forced Rhyme", "...-O [N C`_{mv}]'-..."));
  existingRules.add(new rhymerule("Phonetic Alliteration", "...-[O_{p}] N C'-..."));
  existingRules.add(new rhymerule("Phonetic Assonance", "...-O [N_{p}] C^-..."));
  existingRules.add(new rhymerule("single character", "...[Y]..."));
  existingRules.add(new rhymerule("Eye rhyme", "...[A'...]"));
  existingRules.add(new rhymerule("2-char cluster", "...[YY]..."));
  existingRules.add(new rhymerule("mixed 2-char cluster", "...[YY]*..."));
  existingRules.add(new rhymerule("3-char cluster", "...[YYY]..."));
  existingRules.add(new rhymerule("mixed 3-char cluster", "...[YYY]*..."));
  existingRules.add(new rhymerule("4-char cluster", "...[YYYY]..."));
  existingRules.add(new rhymerule("mixed 4-char cluster", "...[YYYY]*..."));
  existingRules.add(new rhymerule("Anagram", "[...YY...]*"));
  rules.addAll(existingRules);
  println("RULES: "+rules.size());
}

/*existingRules.add(new rhymerule("Identical Rhyme/Rhyme Riche","[... - O N C^ - ...]"));
 existingRules.add(new rhymerule("Perfect Masculine","...O [N C]'"));
 existingRules.add(new rhymerule("Perfect Feminine","...O [N C' - O N C]"));
 existingRules.add(new rhymerule("Perfect Dactylic","...O [N C' - O N C - O N C]"));
 existingRules.add(new rhymerule("Semirhyme","...O [N C]' & ...O [N C]' - O N C"));
 existingRules.add(new rhymerule("Syllabic Rhyme","...O [N C]' & ...O [N C]"));
 existingRules.add(new rhymerule("Consonant Slant Rhyme","...O N [C]'..."));
 existingRules.add(new rhymerule("Vowel Slant Rhyme","...O [N] C'..."));
 existingRules.add(new rhymerule("Pararhyme","...[O] N [C]'..."));
 existingRules.add(new rhymerule("Syllabic 2 Rhyme","O [N C]'..."));
 existingRules.add(new rhymerule("Imperfect consonant slant","...O N ~[C]'..."));
 existingRules.add(new rhymerule("Char cluster 2","...[YY]..."));
 existingRules.add(new rhymerule("Char cluster 2 mixed","...[YY]*..."));*/


