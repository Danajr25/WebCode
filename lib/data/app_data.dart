import '../models/question_model.dart';

// ─── IPSAS Pre-Test Questions (6 questions) ──────────────────────────────────

const List<IpsasQuestion> pretestQuestions = [
  IpsasQuestion(
    id: 'pre_1',
    text: 'I am confident in writing basic HTML structure (doctype, head, body).',
    category: 'HTML',
  ),
  IpsasQuestion(
    id: 'pre_2',
    text: 'I can apply CSS styles to change the appearance of a webpage.',
    category: 'CSS',
  ),
  IpsasQuestion(
    id: 'pre_3',
    text: 'I understand the basics of JavaScript (variables, functions, events).',
    category: 'JavaScript',
  ),
  IpsasQuestion(
    id: 'pre_4',
    text: 'I can identify and fix simple errors in web code.',
    category: 'Debugging',
  ),
  IpsasQuestion(
    id: 'pre_5',
    text: 'I can break down a web programming problem and find a solution.',
    category: 'Problem Solving',
  ),
  IpsasQuestion(
    id: 'pre_6',
    text: 'Overall, I feel confident about my web programming skills.',
    category: 'Confidence',
  ),
];

// ─── IPSAS Post-Test Questions (10 questions) ─────────────────────────────────

const List<IpsasQuestion> posttestQuestions = [
  IpsasQuestion(
    id: 'post_1',
    text: 'I am confident in writing basic HTML structure (doctype, head, body).',
    category: 'HTML',
  ),
  IpsasQuestion(
    id: 'post_2',
    text: 'I can apply CSS styles to change the appearance of a webpage.',
    category: 'CSS',
  ),
  IpsasQuestion(
    id: 'post_3',
    text: 'I understand the basics of JavaScript (variables, functions, events).',
    category: 'JavaScript',
  ),
  IpsasQuestion(
    id: 'post_4',
    text: 'I can identify and fix simple errors in web code.',
    category: 'Debugging',
  ),
  IpsasQuestion(
    id: 'post_5',
    text: 'I can break down a web programming problem and find a solution.',
    category: 'Problem Solving',
  ),
  IpsasQuestion(
    id: 'post_6',
    text: 'Overall, I feel confident about my web programming skills.',
    category: 'Confidence',
  ),
  IpsasQuestion(
    id: 'post_7',
    text: 'I can create a complete HTML page with proper tags and structure.',
    category: 'HTML',
  ),
  IpsasQuestion(
    id: 'post_8',
    text: 'I can use CSS selectors to target specific elements on a page.',
    category: 'CSS',
  ),
  IpsasQuestion(
    id: 'post_9',
    text: 'I can write a JavaScript function that responds to user interaction.',
    category: 'JavaScript',
  ),
  IpsasQuestion(
    id: 'post_10',
    text: 'I feel ready to build simple web projects on my own.',
    category: 'Confidence',
  ),
];

// ─── Determine level from IPSAS score ────────────────────────────────────────

String getLevelFromScore(int score, int maxScore) {
  final double pct = score / maxScore;
  if (pct < 0.5) return 'beginner';
  if (pct < 0.75) return 'intermediate';
  return 'advanced';
}

int getStartingLevelIndex(String level) {
  switch (level) {
    case 'intermediate':
      return 1;
    case 'advanced':
      return 2;
    default:
      return 0;
  }
}

// ─── Quest Levels ─────────────────────────────────────────────────────────────

const List<QuestLevel> questLevels = [
  QuestLevel(
    id: 'html',
    name: 'HTML Village',
    subtitle: 'Foundation of the Web',
    icon: '🏘️',
    description: 'Master the building blocks of every webpage — tags, structure, and semantics.',
    xpReward: 500,
    color: '#E44D26',
  ),
  QuestLevel(
    id: 'css',
    name: 'CSS Forest',
    subtitle: 'Style & Beauty',
    icon: '🌲',
    description: 'Transform plain HTML into beautiful designs with colors, layouts, and animations.',
    xpReward: 750,
    color: '#264DE4',
  ),
  QuestLevel(
    id: 'js',
    name: 'JavaScript Cave',
    subtitle: 'Power & Interactivity',
    icon: '⚡',
    description: 'Bring your webpages to life with logic, events, and dynamic interactions.',
    xpReward: 1000,
    color: '#F7DF1E',
  ),
];

// ─── Quiz Questions ───────────────────────────────────────────────────────────

const List<QuizQuestion> htmlQuizQuestions = [
  QuizQuestion(
    id: 'html_q1',
    levelId: 'html',
    question: 'What does HTML stand for?',
    options: [
      'Hyper Text Markup Language',
      'Home Tool Markup Language',
      'Hyperlinks and Text Markup Language',
      'High-level Text Making Language',
    ],
    correctIndex: 0,
    hint: 'Think about what HTML does — it marks up (structures) text on the web.',
    explanation: 'HTML stands for Hyper Text Markup Language. It is the standard language for creating webpages.',
  ),
  QuizQuestion(
    id: 'html_q2',
    levelId: 'html',
    question: 'Which tag is used for the largest heading in HTML?',
    options: ['<heading>', '<h6>', '<h1>', '<head>'],
    correctIndex: 2,
    hint: 'Heading tags go from h1 (largest) to h6 (smallest).',
    explanation: '<h1> is the largest heading tag. Headings range from <h1> to <h6>.',
  ),
  QuizQuestion(
    id: 'html_q3',
    levelId: 'html',
    question: 'Which attribute is used to specify the URL of an image?',
    options: ['href', 'link', 'src', 'url'],
    correctIndex: 2,
    hint: 'This attribute is also used in <script> and <iframe> tags.',
    explanation: 'The "src" attribute specifies the source URL of an image in the <img> tag.',
  ),
  QuizQuestion(
    id: 'html_q4',
    levelId: 'html',
    question: 'Which HTML tag creates a hyperlink?',
    options: ['<link>', '<a>', '<href>', '<url>'],
    correctIndex: 1,
    hint: 'This tag uses the "href" attribute to define the destination.',
    explanation: 'The <a> (anchor) tag creates hyperlinks. Example: <a href="url">text</a>',
  ),
  QuizQuestion(
    id: 'html_q5',
    levelId: 'html',
    question: 'What does the <p> tag represent in HTML?',
    options: ['Page', 'Paragraph', 'Position', 'Primary'],
    correctIndex: 1,
    hint: 'It\'s used to group sentences that form a block of text.',
    explanation: 'The <p> tag defines a paragraph. Browsers automatically add space before and after it.',
  ),
];

const List<QuizQuestion> cssQuizQuestions = [
  QuizQuestion(
    id: 'css_q1',
    levelId: 'css',
    question: 'Which CSS property is used to change the text color?',
    options: ['text-color', 'font-color', 'color', 'foreground'],
    correctIndex: 2,
    hint: 'It\'s a single simple word — not a compound property.',
    explanation: 'The "color" property sets the text color. Example: color: red;',
  ),
  QuizQuestion(
    id: 'css_q2',
    levelId: 'css',
    question: 'How do you select an element with id="main" in CSS?',
    options: ['.main', '*main', '#main', 'main'],
    correctIndex: 2,
    hint: 'ID selectors use a special symbol prefix.',
    explanation: 'Use # to select by id. Example: #main { color: blue; }',
  ),
  QuizQuestion(
    id: 'css_q3',
    levelId: 'css',
    question: 'Which CSS property controls the font size?',
    options: ['text-size', 'font-size', 'text-style', 'letter-size'],
    correctIndex: 1,
    hint: 'Think: font → the typeface, size → how big it is.',
    explanation: 'font-size controls how large the text appears. Example: font-size: 16px;',
  ),
  QuizQuestion(
    id: 'css_q4',
    levelId: 'css',
    question: 'Which property makes an element\'s background blue?',
    options: ['color: blue', 'bg-color: blue', 'background-color: blue', 'fill: blue'],
    correctIndex: 2,
    hint: 'It\'s a compound property that specifically targets the background.',
    explanation: 'background-color sets the background. Example: background-color: blue;',
  ),
  QuizQuestion(
    id: 'css_q5',
    levelId: 'css',
    question: 'How do you make text bold using CSS?',
    options: [
      'font-weight: bold',
      'text-style: bold',
      'font-bold: true',
      'text-weight: heavy',
    ],
    correctIndex: 0,
    hint: 'The property name relates to how "heavy" the font strokes are.',
    explanation: 'font-weight: bold makes text bold. You can also use font-weight: 700.',
  ),
];

const List<QuizQuestion> jsQuizQuestions = [
  QuizQuestion(
    id: 'js_q1',
    levelId: 'js',
    question: 'Which keyword declares a variable in modern JavaScript?',
    options: ['var', 'let', 'const', 'Both let and const'],
    correctIndex: 3,
    hint: 'Modern JS introduced two new keywords in ES6 for this purpose.',
    explanation: 'Both "let" and "const" are modern ways to declare variables. "let" allows reassignment; "const" does not.',
  ),
  QuizQuestion(
    id: 'js_q2',
    levelId: 'js',
    question: 'Which method writes a message to the browser console?',
    options: ['console.write()', 'console.log()', 'console.print()', 'log.console()'],
    correctIndex: 1,
    hint: 'Developers use this constantly while debugging.',
    explanation: 'console.log() outputs messages to the browser\'s developer console.',
  ),
  QuizQuestion(
    id: 'js_q3',
    levelId: 'js',
    question: 'How do you define a function in JavaScript?',
    options: [
      'function myFunc() {}',
      'def myFunc() {}',
      'func myFunc() {}',
      'create myFunc() {}',
    ],
    correctIndex: 0,
    hint: 'JavaScript uses a specific English keyword followed by the function name.',
    explanation: 'Use the "function" keyword. Example: function myFunc() { // code }',
  ),
  QuizQuestion(
    id: 'js_q4',
    levelId: 'js',
    question: 'Which operator checks for strict equality (value AND type)?',
    options: ['==', '=', '===', '!='],
    correctIndex: 2,
    hint: 'It uses three characters and is stricter than its two-character sibling.',
    explanation: '=== checks both value and type. "5" == 5 is true, but "5" === 5 is false.',
  ),
  QuizQuestion(
    id: 'js_q5',
    levelId: 'js',
    question: 'How do you add a click event listener to a button?',
    options: [
      'button.onClick()',
      'button.addEvent("click", fn)',
      'button.addEventListener("click", fn)',
      'button.on("click", fn)',
    ],
    correctIndex: 2,
    hint: 'The method name literally says "add event listener".',
    explanation: 'addEventListener("click", fn) attaches a click handler to any DOM element.',
  ),
];

Map<String, List<QuizQuestion>> get allQuestions => {
      'html': htmlQuizQuestions,
      'css': cssQuizQuestions,
      'js': jsQuizQuestions,
    };

// ─── Code Challenges ──────────────────────────────────────────────────────────

const List<CodeChallenge> codeChallenges = [
  CodeChallenge(
    id: 'html_challenge',
    levelId: 'html',
    title: 'Build Your First Webpage',
    mission:
        'Create a simple webpage with a main heading that says "Hello, Web!" and a paragraph below it that says "My first webpage is awesome!"',
    language: 'html',
    starterCode: '''<!DOCTYPE html>
<html>
  <head>
    <title>My Page</title>
  </head>
  <body>
    <!-- Write your heading and paragraph here -->

  </body>
</html>''',
    expectedOutput: 'Heading: "Hello, Web!"\nParagraph: "My first webpage is awesome!"',
    hint: 'Use the <h1> tag for the heading and <p> tag for the paragraph.',
    validationKeywords: ['<h1>', 'Hello, Web!', '<p>', 'My first webpage is awesome!'],
  ),
  CodeChallenge(
    id: 'css_challenge',
    levelId: 'css',
    title: 'Style the Box',
    mission:
        'Style the <div> with class "box" so it has: background-color of #7C6FFF, text color of white, font-size of 20px, and padding of 16px.',
    language: 'css',
    starterCode: '''/* Style the .box class */
.box {
  /* Add your styles here */

}''',
    expectedOutput: 'background-color: #7C6FFF\ncolor: white\nfont-size: 20px\npadding: 16px',
    hint: 'Each CSS rule is written as: property: value; — don\'t forget the semicolons!',
    validationKeywords: ['background-color', '#7C6FFF', 'color', 'white', 'font-size', '20px', 'padding', '16px'],
  ),
  CodeChallenge(
    id: 'js_challenge',
    levelId: 'js',
    title: 'Make It Interactive',
    mission:
        'Write a JavaScript function called "greet" that uses alert() to show the message "Hello, World!" and then call the function.',
    language: 'javascript',
    starterCode: '''// Write your greet function here

''',
    expectedOutput: 'Function "greet" defined\nalert("Hello, World!") called',
    hint: 'Define the function with "function greet()" then call it by typing "greet();"',
    validationKeywords: ['function', 'greet', 'alert', 'Hello, World!'],
  ),
];

CodeChallenge getChallengeForLevel(String levelId) {
  return codeChallenges.firstWhere(
    (c) => c.levelId == levelId,
    orElse: () => codeChallenges.first,
  );
}
