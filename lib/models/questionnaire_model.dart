/// Questionnaire model for verifying Malayalee identity.
class QuestionnaireQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  const QuestionnaireQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}

/// All verification questions.
const List<QuestionnaireQuestion> malayaliQuestions = [
  QuestionnaireQuestion(
    question: 'What is the capital of Kerala?',
    options: ['Kochi', 'Thiruvananthapuram', 'Kozhikode', 'Thrissur'],
    correctIndex: 1,
  ),
  QuestionnaireQuestion(
    question: 'Which river is known as the "lifeline of Kerala"?',
    options: ['Bharathapuzha', 'Periyar', 'Chaliyar', 'Pamba'],
    correctIndex: 1,
  ),
  QuestionnaireQuestion(
    question: 'What is the traditional dance form of Kerala?',
    options: ['Bharatanatyam', 'Kathak', 'Kathakali', 'Kuchipudi'],
    correctIndex: 2,
  ),
  QuestionnaireQuestion(
    question: 'Which festival is celebrated as the harvest festival of Kerala?',
    options: ['Vishu', 'Onam', 'Thrissur Pooram', 'Thiruvathira'],
    correctIndex: 1,
  ),
  QuestionnaireQuestion(
    question: 'What does "Nanni" mean in Malayalam?',
    options: ['Hello', 'Goodbye', 'Thank you', 'Sorry'],
    correctIndex: 2,
  ),
  QuestionnaireQuestion(
    question: 'Which spice is Kerala most famous for producing?',
    options: ['Turmeric', 'Black Pepper', 'Cardamom', 'Cloves'],
    correctIndex: 1,
  ),
  QuestionnaireQuestion(
    question: 'What is "Sadhya"?',
    options: [
      'A Kerala temple festival',
      'A traditional Kerala feast served on banana leaf',
      'A classical music form',
      'A type of boat',
    ],
    correctIndex: 1,
  ),
  QuestionnaireQuestion(
    question: 'Which of these is a famous snake boat race in Kerala?',
    options: ['Nehru Trophy', 'Rajiv Cup', 'Gandhi Trophy', 'Ambedkar Race'],
    correctIndex: 0,
  ),
  QuestionnaireQuestion(
    question: 'What does "Vanakkam" mean?',
    options: ['Come in', 'Goodbye', 'Welcome / Greetings', 'How are you'],
    correctIndex: 2,
  ),
  QuestionnaireQuestion(
    question: 'Which district in Kerala is known as the "cultural capital"?',
    options: ['Kochi', 'Thrissur', 'Kozhikode', 'Palakkad'],
    correctIndex: 1,
  ),
];
