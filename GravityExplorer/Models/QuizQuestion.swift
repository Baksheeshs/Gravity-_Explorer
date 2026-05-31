import Foundation

// MARK: - Quiz Question Model
struct QuizQuestion: Identifiable {
    let id = UUID()
    let moduleId: Int
    let question: String
    let options: [String]
    let correctIndex: Int
    let explanation: String
}

// MARK: - Question Bank
extension QuizQuestion {
    static let allQuestions: [QuizQuestion] = [

        // ── Module 1: What is Gravity? ──────────────────────────
        QuizQuestion(
            moduleId: 1,
            question: "What is gravity?",
            options: [
                "A force that pushes objects apart",
                "A force that pulls objects toward each other",
                "A type of electromagnetic radiation",
                "The spin of the Earth"
            ],
            correctIndex: 1,
            explanation: "Gravity is the force that pulls objects toward each other. Every object with mass exerts gravity."
        ),
        QuizQuestion(
            moduleId: 1,
            question: "If you drop a heavy ball and a light ball in a vacuum, which hits the ground first?",
            options: [
                "The heavy ball",
                "The light ball",
                "They hit at the same time",
                "Neither — they float"
            ],
            correctIndex: 2,
            explanation: "In a vacuum (no air resistance), all objects fall at the same rate regardless of their mass."
        ),
        QuizQuestion(
            moduleId: 1,
            question: "What does every object with mass have?",
            options: [
                "Light",
                "Heat",
                "Gravity",
                "Magnetism"
            ],
            correctIndex: 2,
            explanation: "Every object with mass exerts a gravitational pull on other objects."
        ),
        QuizQuestion(
            moduleId: 1,
            question: "Who is famous for describing gravity after watching an apple fall?",
            options: [
                "Albert Einstein",
                "Isaac Newton",
                "Galileo Galilei",
                "Nikola Tesla"
            ],
            correctIndex: 1,
            explanation: "Isaac Newton famously described the law of universal gravitation, inspired by observing falling objects."
        ),
        QuizQuestion(
            moduleId: 1,
            question: "What would happen to a dropped object if there were no gravity?",
            options: [
                "It would fall slower",
                "It would fall faster",
                "It would float and not fall",
                "It would move sideways"
            ],
            correctIndex: 2,
            explanation: "Without gravity, there is no force pulling the object downward, so it would simply float."
        ),

        // ── Module 2: Capital G vs Small g ──────────────────────
        QuizQuestion(
            moduleId: 2,
            question: "What does the universal gravitational constant G equal?",
            options: [
                "9.81 m/s²",
                "6.674 × 10⁻¹¹ N⋅m²/kg²",
                "3.14159",
                "1.62 m/s²"
            ],
            correctIndex: 1,
            explanation: "G = 6.674 × 10⁻¹¹ N⋅m²/kg² is the universal gravitational constant — it's the same everywhere in the universe."
        ),
        QuizQuestion(
            moduleId: 2,
            question: "What is the key difference between G and g?",
            options: [
                "G changes between planets, g is constant",
                "G is constant everywhere, g varies by location",
                "Both are the same value",
                "Neither is related to gravity"
            ],
            correctIndex: 1,
            explanation: "G is the universal constant that never changes. Small g is the local acceleration due to gravity, which varies by planet."
        ),
        QuizQuestion(
            moduleId: 2,
            question: "What is the value of g on Earth?",
            options: [
                "1.62 m/s²",
                "6.674 m/s²",
                "9.81 m/s²",
                "24.79 m/s²"
            ],
            correctIndex: 2,
            explanation: "On Earth, the acceleration due to gravity g ≈ 9.81 m/s²."
        ),
        QuizQuestion(
            moduleId: 2,
            question: "What is the formula for gravitational force between two masses?",
            options: [
                "F = m × a",
                "F = G × m₁ × m₂ / r²",
                "F = m × g",
                "F = ½ × m × v²"
            ],
            correctIndex: 1,
            explanation: "Newton's law of universal gravitation: F = G × m₁ × m₂ / r². Force depends on both masses and the distance between them."
        ),
        QuizQuestion(
            moduleId: 2,
            question: "If you double the distance between two objects, what happens to the gravitational force?",
            options: [
                "It doubles",
                "It stays the same",
                "It becomes one-quarter",
                "It halves"
            ],
            correctIndex: 2,
            explanation: "Gravity follows an inverse-square law: doubling the distance reduces the force to 1/4 (1/2² = 1/4)."
        ),

        // ── Module 3: Acceleration ──────────────────────────────
        QuizQuestion(
            moduleId: 3,
            question: "What is the acceleration due to gravity in free fall (on Earth)?",
            options: [
                "5.0 m/s²",
                "9.8 m/s²",
                "15.0 m/s²",
                "20.0 m/s²"
            ],
            correctIndex: 1,
            explanation: "In free fall on Earth, all objects accelerate at approximately g ≈ 9.8 m/s²."
        ),
        QuizQuestion(
            moduleId: 3,
            question: "Why does a feather fall slower than a ball in air?",
            options: [
                "The feather has less gravity",
                "Air resistance slows the feather more",
                "The ball is attracted to the ground more",
                "Feathers are immune to gravity"
            ],
            correctIndex: 1,
            explanation: "Air resistance affects lighter objects more. In a vacuum, both a feather and a ball fall at the same rate."
        ),
        QuizQuestion(
            moduleId: 3,
            question: "In a vacuum, how does velocity change during free fall?",
            options: [
                "It stays constant",
                "It decreases over time",
                "It increases linearly with time",
                "It increases then decreases"
            ],
            correctIndex: 2,
            explanation: "In free fall, velocity increases linearly with time: v = g × t. This produces a straight line on a velocity-time graph."
        ),
        QuizQuestion(
            moduleId: 3,
            question: "What does a velocity vs. time graph look like for free fall in a vacuum?",
            options: [
                "A horizontal line",
                "A straight line sloping upward",
                "A curve that flattens out",
                "A zigzag pattern"
            ],
            correctIndex: 1,
            explanation: "Since acceleration is constant (g), velocity increases at a steady rate — producing a straight upward-sloping line."
        ),
        QuizQuestion(
            moduleId: 3,
            question: "What happens to the acceleration of a falling object in a vacuum on Earth?",
            options: [
                "It increases as it falls",
                "It decreases as it falls",
                "It remains constant at 9.8 m/s²",
                "It becomes zero"
            ],
            correctIndex: 2,
            explanation: "In a vacuum near Earth's surface, acceleration due to gravity remains constant at approximately 9.8 m/s²."
        ),

        // ── Module 4: Zero Gravity ──────────────────────────────
        QuizQuestion(
            moduleId: 4,
            question: "Why do astronauts float in the International Space Station?",
            options: [
                "There is no gravity in space",
                "They are in continuous free fall around Earth",
                "The ISS has anti-gravity technology",
                "They are too far from Earth for gravity"
            ],
            correctIndex: 1,
            explanation: "Astronauts aren't truly gravity-free — they're in continuous free fall around Earth, creating the sensation of weightlessness."
        ),
        QuizQuestion(
            moduleId: 4,
            question: "What is the correct term for the 'floating' sensation in orbit?",
            options: [
                "Anti-gravity",
                "Weightlessness (microgravity)",
                "Zero mass",
                "Gravitational immunity"
            ],
            correctIndex: 1,
            explanation: "The correct term is weightlessness or microgravity. Gravity still exists, but everything falls together."
        ),
        QuizQuestion(
            moduleId: 4,
            question: "What would happen to water poured from a cup in zero gravity?",
            options: [
                "It would fall to the floor",
                "It would form a floating sphere",
                "It would evaporate instantly",
                "It would stick to the cup"
            ],
            correctIndex: 1,
            explanation: "Without gravity pulling it down, water forms floating spheres due to surface tension."
        ),
        QuizQuestion(
            moduleId: 4,
            question: "Is there truly zero gravity anywhere in the universe?",
            options: [
                "Yes, in deep space",
                "Yes, inside the ISS",
                "No — gravity extends infinitely, just gets weaker",
                "Yes, on the Moon"
            ],
            correctIndex: 2,
            explanation: "Gravity never truly reaches zero. It extends infinitely from every mass, but gets weaker with distance."
        ),
        QuizQuestion(
            moduleId: 4,
            question: "Why do all objects inside the ISS float together?",
            options: [
                "The ISS cancels gravity",
                "Everything is falling at the same rate",
                "Objects lose their mass in space",
                "Air pressure pushes them up"
            ],
            correctIndex: 1,
            explanation: "The ISS and everything inside it are all falling toward Earth at the same rate, so they appear to float relative to each other."
        ),

        // ── Module 5: Gravity & Human Body ──────────────────────
        QuizQuestion(
            moduleId: 5,
            question: "What force balances your weight when you stand on the ground?",
            options: [
                "Friction",
                "Air resistance",
                "Normal force",
                "Centripetal force"
            ],
            correctIndex: 2,
            explanation: "The normal force is the ground pushing back up on you, balancing your weight so you don't fall through."
        ),
        QuizQuestion(
            moduleId: 5,
            question: "Why do you feel heavier in an elevator accelerating upward?",
            options: [
                "Your mass increases",
                "The normal force exceeds your weight",
                "Gravity gets stronger in elevators",
                "Your weight decreases"
            ],
            correctIndex: 1,
            explanation: "When accelerating upward, the floor pushes harder (greater normal force), making you feel heavier. Your actual weight hasn't changed."
        ),
        QuizQuestion(
            moduleId: 5,
            question: "What is your apparent weight during free fall?",
            options: [
                "Double your normal weight",
                "Same as your normal weight",
                "Zero — you feel weightless",
                "Half your normal weight"
            ],
            correctIndex: 2,
            explanation: "In free fall, there is no normal force acting on you, so your apparent weight is zero — you feel weightless."
        ),
        QuizQuestion(
            moduleId: 5,
            question: "Approximately how much does a 70 kg person weigh on Earth (in Newtons)?",
            options: [
                "70 N",
                "350 N",
                "700 N",
                "7000 N"
            ],
            correctIndex: 2,
            explanation: "Weight = mass × g = 70 kg × 9.81 m/s² ≈ 700 N."
        ),
        QuizQuestion(
            moduleId: 5,
            question: "What happens to an astronaut's apparent weight in orbit?",
            options: [
                "It doubles because they move fast",
                "It stays at 700 N",
                "It becomes zero because they are in free fall",
                "It increases due to speed"
            ],
            correctIndex: 2,
            explanation: "In orbit, astronauts are in continuous free fall, so their apparent weight is zero — they feel weightless."
        ),

        // ── Module 6: Planet Explorer ───────────────────────────
        QuizQuestion(
            moduleId: 6,
            question: "On which planet would you jump the highest?",
            options: [
                "Jupiter",
                "Earth",
                "Moon",
                "Saturn"
            ],
            correctIndex: 2,
            explanation: "The Moon has the lowest surface gravity (g = 1.62 m/s²), so you would jump about 6× higher than on Earth."
        ),
        QuizQuestion(
            moduleId: 6,
            question: "What is the surface gravity on Jupiter?",
            options: [
                "3.72 m/s²",
                "9.81 m/s²",
                "24.79 m/s²",
                "1.62 m/s²"
            ],
            correctIndex: 2,
            explanation: "Jupiter has the strongest surface gravity of the listed planets at 24.79 m/s² — you'd barely be able to jump!"
        ),
        QuizQuestion(
            moduleId: 6,
            question: "What two factors determine a planet's surface gravity?",
            options: [
                "Temperature and distance from the Sun",
                "Mass and radius",
                "Color and speed",
                "Number of moons and rings"
            ],
            correctIndex: 1,
            explanation: "A planet's surface gravity depends on its mass and radius: g = G × M / R²."
        ),
        QuizQuestion(
            moduleId: 6,
            question: "If Earth's gravity is 9.81 m/s², what is Mars's gravity approximately?",
            options: [
                "1.62 m/s²",
                "3.72 m/s²",
                "8.87 m/s²",
                "24.79 m/s²"
            ],
            correctIndex: 1,
            explanation: "Mars has a surface gravity of about 3.72 m/s² — roughly 38% of Earth's gravity."
        ),
        QuizQuestion(
            moduleId: 6,
            question: "How is jump height related to surface gravity?",
            options: [
                "Higher gravity = higher jumps",
                "Gravity doesn't affect jump height",
                "Lower gravity = higher jumps",
                "Jump height is always the same"
            ],
            correctIndex: 2,
            explanation: "Jump height = v² / (2g). Lower gravity means the same jump velocity carries you much higher."
        ),
    ]

    static func questions(for moduleId: Int) -> [QuizQuestion] {
        allQuestions.filter { $0.moduleId == moduleId }
    }
}
